`timescale 1ps/1ps
`default_nettype wire

module axi4_lite_master_lut #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDRESS_WIDTH = 32
) (
    //IO
    output logic [DATA_WIDTH - 1 : 0] memory_data,
    output logic [(DATA_WIDTH / 8 ) - 1 : 0] memory_strobe,
    output logic [ADDRESS_WIDTH - 1 : 0] memory_address,
    output logic memory_data_valid,
    input logic [ADDRESS_WIDTH - 1 : 0 ] memory_index,

    //Clock and reset
    input logic clk,
    input logic resetn
);

typedef struct packed {
    logic [DATA_WIDTH - 1 : 0] data;
    logic [(DATA_WIDTH / 8) - 1 : 0] strobe;
    logic [ADDRESS_WIDTH - 1 : 0] address;
} lut_data;

lut_data look_up_table [8 - 1 : 0];

function lut_data create_transaction (
    input [DATA_WIDTH - 1 : 0] data,
    input [(DATA_WIDTH / 8) - 1 : 0] strobe,
    input [ADDRESS_WIDTH - 1 : 0 ] address
);
    automatic lut_data temp = {data, strobe, address};
    return temp;
endfunction

initial begin
    look_up_table[0] = create_transaction(
        32'hFFFF_FFFF,
        4'b1111,
        32'h4000_0000
    );
    look_up_table[1] = create_transaction(
        32'h0000_FFFF,
        4'b1111,
        32'h4000_0000
    );
    look_up_table[2] = create_transaction(
        32'hFFFF_0000,
        4'b1111,
        32'h4000_0000
    );
    look_up_table[3] = create_transaction(
        32'h0000_0000,
        4'b1111,
        32'h4000_0000
    );
end

lut_data temp_variable;
always_comb begin
    memory_data_valid = (memory_index < 4) && resetn; //Number of transactions
    temp_variable = look_up_table[memory_index];
    memory_data = temp_variable.data;
    memory_strobe = temp_variable.strobe;
    memory_address = temp_variable.address;
end

endmodule



