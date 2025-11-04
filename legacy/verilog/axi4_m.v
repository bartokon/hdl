//`default_nettype none

module axi4_m #(
    parameter integer ADDRESS_SIZE = 32,
    parameter integer DATA_SIZE = 32
) (
    //Read Address
    output wire [ADDRESS_SIZE - 1 : 0] m_axi_araddr,
    output wire [7:0] m_axi_arlen,
    output wire [2:0] m_axi_arsize, //Bytes in burst
    output wire [1:0] m_axi_arburst, //Busrt type 0b01 -> incr
    output wire m_axi_arvalid,
    input wire m_axi_arready,

    //Read Data
    input wire [DATA_SIZE - 1 :0] m_axi_rdata,
    input wire [1:0] m_axi_rresp,
    input wire m_axi_rlast,
    input wire m_axi_rvalid,
    output wire m_axi_rready,

    //Write Address
    output wire [1:0] m_axi_awburst,
    output wire [ADDRESS_SIZE - 1 : 0] m_axi_awaddr,
    output wire [7:0] m_axi_awlen,
    output wire [2:0] m_axi_awsize,
    input wire m_axi_awready,
    output wire m_axi_awvalid,
    
    //Write Data
    output wire [DATA_SIZE - 1 :0] m_axi_wdata,
    output wire [(DATA_SIZE/8)-1:0] m_axi_wstrb,
    output wire m_axi_wlast,
    input wire m_axi_wready,
    output wire m_axi_wvalid,
    
    //Write response
    input wire [1:0] m_axi_bresp,
    output wire m_axi_bready,
    input wire m_axi_bvalid,
    
    //Misc
    input wire aclk,
    input wire aresetn
);

    axi4_m_read_manager #(
        .ADDRESS_SIZE(ADDRESS_SIZE),
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi4_m_read_manager (
        //Read Address
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize), //Bytes in burst
        .m_axi_arburst(m_axi_arburst), //Burst type 0b01 -> incr
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),

        //Read Data
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),

        //Misc
        .aclk(aclk),
        .aresetn(aresetn)
    );

    axi4_m_write_manager #(
        .ADDRESS_SIZE(ADDRESS_SIZE),
        .DATA_SIZE(DATA_SIZE)
    ) u0_axi4_m_write_manager (
        //Write Address
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awready(m_axi_awready),
        .m_axi_awvalid(m_axi_awvalid),
        
        //Write Data
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wready(m_axi_wready),
        .m_axi_wvalid(m_axi_wvalid),
        
        //Write response
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bready(m_axi_bready),
        .m_axi_bvalid(m_axi_bvalid),
        
        //Misc
        .aclk(aclk),
        .aresetn(aresetn)
    );
    
endmodule