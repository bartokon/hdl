`timescale 1ns/100ps
`default_nettype none

module my_switch #(
    parameter DATA_WIDTH = 64,
    parameter INPUT_QTY = 8,
    parameter OUTPUT_QTY = 8
) (
    /* clock, reset */
    input wire clk,
    input wire reset,

    /* inputs */
    input wire [INPUT_QTY - 1 : 0] data_in_valid,
    output logic [INPUT_QTY - 1 : 0] data_in_ready,
    input wire [INPUT_QTY - 1 : 0] [DATA_WIDTH + $clog2(OUTPUT_QTY) - 1 : 0] data_in,

    /* outputs */
    output logic [OUTPUT_QTY - 1 : 0] data_out_valid,
    output logic [OUTPUT_QTY - 1 : 0] [DATA_WIDTH - 1 : 0] data_out
);

initial begin
    if ($clog2(OUTPUT_QTY) == 0) begin
        $display("clog2 is %d", $clog2(OUTPUT_QTY));
        $error("This is not supported OUTPUT_QTY must be > 1");
    end
end

//Extract payload and destination
logic [INPUT_QTY - 1 : 0 ] [DATA_WIDTH - 1 : 0] data_in_payload;
logic [INPUT_QTY - 1 : 0 ] [$clog2(OUTPUT_QTY) - 1 : 0] data_in_destination;

//Notice: Only good destinations supported!
always @(posedge clk) begin
    for (integer i = 0; i < INPUT_QTY; i = i + 1) begin
        if (data_in_destination[i] != 'x) begin
            assert property (data_in_destination[i] < OUTPUT_QTY) else begin
                $display("data_in_destination: %d", data_in_destination[i]);
                $error;
            end
        end
    end
end

generate
    for (genvar i = 0; i < INPUT_QTY; i = i + 1) begin
        assign data_in_payload[i] = data_in[i][DATA_WIDTH + $clog2(OUTPUT_QTY) - 1 : $clog2(OUTPUT_QTY)];
        assign data_in_destination[i] = data_in[i][$clog2(OUTPUT_QTY) - 1 : 0];
    end
endgenerate

logic [OUTPUT_QTY - 1 : 0] [DATA_WIDTH - 1 : 0] data_out_q, data_out_d;
logic [OUTPUT_QTY - 1 : 0] data_out_valid_q, data_out_valid_d;
logic [INPUT_QTY - 1 : 0] data_in_ready_d;

generate
    for (genvar i = 0; i < INPUT_QTY; i = i + 1) begin
        assign data_in_ready[i] = data_in_ready_d[i];
    end
    for (genvar i = 0; i < OUTPUT_QTY; i = i + 1) begin
        assign data_out[i] = data_out_q[i];
        assign data_out_valid[i] = data_out_valid_q[i];
    end
endgenerate

always_comb begin
    for (integer i = 0; i < OUTPUT_QTY; i = i + 1) begin
        data_out_valid_d[i] = 1'b0;
        data_out_d[i] = data_out_q[i];
    end
    for (integer i = 0; i < INPUT_QTY; i = i + 1) begin
        if (data_in_valid[i] == 1'b1) begin
            if (data_out_valid_d[data_in_destination[i]] == 1'b0) begin
                data_out_d[data_in_destination[i]] = data_in_payload[i];
                data_out_valid_d[data_in_destination[i]] = 1'b1;
                data_in_ready_d[i] = 1'b1;
            end else begin
                data_in_ready_d[i] = 1'b0;
            end
        end else begin
            data_in_ready_d[i] = 1'b0;
        end
    end
end

always_ff @(posedge clk) begin
    if (reset == 1'b1) begin
        for (integer i = 0; i < OUTPUT_QTY; i = i + 1) begin
            data_out_q[i] <= 0;
            data_out_valid_q[i] <= 0;
        end
    end else begin
        for (integer i = 0; i < OUTPUT_QTY; i = i + 1) begin
            data_out_q[i] <= data_out_d[i];
            data_out_valid_q[i] <= data_out_valid_d[i];
        end
    end
end

endmodule