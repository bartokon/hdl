`ifndef INTERFACE_SV
`define INTERFACE_SV

interface axi4_stream #(
    parameter DATA_SIZE = 8
) (
    input clk
);
    logic [DATA_SIZE - 1 : 0] data;
    logic valid;
    logic ready;
    logic rstn;
    
    modport slave (
        input data,
        input valid,
        output ready
    );
    
    modport master (
        output data,
        output valid,
        input ready
    );
    
endinterface

`endif