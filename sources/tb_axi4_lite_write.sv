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
        #100ns
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
        for (int i = 0, addr = 0, data = 0; i < DUT.axi4_lite_wrapper_v2_0.inst.REGISTERS + 0; ++i, ++data, addr = addr + 4) begin        
            master_agent.AXI4LITE_WRITE_BURST(base_addr + addr, 0, data, resp);
            data_in.push_back(data);
            addr_in.push_back(addr);
            wait(DUT.axi4_lite_wrapper_v2_0.s_axi_bvalid && DUT.axi4_lite_wrapper_v2_0.s_axi_bready);
            master_agent.AXI4LITE_READ_BURST(base_addr + addr, 0, data, resp);
            data_out.push_back(data);
            addr_out.push_back(addr);
            $display("Data is %h", data);
        end
        
        assert(data_out.size() == data_in.size());
        assert(addr_out.size() == addr_in.size());
        
        for (int i = 0; i < data_out.size(); ++i) begin
            int err = 0;
            err += data_out.pop_back() != data_in.pop_back();
            err += addr_out.pop_back() != addr_in.pop_back();
            if (err == 1) begin 
                $error("Data missmatch");
                $stop("on i: %d", i);
            end
        end
        #10ns $finish("Simulation Finished");
    end

endmodule
