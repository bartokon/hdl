//`default_nettype none

module axi4_lite_read_manager #(
    parameter ADDRESS_SIZE = 32,
    parameter DATA_SIZE = 32
) (
    //Read port
    input logic [ADDRESS_SIZE-1:0] read_address_i,
    input logic read_address_valid_i,
    output logic read_address_ready_o,

    //Read port response
    output logic [1:0] read_data_response_o, //2bit
    output logic [DATA_SIZE-1:0] read_data_o,
    output logic read_data_valid_o,
    input logic read_data_ready_i,

    //Misc
    input logic clk_i,
    input logic rst_clk_ni,

    input logic [DATA_SIZE-1:0] register_data_0_i
);

    logic stall;
    logic [ADDRESS_SIZE-1:0] read_address_q;
    logic read_address_valid_q;
    always_ff @(posedge clk_i) begin: pipeline_0_read_addr
        if (rst_clk_ni == 0) begin
            read_address_q <= 0;
            read_address_valid_q <= 0;
            read_address_ready_o <= 0;
        end else begin
            read_address_q <= read_address_i;
            read_address_valid_q <= read_address_valid_i;
            read_address_ready_o <= stall;
        end
    end

    logic [DATA_SIZE-1:0] register_data_q, register_data_d;
    logic [1:0] read_data_response_q;
    always_comb begin: address_decode
        read_data_response_q = 2'b00;
        case (read_address_q)
        0: begin
            register_data_q = register_data_0_i;
        end
        default: begin
            read_data_response_q = 2'b10;
            register_data_q = register_data_d;
        end
    endcase
    end

    always_ff @(posedge clk_i) begin
        if (rst_clk_ni == 0) begin
            register_data_d <= 0;
            stall <= 0;
            read_data_o <= 0;
            read_data_response_o <= 0;
            read_data_valid_o <= 0;
        end else begin
            stall <= read_data_ready_i;
            read_data_o <= register_data_q;
            read_data_response_o <= read_data_response_q;
            read_data_valid_o <= read_address_valid_q;
        end
    end

endmodule
