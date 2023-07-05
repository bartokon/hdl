`include "interface.sv"

module uvm_skid_buffer #(
    parameter DATA_SIZE = 8
) (
    axi4_stream_slave data_in,
    axi4_stream_master data_out
);

    //Should data_out have clock???
    assign data_out.resetn = data_in.resetn;
    assign data_out.clk = data_in.clk;
    
skid_buffer #(
    .DATA_SIZE(DATA_SIZE)
) u0_skid_buffer (
    // Input ports
    .data_i(data_in.data),
    .data_valid_i(data_in.valid),
    .data_ready_o(data_in.ready),
    // Output ports
    .data_o(data_out.data),
    .data_valid_o(data_out.valid),
    .data_ready_i(data_out.ready),
    // Misc
    .clk_i(data_in.clk),
    .rst_clk_ni(data_in.resetn)
);

endmodule