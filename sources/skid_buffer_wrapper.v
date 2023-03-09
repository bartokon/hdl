module skid_buffer_wrapper #(
    parameter DATA_SIZE = 8
) (
    // Input ports
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *)
    input wire [DATA_SIZE-1:0] data_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *)
    input wire data_valid_i,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *)
    output wire data_ready_o,
    // Output ports
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *)
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *)
    output wire [DATA_SIZE-1:0] data_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *)
    output wire data_valid_o,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *)
    input wire data_ready_i,
    // Misc
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_I CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_I, ASSOCIATED_BUSIF M_AXIS:S_AXIS, ASSOCIATED_RESET rst_clk_ni" *)
    input wire clk_i,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RST_CLK_NI RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RST_CLK_NI, POLARITY ACTIVE_LOW" *)
    input wire rst_clk_ni
);

skid_buffer #(
    .DATA_SIZE(DATA_SIZE)
) u0_skid_buffer (
    // Input ports
    .data_i(data_i),
    .data_valid_i(data_valid_i),
    .data_ready_o(data_ready_o),
    // Output ports
    .data_o(data_o),
    .data_valid_o(data_valid_o),
    .data_ready_i(data_ready_i),
    // Misc
    .clk_i(clk_i),
    .rst_clk_ni(rst_clk_ni)
);

endmodule
