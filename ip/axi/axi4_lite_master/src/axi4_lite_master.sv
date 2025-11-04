`timescale 1ps/1ps
`default_nettype wire
module axi4_lite_master #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDRESS_WIDTH = 32
) (
    //Read port
    output logic [ADDRESS_WIDTH - 1 : 0] s_axi_araddr,
    output logic s_axi_arvalid,
    input logic s_axi_arready,

    input logic [DATA_WIDTH - 1 :0] s_axi_rdata,
    input logic s_axi_rvalid,
    output logic s_axi_rready,

    //Read port response
    input logic [1 : 0] s_axi_rresp, //2bit

    //Write port
    output logic [ADDRESS_WIDTH - 1 : 0] s_axi_awaddr,
    output logic s_axi_awvalid,
    input logic s_axi_awready,

    output logic [DATA_WIDTH - 1 :0] s_axi_wdata,
    output logic [(DATA_WIDTH / 8) - 1 :0] s_axi_wstrb, //Indicates what bytes of data are valid - 1 bit for each byte in write_data
    output logic s_axi_wvalid,
    input logic s_axi_wready,

    //Write port response
    input logic [1 : 0] s_axi_bresp, //2bit
    input logic s_axi_bvalid,
    output logic s_axi_bready,

    //Clock and reset
    input logic aclk,
    input logic aresetn,

    //Fetch data from external look-up-table
    input logic [DATA_WIDTH - 1 : 0] memory_data,
    input logic [(DATA_WIDTH / 8) - 1 : 0] memory_strobe,
    input logic [ADDRESS_WIDTH - 1 : 0] memory_address,
    input logic memory_data_valid, //If not valid, then index out of scope -> go to done state
    output logic [ADDRESS_WIDTH - 1 : 0] memory_index, //This couble less in width

    //Misc ports
    output logic error_led,
    output logic done_led
);

//assert property (DATA_WIDTH == 32) else $error("Only data width = 32 is supported");
//assert (ADDRESS_WIDTH == 32) else $error("Only address width = 32 is supported");

logic [ADDRESS_WIDTH - 1 : 0 ] s_axi_awaddr_d, s_axi_awaddr_q;
logic s_axi_awvalid_d, s_axi_awvalid_q;
logic [DATA_WIDTH - 1 : 0] s_axi_wdata_d, s_axi_wdata_q;
logic [(DATA_WIDTH / 8) - 1 : 0] s_axi_wstrb_d, s_axi_wstrb_q;
logic s_axi_wvalid_d, s_axi_wvalid_q;
logic s_axi_bready_d, s_axi_bready_q;
logic [ADDRESS_WIDTH : 0] memory_index_d, memory_index_q;
logic error_led_d, error_led_q;
logic done_led_d, done_led_q;

typedef enum {
    StReset, StGetNewData, StWrite, StCheckResponse, StDone
} axi4_lite_write_state_e;

axi4_lite_write_state_e axi4_lite_write_state_d, axi4_lite_write_state_q;
logic write_address_done_d, write_address_done_q;
logic write_data_done_d, write_data_done_q;

always_comb begin
    axi4_lite_write_state_d = axi4_lite_write_state_q;
    s_axi_awaddr_d = s_axi_awaddr_q;
    s_axi_awvalid_d = s_axi_awvalid_q;
    s_axi_wdata_d = s_axi_wdata_q;
    s_axi_wstrb_d = s_axi_wstrb_q;
    s_axi_wvalid_d = s_axi_wvalid_q;
    s_axi_bready_d = s_axi_bready_q;
    memory_index_d = memory_index_q;
    error_led_d = error_led_q;
    done_led_d = done_led_q;
    write_address_done_d = write_address_done_q;
    write_data_done_d = write_data_done_q;
    unique case (axi4_lite_write_state_q)
        StReset: begin
            axi4_lite_write_state_d = StGetNewData;
            s_axi_awaddr_d = 0;
            s_axi_awvalid_d = 0;
            s_axi_wdata_d = 0;
            s_axi_wstrb_d = 0;
            s_axi_wvalid_d = 0;
            s_axi_bready_d = 0;
            memory_index_d = 0;
            error_led_d = 0;
            done_led_d = 0;
            write_address_done_d = 0;
            write_data_done_d = 0;
        end
        StGetNewData: begin
            if (memory_data_valid) begin
                memory_index_d = memory_index_q + 1;
                s_axi_awaddr_d = memory_address;
                s_axi_awvalid_d = 1;
                s_axi_wdata_d = memory_data;
                s_axi_wstrb_d = memory_strobe;
                s_axi_wvalid_d = 1;
                axi4_lite_write_state_d = StWrite;
            end else begin
                //Why are you using this IP if you don't have valid data?
                //This should be illegal :)
                error_led_d = 1;
                axi4_lite_write_state_d = StDone;
            end
        end
        StWrite: begin
            if (s_axi_awready && s_axi_awvalid_d) begin
                s_axi_awvalid_d = 0;
                write_address_done_d = 1;
            end
            if (s_axi_wready && s_axi_wvalid_d) begin
                s_axi_wvalid_d = 0;
                write_data_done_d = 1;
            end
            if (write_address_done_d && write_data_done_d) begin
                s_axi_bready_d = 1;
                write_address_done_d = 0;
                write_data_done_d = 0;
                axi4_lite_write_state_d = StCheckResponse;
            end
        end
        StCheckResponse: begin
            if (s_axi_bready_d && s_axi_bvalid) begin
                s_axi_bready_d = 0;
                axi4_lite_write_state_d = memory_data_valid ? StGetNewData : StDone;
                error_led_d = s_axi_bresp != 2'b00;
            end
        end
        StDone: begin
            done_led_d = 1;
        end
        default: begin
            error_led_d = 1;
        end
    endcase
end

always_ff @(posedge aclk) begin
    axi4_lite_write_state_q <= aresetn ? axi4_lite_write_state_d : StReset;
    s_axi_awaddr_q <= s_axi_awaddr_d;
    s_axi_awvalid_q <= s_axi_awvalid_d;
    s_axi_wdata_q <= s_axi_wdata_d;
    s_axi_wstrb_q <= s_axi_wstrb_d;
    s_axi_wvalid_q <= s_axi_wvalid_d;
    s_axi_bready_q <= s_axi_bready_d;
    memory_index_q <= memory_index_d;
    error_led_q <= error_led_d;
    done_led_q <= done_led_d;
    write_address_done_q <= write_address_done_d;
    write_data_done_q <= write_data_done_d;
end

assign s_axi_awaddr = s_axi_awaddr_q;
assign s_axi_awvalid = s_axi_awvalid_q;
assign s_axi_wdata = s_axi_wdata_q;
assign s_axi_wstrb = s_axi_wstrb_q;
assign s_axi_wvalid = s_axi_wvalid_q;
assign s_axi_bready = s_axi_bready_q;
assign memory_index = memory_index_q;
assign error_led = error_led_q;
assign done_led = done_led_q;

endmodule