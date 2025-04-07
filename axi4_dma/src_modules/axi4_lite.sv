//`default_nettype none

module axi4_lite #(
    parameter int unsigned DEPTH = 8,
    parameter int unsigned DATA_SIZE = 32
) (
    axi4_lite_if intf
);

    logic [$clog2(DEPTH) - 1 : 0] addra;
    logic [DATA_SIZE - 1 : 0] dina;
    logic [DATA_SIZE / 8 - 1 : 0] wea;
    logic [$clog2(DEPTH) - 1 : 0] addrb;
    logic [DATA_SIZE - 1 : 0] doutb;

    memory #(
        .DEPTH(DEPTH),
        .DATA_SIZE(DATA_SIZE)
    ) u0_mem (
        .addra(addra),
        .dina(dina),
        .wea(wea),
        .addrb(addrb),
        .doutb(doutb),
        .clk(intf.aclk),
        .rst(~intf.arstn)
    );

    axi4_lite_read #(
        .DEPTH(DEPTH),
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi_read (
        .read_address_i(intf.araddr),
        .read_address_valid_i(intf.arvalid),
        .read_address_ready_o(intf.arready),

        .read_data_response_o(intf.rresp),
        .read_data_o(intf.rdata),
        .read_data_valid_o(intf.rvalid),
        .read_data_ready_i(intf.rready),

        .clk_i(intf.aclk),
        .rst_clk_ni(intf.arstn),

        .register_data_i(doutb),
        .register_address_o(addrb)
    );

    axi4_lite_write #(
        .DEPTH(DEPTH),
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi_write (
        .write_address_i(intf.awaddr[0+:($clog2(DEPTH))]),
        .write_address_valid_i(intf.awvalid),
        .write_address_ready_o(intf.awready),

        .write_data_i(intf.wdata),
        .write_data_strb_i(intf.wstrb),
        .write_data_valid_i(intf.wvalid),
        .write_data_ready_o(intf.wready),

        .write_response_o(intf.bresp),
        .write_response_valid_o(intf.bvalid),
        .write_response_ready_i(intf.bready),

        .clk_i(intf.aclk),
        .rst_clk_ni(intf.arstn),

        .register_data_o(dina),
        .register_address_o(addra),
        .enable_register_data_o(wea)
    );

endmodule

//module axi4_lite_top(
    //input logic aclk,
    //input logic arstn
//);
    //axi4_lite_if #(
        //.C_AXI_DATA_WIDTH(32),
        //.C_AXI_ADDR_WIDTH(2)
    //) ss(
        //.aclk(aclk),
        //.arstn(arstn)
    //);
    //axi4_lite u0_dut(
        //.intf(ss.master),
        //.aclk(aclk),
        //.arstn(arstn)
    //);
//endmodule