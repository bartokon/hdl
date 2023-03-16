//`timescale 1ns / 1ps
//`default_nettype none

module axi4_m_write_manager #(
    parameter ADDRESS_SIZE = 32,
    parameter DATA_SIZE = 32
) (
    //Write Address
    output logic [1:0] m_axi_awburst,
    output logic [ADDRESS_SIZE-1:0] m_axi_awaddr,
    output logic [7:0] m_axi_awlen,
    output logic [2:0] m_axi_awsize,
    input logic m_axi_awready,
    output logic m_axi_awvalid,

    //Write Data
    output logic [DATA_SIZE-1:0] m_axi_wdata,
    output logic [(DATA_SIZE/8)-1:0] m_axi_wstrb,
    output logic m_axi_wlast,
    input logic m_axi_wready,
    output logic m_axi_wvalid,

    //Write response
    input logic [1:0] m_axi_bresp,
    output logic m_axi_bready,
    input logic m_axi_bvalid,

    //Misc
    input logic aclk,
    input logic aresetn
);

    localparam ADDRESS = 'h0;
    localparam LEN = 'h00;
    localparam SIZE = 'b010;
    localparam BURST = 'h00;

    typedef enum {
        StReset,
        StWriteAddress,
        StWriteData,
        StReadResponse
    } state_e;
    state_e state_d, state_q;

    always_ff @(posedge aclk) begin
        if (aresetn == 0) begin
            state_d <= StReset;
        end else begin
            state_d <= state_q;
        end
    end

    always_comb begin
        state_q = state_d;
        case (state_q)
            StReset: begin
                state_q = StWriteAddress;
            end
            StWriteAddress: begin
                if (m_axi_awready && m_axi_awvalid) begin
                    state_q = StWriteData;
                end
            end
            StWriteData: begin
                if (m_axi_wready && m_axi_wvalid) begin
                    state_q = StReadResponse;
                end
            end
            StReadResponse: begin
                if (m_axi_bready && m_axi_bvalid) begin
                    state_q = StWriteAddress;
                end
            end
            default: ;
        endcase
    end

    logic [1:0] m_axi_awburst_q;
    logic [ADDRESS_SIZE-1:0] m_axi_awaddr_q;
    logic [7:0] m_axi_awlen_q;
    logic [2:0] m_axi_awsize_q;
    logic m_axi_awvalid_q;

    logic [DATA_SIZE-1:0] m_axi_wdata_q;
    logic [(DATA_SIZE/8)-1:0] m_axi_wstrb_q;
    logic m_axi_wlast_q;
    logic m_axi_wvalid_q;

    //logic [1:0] m_axi_bresp_q;
    logic m_axi_bready_q;

    always_ff @(posedge aclk) begin
        if (aresetn == 0) begin
            m_axi_awburst <= 0;
            m_axi_awaddr <= 0;
            m_axi_awlen <= 0;
            m_axi_awsize <= 0;
            m_axi_awvalid <= 0;
            m_axi_wdata <= 0;
            m_axi_wstrb <= 0;
            m_axi_wlast <= 0;
            m_axi_wvalid <= 0;
            m_axi_bready <= 0;
        end else begin
            m_axi_awburst <= m_axi_awburst_q;
            m_axi_awaddr <= m_axi_awaddr_q;
            m_axi_awlen <= m_axi_awlen_q;
            m_axi_awsize <= m_axi_awsize_q;
            m_axi_awvalid <= m_axi_awvalid_q;
            m_axi_wdata <= m_axi_wdata_q;
            m_axi_wstrb <= m_axi_wstrb_q;
            m_axi_wlast <= m_axi_wlast_q;
            m_axi_wvalid <= m_axi_wvalid_q;
            m_axi_bready <= m_axi_bready_q;
        end
    end

    always_comb begin
        m_axi_awburst_q = 0;
        m_axi_awaddr_q = 0;
        m_axi_awlen_q = 0;
        m_axi_awsize_q = 0;
        m_axi_awvalid_q = 0;
        m_axi_wdata_q = 0;
        m_axi_wstrb_q = 0;
        m_axi_wlast_q = 0;
        m_axi_wvalid_q = 0;
        m_axi_bready_q = 0;
        case (state_q)
            StWriteAddress: begin
                m_axi_awburst_q = BURST;
                m_axi_awaddr_q = ADDRESS;
                m_axi_awlen_q = LEN;
                m_axi_awsize_q = SIZE;
                m_axi_awvalid_q = !(m_axi_awready && m_axi_awvalid);
            end
            StWriteData: begin
                m_axi_wdata_q = 32'hFFFF_FFFF;
                m_axi_wstrb_q = 4'b1111;
                m_axi_wlast_q = 1;
                m_axi_wvalid_q = 1;
            end
            StReadResponse: begin
                m_axi_bready_q = 1;
            end
            default: ;
        endcase
    end

endmodule
