//`timescale 1ns / 1ps
//`default_nettype none

module axi4_lite_write #(
    parameter DEPTH = 4,
    parameter DATA_SIZE = 32
) (
    //Write port
    input logic [$clog2(DEPTH) - 1 : 0] write_address_i,
    input logic write_address_valid_i,
    output logic write_address_ready_o,

    input logic [DATA_SIZE - 1 : 0] write_data_i,
    input logic [DATA_SIZE / 8 - 1 : 0] write_data_strb_i,
    input logic write_data_valid_i,
    output logic write_data_ready_o,

    //Write port response
    output logic [1 : 0] write_response_o,
    output logic write_response_valid_o,
    input logic write_response_ready_i,

    //Misc
    input logic clk_i,
    input logic rst_clk_ni,

    output logic [DATA_SIZE - 1 : 0] register_data_o,
    output logic [$clog2(DEPTH) - 1 : 0] register_address_o,
    output logic [DATA_SIZE / 8 - 1 : 0] enable_register_data_o
);
    logic state; 
    always_ff @(posedge clk_i) begin
        if (rst_clk_ni == 0) begin
            state <= 0;
            register_data_o <= 0;
            register_address_o <= 0;
            enable_register_data_o <= 0;
            write_data_ready_o <= 0;
            write_address_ready_o <= 0;
        end else begin
            if (state == 1'b0) begin 
                state <= write_data_valid_i & write_address_valid_i;
                register_data_o <= write_data_i;
                register_address_o <= write_address_i;
                enable_register_data_o <= write_data_strb_i & {(DATA_SIZE / 8){write_data_valid_i & write_address_valid_i}};        
                write_data_ready_o <= write_data_valid_i & write_address_valid_i;
                write_address_ready_o <= write_data_valid_i & write_address_valid_i;
                write_response_o <= (register_address_o <= $clog2(DEPTH)) ? 2'b00 : 2'b10; //Should stall for HS
                write_response_valid_o <= write_data_valid_i & write_address_valid_i;
            end else begin 
                write_data_ready_o <= 1'b0;
                state <= ~(write_response_valid_o & write_response_ready_i);
            end
        end
    end

endmodule
