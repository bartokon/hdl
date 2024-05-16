`include "uvm_macros.svh"
import uvm_pkg::*;

`include "interface.sv"
`include "uvm_test.sv"

module tb;

    logic clk = 0;
    always #10 clk = ~clk;

    axi4_stream if_i(.clk(clk));
    axi4_stream if_o(.clk(clk));

    axi4_stream_fifo u0 (
        .s_axis_tdata(if_i.data),
        .s_axis_tvalid(if_i.valid),
        .s_axis_tready(if_i.ready),

        .m_axis_tdata(if_o.data),
        .m_axis_tvalid(if_o.valid),
        .m_axis_tready(if_o.ready),

        .empty(if_o.empty),
        .full(if_i.full),

        .clk(clk),
        .resetn(if_i.rstn)
    );

    initial begin
        uvm_config_db#(virtual axi4_stream)::set(null, "", "axi4_stream_input", if_i);
        uvm_config_db#(virtual axi4_stream)::set(null, "", "axi4_stream_output", if_o);
    end

    initial begin
        run_test("test");
    end

endmodule