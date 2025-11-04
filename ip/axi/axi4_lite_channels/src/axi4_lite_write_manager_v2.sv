//`timescale 1ns / 1ps
//`default_nettype none

module axi4_lite_write_manager #(
    parameter ADDRESS_SIZE = 4,
    parameter DATA_SIZE = 32,
    parameter REGISTERS = 1
) (
    //Write port
    input logic [ADDRESS_SIZE-1 : 0] write_address_i,
    input logic write_address_valid_i,
    output logic write_address_ready_o,

    input logic [DATA_SIZE-1:0] write_data_i,
    input logic [(DATA_SIZE/8)-1:0] write_data_strobe_i,
    input logic write_data_valid_i,
    output logic write_data_ready_o,

    //Write port response
    output logic [1 : 0] write_response_o,
    output logic write_response_valid_o,
    input logic write_response_ready_i,

    //Misc
    input logic clk_i,
    input logic rst_clk_i,

    output logic [DATA_SIZE-1 :0] register_data_o,
    output logic [(DATA_SIZE/8)-1:0] register_data_strobe_o,
    output logic [ADDRESS_SIZE-1:0] register_address_o,
    output logic enable_register_data_o
);

    logic [ADDRESS_SIZE-1:0] write_address_q;
    logic [DATA_SIZE-1:0] write_data_q;
    logic [(DATA_SIZE/8)-1:0] write_data_strobe_q;
    logic write_ready, write_ready_q;

    assign write_ready = (write_address_ready_o && write_address_valid_i)
        && (write_data_ready_o && write_data_valid_i);
    assign write_data_ready_o = write_response_ready_i
        && (write_address_valid_i && write_data_valid_i);
    assign write_address_ready_o = write_response_ready_i
        && (write_address_valid_i && write_data_valid_i);

    always_ff @(posedge clk_i) begin
        if (rst_clk_i == 0) begin
            write_address_q <= 0;
            write_data_q <= 0;
            write_data_strobe_q <= 0;
            write_ready_q <= 0;
        end else begin
            write_ready_q <= write_ready;
            if (write_ready) begin
                write_address_q <= write_address_i;
                write_data_q <= write_data_i;
                write_data_strobe_q <= write_data_strobe_i;
            end
        end
    end

    logic [1:0] write_response_q;
    logic write_response_valid_q;
    logic [ADDRESS_SIZE-1:0] register_number;
    always_comb begin
        register_number = (write_address_q / 4);
        register_data_o = write_data_q;
        register_address_o = register_number;
        register_data_strobe_o = write_data_strobe_q;
        enable_register_data_o =
            (register_number < REGISTERS) ? write_ready_q : 0;
        write_response_valid_q = write_ready_q;
        write_response_q = (register_number < REGISTERS) ? 2'b00 : 2'b10;
    end

    always_ff @(posedge clk_i) begin
        if (rst_clk_i == 0) begin
            write_response_o <= 0;
            write_response_valid_o <= 0;
        end else begin
            write_response_o <= write_response_q;
            write_response_valid_o <= write_response_valid_q;
        end
    end

endmodule
