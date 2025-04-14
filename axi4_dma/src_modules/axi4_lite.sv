//`default_nettype none

module axi4_lite #(
    parameter int unsigned DEPTH = 64,
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

module axi4_lite_vip #(
    parameter int unsigned DEPTH = 256,
    parameter int unsigned DATA_SIZE = 32
) (
    axi4_lite_if intf
);

    axi4_lite_if #(
        .C_AXI_ADDR_WIDTH($clog2(DEPTH)),
        .C_AXI_DATA_WIDTH(DATA_SIZE)
    ) internal_intf (
        .aclk(intf.aclk),
        .arstn(intf.arstn)
    );

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
    AXI4_LITE_VIP_0 u0_axi4_lite_vip (
        .aclk         (intf.aclk),     // input wire aclk
        .aresetn      (intf.arstn),    // input wire aresetn
        // AXI4-Lite Slave Interface
        .s_axi_awaddr (intf.awaddr),   // input wire [31 : 0] s_axi_awaddr
        .s_axi_awvalid(intf.awvalid),  // input wire s_axi_awvalid
        .s_axi_awready(intf.awready),  // output wire s_axi_awready
        .s_axi_wdata  (intf.wdata),    // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb  (intf.wstrb),    // input wire [3 : 0] s_axi_wstrb
        .s_axi_wvalid (intf.wvalid),   // input wire s_axi_wvalid
        .s_axi_wready (intf.wready),   // output wire s_axi_wready
        .s_axi_bresp  (intf.bresp),    // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid (intf.bvalid),   // output wire s_axi_bvalid
        .s_axi_bready (intf.bready),   // input wire s_axi_bready
        .s_axi_araddr (intf.araddr),   // input wire [31 : 0] s_axi_araddr
        .s_axi_arvalid(intf.arvalid),  // input wire s_axi_arvalid
        .s_axi_arready(intf.arready),  // output wire s_axi_arready
        .s_axi_rdata  (intf.rdata),    // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp  (intf.rresp),    // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid (intf.rvalid),   // output wire s_axi_rvalid
        .s_axi_rready (intf.rready),   // input wire s_axi_rready
        // AXI4-Lite Master Interface
        .m_axi_awaddr (internal_intf.awaddr),   // output wire [31 : 0] m_axi_awaddr
        .m_axi_awvalid(internal_intf.awvalid),  // output wire m_axi_awvalid
        .m_axi_awready(internal_intf.awready),  // input wire m_axi_awready
        .m_axi_wdata  (internal_intf.wdata),    // output wire [31 : 0] m_axi_wdata
        .m_axi_wstrb  (internal_intf.wstrb),    // output wire [3 : 0] m_axi_wstrb
        .m_axi_wvalid (internal_intf.wvalid),   // output wire m_axi_wvalid
        .m_axi_wready (internal_intf.wready),   // input wire m_axi_wready
        .m_axi_bresp  (internal_intf.bresp),    // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid (internal_intf.bvalid),   // input wire m_axi_bvalid
        .m_axi_bready (internal_intf.bready),   // output wire m_axi_bready
        .m_axi_araddr (internal_intf.araddr),   // output wire [31 : 0] m_axi_araddr
        .m_axi_arvalid(internal_intf.arvalid),  // output wire m_axi_arvalid
        .m_axi_arready(internal_intf.arready),  // input wire m_axi_arready
        .m_axi_rdata  (internal_intf.rdata),    // input wire [31 : 0] m_axi_rdata
        .m_axi_rresp  (internal_intf.rresp),    // input wire [1 : 0] m_axi_rresp
        .m_axi_rvalid (internal_intf.rvalid),   // input wire m_axi_rvalid
        .m_axi_rready (internal_intf.rready)    // output wire m_axi_rready
    );
// INST_TAG_END ------ End INSTANTIATION Template ---------

    axi4_lite #(
        .DEPTH(DEPTH),
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi4_lite(
        .intf(internal_intf.slave)
    );


endmodule