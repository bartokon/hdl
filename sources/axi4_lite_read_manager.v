`timescale 1ns / 1ps
`default_nettype none

module axi_lite_read_manager
#(
    parameter ADDRESS_SIZE = 32,
    parameter DATA_SIZE = 32
)
(
    //Read port
    input wire [ADDRESS_SIZE - 1 : 0] read_address,
    input wire read_address_valid,
    output wire read_address_ready,

    output wire [DATA_SIZE - 1 :0] read_data,
    output wire read_data_valid,
    input wire read_data_ready,

    //Read port response
    output wire [1 : 0] read_data_response, //2bit

    //Misc
    input wire aclk,
    input wire aresetn,
    
    input wire [DATA_SIZE - 1 :0] register_data_0
);
    
    localparam [2:0] RESET = 3'b00;
    localparam [2:0] FETCH = 3'b01;
    localparam [2:0] READ = 3'b10;
    localparam [2:0] SEND = 3'b11;
    
    reg [1:0] STATE = RESET;
    reg [ADDRESS_SIZE - 1 : 0] read_address_reg = 0;
    reg [DATA_SIZE - 1 :0] read_data_reg = 0;
    reg read_address_ready_reg = 0;
    reg read_data_valid_reg = 0;
    reg [1 : 0] read_data_response_reg = 0;
    
    assign read_data_response = read_data_response_reg;
    assign read_address_ready = read_address_ready_reg;
    assign read_data = read_data_reg;
    assign read_data_valid = read_data_valid_reg;
        
    always @(posedge aclk) begin 
        if (aresetn == 0) begin 
            STATE <= RESET;
        end else begin 
            case (STATE)
                RESET: begin 
                    read_address_reg <= 0;
                    read_address_ready_reg <= 1;
                    read_data_reg <= 0;
                    read_data_valid_reg <= 0;
                    STATE <= FETCH;
                end
                FETCH: begin
                    if (read_address_valid && read_address_ready) begin 
                        read_address_reg <= read_address;
                        read_address_ready_reg <= 0;
                        STATE <= READ;
                    end 
                end
                READ: begin 
                    if (read_address_reg == 0) begin 
                        read_data_reg <= register_data_0;
                        read_data_response_reg <= 2'b00;
                    end else begin 
                        read_data_response_reg <= 2'b10;
                    end
                    read_data_valid_reg <= 1;
                    STATE <= SEND;
                end
                SEND: begin 
                    if (read_data_valid_reg && read_data_ready) begin 
                        read_data_valid_reg <= 0;
                        read_address_ready_reg <= 1;
                        STATE <= FETCH;
                    end
                end
            endcase
        end
    end
endmodule
