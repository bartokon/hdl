module axi4_stream_fifo #(
    parameter int unsigned DATA_SIZE = 16
) (
    input  logic [DATA_SIZE - 1 : 0] data_in_tdata,
    input  logic data_in_tvalid,
    output logic data_in_tready,
    output logic [DATA_SIZE - 1 : 0] data_out_tdata,
    output logic data_out_tvalid,
    input  logic data_out_tready,
    input  logic clk_i,
    input  logic clk_o,
    input  logic rst_ni
);

    // skid_buffer #(
    //     .DATA_SIZE(DATA_SIZE)
    // ) u0_in_skid_buffer (
    //     // Input ports
    //     .data_i(data_in_tdata),
    //     .data_valid_i(data_in_tvalid),
    //     .data_ready_o(data_in_tready),
    //     // Output ports
    //     .data_o(data_out_tdata),
    //     .data_valid_o(data_out_tvalid),
    //     .data_ready_i(data_out_tready),
    //     // Misc
    //     .clk_i(clk_i),
    //     .rst_clk_ni(rst_clk_ni)
    // );

    // //Metastability! for rst_clk_ni
    // skid_buffer #(
    //     .DATA_SIZE(DATA_SIZE)
    // ) u0_out_skid_buffer (
    //     // Input ports
    //     .data_i(data_in_tdata),
    //     .data_valid_i(data_in_tvalid),
    //     .data_ready_o(data_in_tready),
    //     // Output ports
    //     .data_o(data_out_tdata),
    //     .data_valid_o(data_out_tvalid),
    //     .data_ready_i(data_out_tready),
    //     // Misc
    //     .clk_i(clk_o),
    //     .rst_clk_ni(rst_clk_ni)
    // );

    dual_port_ram_fifo #(
        .DATA_SIZE(DATA_SIZE)
    ) u0_dual_port_ram (
        .data_in_tdata(data_in_tdata),
        .data_in_tvalid(data_in_tvalid),
        .data_in_tready(data_in_tready),
        .data_out_tdata(data_out_tdata),
        .data_out_tvalid(data_out_tvalid),
        .data_out_tready(data_out_tready),
        .clk_i(clk_i),
        .clk_o(clk_o),
        .rst_ni(rst_ni)
    );

endmodule