`timescale 1ns/100ps
`default_nettype none

module very_simple_switch #(
    parameter integer DATA_WIDTH = 8,
    parameter integer INPUT_QTY = 2,
    parameter integer OUTPUT_QTY = 2
) (
    /* clock, reset */
    input wire clk,
    input wire reset,

    /* inputs */
    input wire [INPUT_QTY - 1 : 0] data_in_valid,
    input wire [INPUT_QTY - 1 : 0] [DATA_WIDTH - 1 : 0] data_in,
    input wire [INPUT_QTY - 1 : 0] [$clog2(OUTPUT_QTY) - 1 : 0] data_in_destination,

    /* outputs */
    output logic [OUTPUT_QTY - 1 : 0] data_out_valid,
    output logic [OUTPUT_QTY - 1 : 0] [DATA_WIDTH - 1 : 0] data_out
);

localparam FIFO_WIDTH = DATA_WIDTH + $clog2(OUTPUT_QTY);

logic [INPUT_QTY - 1 : 0] [FIFO_WIDTH - 1 : 0] fifo_dout;
logic [INPUT_QTY - 1 : 0] pop;
logic [INPUT_QTY - 1 : 0] empty;

for (genvar i = 0; i < INPUT_QTY; i = i + 1) begin
//    fifo #(
//        .DWIDTH(FIFO_WIDTH),
//        .LOG2_DEPTH(2)
//    ) data_in_fifos (
//        //input
//        .din({data_in[i], data_in_destination[i]}),
//        .push(data_in_valid[i]),
//        .full(), //nc
//        //output
//        .dout(fifo_dout[i]),
//        .pop(pop[i]),
//        .empty(empty[i]),
//        //clk reset
//        .clk(clk),
//        .reset(reset)
//    );
    
    fifo_generator_0 data_in_fifos (
      .clk(clk),      // input wire clk
      .srst(reset),    // input wire srst
      .din({data_in[i], data_in_destination[i]}),      // input wire [31 : 0] din
      .wr_en(data_in_valid[i]),  // input wire wr_en
      .rd_en(pop[i]),  // input wire rd_en
      .dout(fifo_dout[i]),    // output wire [31 : 0] dout
      .full(),    // output wire full
      .empty(empty[i])  // output wire empty
    );
end

my_switch #(
    .DATA_WIDTH(DATA_WIDTH),
    .INPUT_QTY(INPUT_QTY),
    .OUTPUT_QTY(OUTPUT_QTY)
) u0_my_switch (
    .clk(clk),
    .reset(reset),

    .data_in_valid(~empty),
    .data_in_ready(pop),
    .data_in(fifo_dout),

    .data_out_valid(data_out_valid),
    .data_out(data_out)
);


endmodule