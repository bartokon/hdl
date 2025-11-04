`timescale 1ns/10ps

import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;

module tb_axi4_m;

    logic aclk = 0;
    logic aresetn = 0;
    logic [31:0] addr = 0;
    logic [31:0] base_addr = 0;
    logic [1:0] resp = 0;
    logic [31:0] data = 0;
    logic [31:0] data_in[$];
    logic [31:0] addr_in[$];
    logic [31:0] data_out[$];
    logic [31:0] addr_out[$];
    
    design_1 DUT
    (
        .aclk (aclk),
        .aresetn(aresetn)
    );

    //CLK and reset
    always #2ns aclk = ~aclk;
    initial begin
        //Assert the reset
        aresetn = 0;
        #50ns
        // Release the reset
        aresetn = 1;
    end

    //Main test
    initial begin
        //Setup
        design_1_axi_vip_0_0_slv_mem_t slave_agent;
        slave_agent = new("slave vip agent", DUT.axi_vip_0.inst.IF);
        slave_agent.vif_proxy.set_dummy_drive_type(XIL_AXI_VIF_DRIVE_NONE);
        slave_agent.set_agent_tag("Slave VIP");
        slave_agent.set_verbosity(400);
        slave_agent.start_slave(); 

        //Wait for reset release
        wait (aresetn == 1'b1);
   
        #1000ns $finish("Simulation Finished");
    end

endmodule
