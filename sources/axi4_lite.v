`default_nettype none
//https://www.youtube.com/watch?v=okiTzvihHRA

// Response (Not 0 or 1 is an error):
// 00 - ok
// 01 - EXOK
// 10 - SLVERR
// 11 - DECERR
//AXI 4 wip tets

module axi4_lite
#(
    parameter integer ADDRESS_SIZE = 32,
    parameter integer DATA_SIZE = 32
)
(
    //Read port
    input wire [ADDRESS_SIZE - 1 : 0] s_axi_araddr,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    
    output wire [DATA_SIZE - 1 :0] s_axi_rdata,
    output wire s_axi_rvalid,
    input wire s_axi_rready,

    //Read port response
    output wire [1 : 0] s_axi_rresp, //2bit

    //Write port
    input wire [ADDRESS_SIZE - 1 : 0] s_axi_awaddr,
    input wire s_axi_awvalid,
    output wire s_axi_awready,

    input wire [DATA_SIZE - 1 :0] s_axi_wdata,
    input wire [(DATA_SIZE / 8) - 1 :0] s_axi_wstrb, //Indicates what bytes of data are valid - 1 bit for each byte in write_data
    input wire s_axi_wvalid,
    output wire s_axi_wready,

    //Write port response
    output wire [1 : 0] s_axi_bresp, //2bit
    output wire s_axi_bvalid,
    input wire s_axi_bready,

    //Misc
    input wire aclk,
    input wire aresetn 
);

    reg [DATA_SIZE - 1 :0] register_0;
    wire [DATA_SIZE - 1 :0] register_data_0;
    wire register_write_enable_0;
    always @(posedge aclk) begin 
        if (aresetn == 0) begin 
            register_0 <= 0;
        end else begin 
            if (register_write_enable_0 == 1) begin 
                register_0 <= register_data_0;
            end
        end
    end
    
    axi_lite_read_manager #(
        .ADDRESS_SIZE(4),
        .DATA_SIZE(32)
    ) u0_axi_read_manager (
        .read_address(s_axi_araddr[3:0]),
        .read_address_valid(s_axi_arvalid),
        .read_address_ready(s_axi_arready),
        
        .read_data(s_axi_rdata),
        .read_data_valid(s_axi_rvalid),
        .read_data_ready(s_axi_rready),
        
        .read_data_response(s_axi_rresp),
        
        .aclk(aclk),
        .aresetn(aresetn),
        
        .register_data_0(register_0)
    );

    axi_lite_write_manager #(
        .ADDRESS_SIZE(4),
        .DATA_SIZE(32)
    ) u0_axi_write_manager (
        .write_address(s_axi_awaddr[3:0]),
        .write_address_valid(s_axi_awvalid),
        .write_address_ready(s_axi_awready),
    
        .write_data(s_axi_wdata),
        .write_data_strobe(s_axi_wstrb), //Indicates what bytes of data are valid - 1 bit for each byte in write_data
        .write_data_valid(s_axi_wvalid),
        .write_data_ready(s_axi_wready),
    
        //Write port response
        .write_response(s_axi_bresp), //2bit
        .write_response_valid(s_axi_bvalid),
        .write_response_ready(s_axi_bready),
        
        .aclk(aclk),
        .aresetn(aresetn),
        
        .register_data_0(register_data_0),
        .register_write_enable_0(register_write_enable_0)
    );

    
endmodule