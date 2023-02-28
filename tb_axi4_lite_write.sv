`timescale 1ns/10ps

import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;

module tb_axi4_lite_write;

    bit aclk = 0;
    bit aresetn = 0;
    bit [31:0] addr = 0;
    bit [31:0] base_addr = 0;
    bit [1:0] resp = 0;
    bit [31:0] data = 0;
    
    design_1_wrapper DUT
    (
        .aclk (aclk),
        .aresetn(aresetn)
    );
    
    //CLK and reset
    always #10ns aclk = ~aclk;
    initial begin
        //Assert the reset
        aresetn = 0;
        #340ns
        // Release the reset
        aresetn = 1;
    end
    
    //Main test
    initial begin
        //Setup
        design_1_axi_vip_0_0_mst_t master_agent;
        master_agent = new("master vip agent", DUT.design_1_i.axi_vip_0.inst.IF);
        master_agent.set_agent_tag("Master VIP");
        master_agent.set_verbosity(400);
        master_agent.start_master();
        
        //Wait for reset release
        wait (aresetn == 1'b1);
        
        // 0 is prot (Not used)
        #500ns
        addr = 0;
        data = 32'hdeadbeef;
        master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
        addr = 1;
        data = 32'h0000beef;
        master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);  
        addr = 2;
        data = 32'hdead0000;
        master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
        #500ns
        addr = 0;
        master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
        $display("Data is %h", data);
        #500ns
        addr = 1;
        master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
        $display("Data is %h", data);
        addr = 2;
        master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
        $display("Data is %h", data);
        addr = 3;
        master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
        $display("Data is %h", data);

        #100ns
        $finish("Simulation Finished");
    end
    
endmodule
