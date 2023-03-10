`default_nettype none

module axi4_lite #(
    parameter integer ADDRESS_SIZE = 4,
    parameter integer DATA_SIZE = 32
) (
    //Read port
    input wire [ADDRESS_SIZE-1:0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,

    output wire [DATA_SIZE-1:0] s_axi_rdata,
    output wire s_axi_rvalid,
    input wire s_axi_rready,

    //Read port response
    output wire [1:0] s_axi_rresp, //2bit

    //Write port
    input wire [ADDRESS_SIZE-1:0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,

    input wire [DATA_SIZE-1:0] s_axi_wdata,
    input wire [(DATA_SIZE/8)-1:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,

    //Write port response
    output wire [1:0] s_axi_bresp, //2bit
    output wire s_axi_bvalid,
    input wire s_axi_bready,

    //Misc
    input wire aclk,
    input wire aresetn
);
    wire [ADDRESS_SIZE-1:0]s_axi_araddr_q;
    wire s_axi_arvalid_q;
    wire s_axi_arready_q;

    skid_buffer #(
        .DATA_SIZE(ADDRESS_SIZE)
    ) u0_ar_skid_buffer (
        // Input ports
        .data_i(s_axi_araddr),
        .data_valid_i(s_axi_arvalid),
        .data_ready_o(s_axi_arready),
        // Output ports
        .data_o(s_axi_araddr_q),
        .data_valid_o(s_axi_arvalid_q),
        .data_ready_i(s_axi_arready_q),
        // Misc
        .clk_i(aclk),
        .rst_clk_ni(aresetn)
    );
    
    wire [DATA_SIZE-1:0] s_axi_rdata_q;
    wire [1:0] s_axi_rresp_q;
    wire s_axi_rvalid_q;
    wire s_axi_rready_q;
    
    skid_buffer #(
        .DATA_SIZE(DATA_SIZE+2)
    ) u0_rd_skid_buffer (
        // Input ports
        .data_i({s_axi_rdata_q, s_axi_rresp_q}),
        .data_valid_i(s_axi_rvalid_q),
        .data_ready_o(s_axi_rready_q),
        // Output ports
        .data_o({s_axi_rdata, s_axi_rresp}),
        .data_valid_o(s_axi_rvalid),
        .data_ready_i(s_axi_rready),
        // Misc
        .clk_i(aclk),
        .rst_clk_ni(aresetn)
    );
    
    axi4_lite_v2 #(
        .ADDRESS_SIZE(ADDRESS_SIZE),
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi_lite_v2 (
        .s_axi_araddr(s_axi_araddr_q),
        .s_axi_arvalid(s_axi_arvalid_q),
        .s_axi_arready(s_axi_arready_q),

        .s_axi_rdata(s_axi_rdata_q),
        .s_axi_rvalid(s_axi_rvalid_q),
        .s_axi_rready(s_axi_rready_q),
        .s_axi_rresp(s_axi_rresp_q),
        
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        .aclk(aclk),
        .aresetn(aresetn)
    );


endmodule
