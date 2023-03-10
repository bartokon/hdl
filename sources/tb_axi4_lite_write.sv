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

        // 0 is prot (Not used)
        #10ns
        fork
            addr = 0;
            data = 32'hdeadbeef;
            master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
            addr = 4;
            data = 32'h00000001;
            master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
            addr = 8;
            data = 32'h00000002;
            master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
        
    //      #50ns
            addr = 0;
            master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
            $display("Data is %h", data);
            addr = 4;
            master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
            $display("Data is %h", data);
            addr = 8;
            master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
            $display("Data is %h", data);
        join
        #20ns
        $finish("Simulation Finished");
    end

endmodule
