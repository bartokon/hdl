`timescale 1ns/10ps

import axi_vip_pkg::*;
import design_1_axi_vip_0_0_pkg::*;

module tb_axi4_lite_write;

    logic aclk = 0;
    logic aresetn = 0;
    logic [31:0] addr = 0;
    logic [31:0] base_addr = 0;
    logic [1:0] resp = 0;
    logic [31:0] data = 0;
    
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
        #10ns
        // Release the reset
        aresetn = 1;
    end

    //Main test
    initial begin
        //Setup
        design_1_axi_vip_0_0_mst_t master_agent;
        master_agent = new("master vip agent", DUT.axi_vip_0.inst.IF);
        master_agent.set_agent_tag("Master VIP");
        master_agent.set_verbosity(0);
        master_agent.start_master();

        //Wait for reset release
        wait (aresetn == 1'b1);
   
        #10ns
        fork
            for (int i = 0, addr = 0, data = 0; i < DUT.axi4_lite_wrapper_v2_0.inst.REGISTERS + 1; ++i, ++data, addr = addr + 4) begin 
                master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
            end
        join  
        fork
            for (int i = 0, addr = 0, data = 0; i < DUT.axi4_lite_wrapper_v2_0.inst.REGISTERS + 1; ++i, addr = addr + 4) begin
                master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
                $display("Data is %h", data);
            end
        join
        #10ns $finish("Simulation Finished");
    end

endmodule
