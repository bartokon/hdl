`timescale 1ps/1ps
`default_nettype wire

module axi4_lite_master_with_lut #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDRESS_WIDTH = 32
) (
    //Read port
    output wire [ADDRESS_WIDTH - 1 : 0] s_axi_araddr,
    output wire s_axi_arvalid,
    input wire s_axi_arready,

    input wire [DATA_WIDTH - 1 :0] s_axi_rdata,
    input wire s_axi_rvalid,
    output wire s_axi_rready,

    //Read port response
    input wire [1 : 0] s_axi_rresp, //2bit

    //Write port
    output wire [ADDRESS_WIDTH - 1 : 0] s_axi_awaddr,
    output wire s_axi_awvalid,
    input wire s_axi_awready,

    output wire [DATA_WIDTH - 1 :0] s_axi_wdata,
    output wire [(DATA_WIDTH / 8) - 1 :0] s_axi_wstrb, //Indicates what bytes of data are valid - 1 bit for each byte in write_data
    output wire s_axi_wvalid,
    input wire s_axi_wready,

    //Write port response
    input wire [1 : 0] s_axi_bresp, //2bit
    input wire s_axi_bvalid,
    output wire s_axi_bready,

    //Clock and reset
    input wire aclk,
    input wire aresetn,

    //Misc ports
    output wire error_led,
    output wire done_led
);

wire [DATA_WIDTH - 1 : 0] memory_data;
wire [(DATA_WIDTH / 8 ) - 1 : 0] memory_strobe;
wire [ADDRESS_WIDTH - 1 : 0] memory_address;
wire memory_data_valid;
wire [ADDRESS_WIDTH - 1 : 0 ] memory_index;

axi4_lite_master  #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
) u0_axi4_lite_master (
    //Read port
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_arready(s_axi_arready),

    .s_axi_rdata(s_axi_rdata),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rready(s_axi_rready),

    //Read port response
    .s_axi_rresp(s_axi_rresp),//2bit

    //Write port
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awready(s_axi_awready),

    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),//Indicates what bytes of data are valid - 1 bit for each byte in write_data
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wready(s_axi_wready),

    //Write port response
    .s_axi_bresp(s_axi_bresp),//2bit
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bready(s_axi_bready),

    //Clock and reset
    .aclk(aclk),
    .aresetn(aresetn),

    //Fetch data from external look-up-table
    .memory_data(memory_data),
    .memory_strobe(memory_strobe),
    .memory_address(memory_address),
    .memory_data_valid(memory_data_valid),//If not valid, then index out of scope -> go to done state
    .memory_index(memory_index),

    //Misc ports
    .error_led(error_led),
    .done_led(done_led)
);

axi4_lite_master_lut #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDRESS_WIDTH(ADDRESS_WIDTH)
) u0_lut (
    //IO
    .memory_data(memory_data),
    .memory_strobe(memory_strobe),
    .memory_address(memory_address),
    .memory_data_valid(memory_data_valid),
    .memory_index(memory_index),

    //Clock and reset
    .clk(aclk),
    .resetn(aresetn)
);


endmodule