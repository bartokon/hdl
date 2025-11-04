`include "uvm_macros.svh"
import uvm_pkg::*;

`include "interface.sv"
`include "uvm_test.sv"

module tb;

    reg clk = 0;
    
    always #10 clk = ~clk;

    axi4_stream if_i(.clk(clk));
    axi4_stream if_o(.clk(clk));
    
    skid_buffer u0 (
        // Input ports
        .data_i(if_i.data),
        .data_valid_i(if_i.valid),
        .data_ready_o(if_i.ready),
        // Output ports
        .data_o(if_o.data),
        .data_valid_o(if_o.valid),
        .data_ready_i(if_o.ready),
        // Misc
        .clk_i(if_i.clk),
        .rst_clk_ni(if_i.rstn)
    );
  
    initial begin 
        uvm_config_db#(virtual axi4_stream)::set(null, "", "axi4_stream_input", if_i);
        uvm_config_db#(virtual axi4_stream)::set(null, "", "axi4_stream_output", if_o);
    end
    
    initial begin 
        run_test("test");
    end
    
endmodule