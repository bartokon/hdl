
module axi4_stream_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 4
) (
    input logic [WIDTH - 1 : 0] s_axis_tdata,
    input logic s_axis_tvalid,
    output logic s_axis_tready,

    output logic [WIDTH - 1 : 0] m_axis_tdata,
    output logic m_axis_tvalid,
    input logic m_axis_tready,

    output logic empty,
    output logic full,

    input logic clk,
    input logic resetn
);
    localparam POINTER_WIDTH = $clog2(DEPTH);

    logic WRITE_OPERATION;
    logic READ_OPERATION;

    logic [POINTER_WIDTH - 1 : 0] read_pointer;
    logic [POINTER_WIDTH - 1 : 0] write_pointer;
    logic [WIDTH - 1 : 0] memory [DEPTH - 1 : 0];

    assign empty = (read_pointer == write_pointer);
    assign full = ((write_pointer + 1) == read_pointer);
    assign WRITE_OPERATION = s_axis_tvalid && s_axis_tready;
    assign READ_OPERATION = m_axis_tvalid && m_axis_tready;
    assign m_axis_tdata = memory[read_pointer];

    always_ff @(posedge clk) begin
        if (resetn == 0) begin
            write_pointer <= 0;
            s_axis_tready <= 0;
        end else begin
            write_pointer <= write_pointer + (WRITE_OPERATION);
            s_axis_tready <= !full;
        end
    end

    always_ff @(posedge clk) begin
        if (resetn == 0) begin
            read_pointer <= 0;
            m_axis_tvalid <= 0;
        end else begin
            read_pointer <= read_pointer + (READ_OPERATION);
            m_axis_tvalid <= !empty;
        end
    end

    always_ff @(posedge clk) begin
        if (resetn == 0) begin
            for (int i = 0; i < DEPTH; ++i) begin
                memory[i] <= 0;
            end
        end else begin
            if (WRITE_OPERATION) begin
                memory[write_pointer] <= s_axis_tdata;
            end
        end
    end
endmodule