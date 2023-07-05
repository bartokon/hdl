`ifndef INTERFACE_SV
`define INTERFACE_SV

interface axi4_stream_master #(
    parameter DATA_SIZE = 8
) (
    input clk,
    input resetn
);
    logic [DATA_SIZE - 1 : 0] data;
    logic valid;
    logic ready;
endinterface

interface axi4_stream_slave #(
    parameter DATA_SIZE = 8
) (
    input clk,
    input resetn
);
    logic [DATA_SIZE - 1 : 0] data;
    logic valid;
    logic ready;
endinterface

`endif