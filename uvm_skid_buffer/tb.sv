`include "uvm_macros.svh"
import uvm_pkg::*;

`include "interface.sv"
`include "uvm_test.sv"

module tb;

    reg clk = 0;
    reg resetn = 0;
    
    always #10 clk = ~clk;
    axi4_stream_master if_i(clk, resetn);
    axi4_stream_slave if_o(clk, resetn); //Do i need clk?
    //For what i have created wrapper with intf?
    
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
        .clk_i(clk),
        .rst_clk_ni(resetn)
    );
    
    initial begin 
        uvm_config_db#(virtual axi4_stream_master)::set(null, "uvm_test_top", "axi4_stream_master", if_i);
        uvm_config_db#(virtual axi4_stream_slave)::set(null, "uvm_test_top", "axi4_stream_slave", if_o);
    end
    
    initial begin 
        run_test("test");
    end
    
endmodule