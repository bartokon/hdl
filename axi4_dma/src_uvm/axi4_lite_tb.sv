module axi4_lite_tb;
    import uvm_pkg::*;
    import axi4_lite_package::*;
    
    bit aclk = 0;
    bit arstn = 0;
    
    parameter cycle = 10;
    always #(cycle / 2) aclk = ~aclk;
    initial begin 
        #(cycle * 5) arstn = ~arstn;
    end
    
    axi4_lite_if u0_axi4_lite_if (
        .aclk(aclk),
        .arstn(arstn)
    );

    axi4_lite #(
        .DEPTH(256),
        .DATA_SIZE(32)
    )  u0_axi4_lite_dut (
        u0_axi4_lite_if.slave
    );

    initial begin
        uvm_config_db#(virtual axi4_lite_if)::set(null, "", "dut_vif", u0_axi4_lite_if);
    end

    initial begin
        run_test("random_write_test");
    end
    

endmodule