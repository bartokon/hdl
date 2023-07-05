`timescale 1ps/1ps
`default_nettype none

module tb_axi4_lite_master;
    parameter integer DATA_WIDTH = 32;
    parameter integer ADDRESS_WIDTH = 32;

    //Read port
    logic [ADDRESS_WIDTH - 1 : 0] s_axi_araddr;
    logic s_axi_arvalid;
    logic s_axi_arready;

    logic [DATA_WIDTH - 1 :0] s_axi_rdata;
    logic s_axi_rvalid;
    logic s_axi_rready;

    //Read port response
    logic [1 : 0] s_axi_rresp; //2bit

    //Write port
    logic [ADDRESS_WIDTH - 1 : 0] s_axi_awaddr;
    logic s_axi_awvalid;
    logic s_axi_awready;

    logic [DATA_WIDTH - 1 :0] s_axi_wdata;
    logic [(DATA_WIDTH / 8) - 1 :0] s_axi_wstrb; //Indicates what bytes of data are valid - 1 bit for each byte in write_data
    logic s_axi_wvalid;
    logic s_axi_wready;

    //Write port response
    logic [1 : 0] s_axi_bresp; //2bit
    logic s_axi_bvalid;
    logic s_axi_bready;

    //Clock and reset
    logic aclk;
    logic aresetn;

    //Misc ports
    logic error_led;
    logic done_led;
    logic [31:0] GPIO_0_tri_o;

    axi4_lite_master_with_lut #(
        .DATA_WIDTH(32),
        .ADDRESS_WIDTH(32)
    ) u0_axi4_lite_master_with_lut (
        //Read port
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rdata(s_axi_rdata),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),

        //Read port response
        .s_axi_rresp(s_axi_rresp), //2bit

        //Write port
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb), //Indicates what bytes of data are valid - 1 bit for each byte in write_data
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),

        //Write port response
        .s_axi_bresp(s_axi_bresp), //2bit
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),

        //Clock and reset
        .aclk(aclk),
        .aresetn(aresetn),

        //Misc ports
        .error_led(error_led),
        .done_led(done_led)
    );

    gpio_bd gpio_bd_i (
        .GPIO_0_tri_o(GPIO_0_tri_o),
        .S_AXI_0_araddr(s_axi_araddr),
        .S_AXI_0_arready(s_axi_arready),
        .S_AXI_0_arvalid(s_axi_arvalid),
        .S_AXI_0_awaddr(s_axi_awaddr),
        .S_AXI_0_awready(s_axi_awready),
        .S_AXI_0_awvalid(s_axi_awvalid),
        .S_AXI_0_bready(s_axi_bready),
        .S_AXI_0_bresp(s_axi_bresp),
        .S_AXI_0_bvalid(s_axi_bvalid),
        .S_AXI_0_rdata(s_axi_rdata),
        .S_AXI_0_rready(s_axi_rready),
        .S_AXI_0_rresp(s_axi_rresp),
        .S_AXI_0_rvalid(s_axi_rvalid),
        .S_AXI_0_wdata(s_axi_wdata),
        .S_AXI_0_wready(s_axi_wready),
        .S_AXI_0_wstrb(s_axi_wstrb),
        .S_AXI_0_wvalid(s_axi_wvalid),
        .s_axi_aclk_0(aclk),
        .s_axi_aresetn_0(aresetn)
    );

always #10 aclk = !aclk;

initial begin
    aclk = 0;
    aresetn = 0;

    #300 aresetn = !aresetn;
    #5000
        $finish("Simulation finished!");
end
initial begin
    $monitor("GPIO STATE: %h", GPIO_0_tri_o);
    $monitor("done_led = %b", done_led);
end

endmodule