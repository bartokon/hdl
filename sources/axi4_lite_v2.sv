//`default_nettype none

module axi4_lite_v2 #(
    parameter int unsigned ADDRESS_SIZE = 32,
    parameter int unsigned DATA_SIZE = 32,
    parameter int unsigned REGISTERS = 1
) (
    //Read port
    input  logic [ADDRESS_SIZE-1:0] s_axi_araddr,
    input  logic s_axi_arvalid,
    output logic s_axi_arready,

    output logic [DATA_SIZE-1:0] s_axi_rdata,
    output logic s_axi_rvalid,
    input  logic s_axi_rready,

    //Read port response
    output logic [1:0] s_axi_rresp, //2bit

    //Write port
    input  logic [ADDRESS_SIZE-1:0] s_axi_awaddr,
    input  logic s_axi_awvalid,
    output logic s_axi_awready,

    input  logic [DATA_SIZE-1:0] s_axi_wdata,
    input  logic [(DATA_SIZE/8)-1:0] s_axi_wstrb, //Indicates what bytes of data are valid - 1 bit for each byte in write_data
    input  logic s_axi_wvalid,
    output logic s_axi_wready,

    //Write port response
    output logic [1:0] s_axi_bresp, //2bit
    output logic s_axi_bvalid,
    input  logic s_axi_bready,

    //Misc
    input  logic aclk,
    input  logic aresetn
);
    logic [DATA_SIZE-1:0] registers[REGISTERS];
    logic [DATA_SIZE-1:0] registers_data;
    logic [ADDRESS_SIZE-1:0] registers_address_write;
    logic registers_write_enable;
    
    //TODO: Redesign to bram
    always_ff @(posedge aclk) begin
        if (registers_write_enable) begin
            registers[registers_address_write] <= registers_data;
        end
    end
    
    logic [ADDRESS_SIZE-1:0] register_address_read;
    logic [DATA_SIZE-1:0] registers_q;
    assign registers_q = registers[register_address_read];
    
    axi4_lite_read_manager #(
        .ADDRESS_SIZE(ADDRESS_SIZE),
        .DATA_SIZE(DATA_SIZE),
        .REGISTERS(REGISTERS)
    ) u0_axi_read_manager (
        .read_address_i(s_axi_araddr),
        .read_address_valid_i(s_axi_arvalid),
        .read_address_ready_o(s_axi_arready),

        .read_data_response_o(s_axi_rresp),
        .read_data_o(s_axi_rdata),
        .read_data_valid_o(s_axi_rvalid),
        .read_data_ready_i(s_axi_rready),

        .clk_i(aclk),
        .rst_clk_ni(aresetn),

        .register_data_i(registers_q),
        .register_address_o(register_address_read)
    );

    axi4_lite_write_manager #(
        .ADDRESS_SIZE(ADDRESS_SIZE),
        .DATA_SIZE(DATA_SIZE),
        .REGISTERS(REGISTERS)
    ) u0_axi_write_manager (
        .write_address_i(s_axi_awaddr),
        .write_address_valid_i(s_axi_awvalid),
        .write_address_ready_o(s_axi_awready),

        .write_data_i(s_axi_wdata),
        .write_data_strobe_i(s_axi_wstrb), //Indicates what bytes of data are valid - 1 bit for each byte in write_data
        .write_data_valid_i(s_axi_wvalid),
        .write_data_ready_o(s_axi_wready),

        //Write port response
        .write_response_o(s_axi_bresp), //2bit
        .write_response_valid_o(s_axi_bvalid),
        .write_response_ready_i(s_axi_bready),

        .clk_i(aclk),
        .rst_clk_i(aresetn),

        .register_data_o(registers_data),
        .register_address_o(registers_address_write),
        .enable_register_data_o(registers_write_enable)
    );


endmodule