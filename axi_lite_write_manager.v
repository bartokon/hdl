`timescale 1ns / 1ps
`default_nettype none

module axi_lite_write_manager
#(
    parameter ADDRESS_SIZE = 32,
    parameter DATA_SIZE = 32,

    parameter WRITE_STROBE = (DATA_SIZE / 8)
)
(
    //Write port
    input wire [ADDRESS_SIZE - 1 : 0] write_address,
    input wire write_address_valid,
    output wire write_address_ready,

    input wire [DATA_SIZE - 1 :0] write_data,
    input wire [WRITE_STROBE - 1 :0] write_data_strobe, //Indicates what bytes of data are valid - 1 bit for each byte in write_data
    input wire write_data_valid,
    output wire write_data_ready,

    //Write port response
    output wire [1 : 0] write_response, //2bit
    output wire write_response_valid,
    input wire write_response_ready,
    
    //Misc
    input wire aclk,
    input wire aresetn,
    
    output reg [DATA_SIZE - 1 :0] register_data_0,
    output reg register_write_enable_0
);
    localparam [1:0] RESET = 2'b00;
    localparam [1:0] FETCH = 2'b01;
    localparam [1:0] WRITE = 2'b10;
    localparam [1:0] RESPONSE = 2'b11;
    
    reg [1:0] STATE = RESET;
    reg write_address_ready_reg = 0;
    reg write_data_ready_reg = 0;
    reg [1:0] write_response_reg = 0;
    reg write_response_valid_reg = 0;
    reg [ADDRESS_SIZE - 1 : 0] write_address_reg = 0;
    reg [DATA_SIZE - 1 : 0] write_data_reg = 0;
    reg write_address_locked = 0;
    reg write_data_locked = 0;
                        
    assign write_data_ready = write_data_ready_reg;
    assign write_address_ready = write_address_ready_reg;
    assign write_response = write_response_reg;
    assign write_response_valid = write_response_valid_reg;
     
    always @(posedge aclk) begin 
        if (aresetn == 0) begin 
            STATE <= RESET;
        end else begin 
            case (STATE)
                RESET: begin 
                    write_address_ready_reg <= 1;
                    write_data_ready_reg <= 1;
                    write_response_reg <= 0;
                    write_response_valid_reg <= 0;
                    write_data_reg <= 0;
                    write_address_locked <= 0;
                    write_data_locked <= 0;
                    register_data_0 <= 0;
                    register_write_enable_0 <= 0; 
                    STATE <= FETCH;
                end
                FETCH: begin 
                    if (write_address_ready_reg && write_address_valid) begin 
                        write_address_reg <= write_address;
                        write_address_ready_reg <=0;
                        write_address_locked <= 1;
                    end
                    if (write_data_ready_reg && write_data_valid) begin 
                        write_data_reg <= write_data;
                        write_data_ready_reg <= 0;
                        write_data_locked <= 1;
                    end
                    if (write_address_locked && write_data_locked) begin 
                        write_address_locked <= 0;
                        write_data_locked <= 0;
                        STATE <= WRITE;
                    end
                end
                WRITE: begin 
                //Todo: Add last n bits addres-range checking
                //Addresing is global space!
                //Xilinx minimum address space is 128 so last 7 bits for addressing internal register should be taken into account!
                    if (write_address_reg == 0) begin 
                        register_data_0 <= write_data_reg;
                        register_write_enable_0 <= 1;
                        write_response_reg <= 2'b00; //GOOD WRITE
                    end else begin 
                        write_response_reg <= 2'b11; // Error wrong write address SLVERR
                    end
                    STATE <= RESPONSE;
                    write_response_valid_reg <= 1;            
                end
                RESPONSE: begin
                    register_write_enable_0 <= 0; 
                    if (write_response_valid_reg && write_response_ready) begin 
                        write_address_ready_reg <=1;
                        write_data_ready_reg <= 1;
                        write_response_valid_reg <= 0;
                        STATE <= FETCH;
                    end
                end
            endcase
        end
    end


endmodule
