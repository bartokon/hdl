//`timescale 1ns / 1ps
//`default_nettype none

module axi4_m_read_manager #(
    parameter ADDRESS_SIZE = 32,
    parameter DATA_SIZE = 32
) (
    //Read Address
    output logic [ADDRESS_SIZE - 1 : 0] m_axi_araddr,
    output logic [7:0] m_axi_arlen,
    output logic [2:0] m_axi_arsize, //Bytes in burst
    output logic [1:0] m_axi_arburst, //Busrt trype 0b01 -> incr
    output logic m_axi_arvalid,
    input logic m_axi_arready,

    //Read Data
    input  logic [DATA_SIZE - 1 :0] m_axi_rdata,
    input  logic [1:0] m_axi_rresp,
    input  logic m_axi_rlast,
    input logic m_axi_rvalid,
    output  logic m_axi_rready,

    //Some stream output nb
    output logic [DATA_SIZE - 1:0] debug_data,
    output logic debug_valid,
    output logic debug_last,

    //Misc
    input  logic aclk,
    input  logic aresetn
);

    localparam ADDRESS = 'h0;
    localparam LEN = 'h00;
    localparam SIZE = 3'b010;
    localparam BURST = 'h00;

    typedef enum {
        StReset,
        StWriteAddress,
        StReadData
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
                if(m_axi_arvalid && m_axi_arready) begin
                    state_q = StReadData;
                end
            end
            StReadData: begin
                if (m_axi_rlast && m_axi_rvalid && m_axi_rready) begin
                    state_q = StWriteAddress;
                end
            end
            default: ;
        endcase
    end


    logic [ADDRESS_SIZE - 1 : 0] m_axi_araddr_q;
    logic [7:0] m_axi_arlen_q;
    logic [2:0] m_axi_arsize_q;
    logic [1:0] m_axi_arburst_q;
    logic m_axi_arvalid_q;
    logic m_axi_rready_q;

    logic debug_data_q;
    logic debug_valid_q;
    logic debug_last_q;

    always_ff @(posedge aclk) begin
        if (aresetn == 0) begin
            m_axi_araddr  <= 0;
            m_axi_arlen   <= 0;
            m_axi_arsize  <= 0;
            m_axi_arburst <= 0;
            m_axi_arvalid <= 0;
        end else begin
            m_axi_araddr  <= m_axi_araddr_q;
            m_axi_arlen   <= m_axi_arlen_q;
            m_axi_arsize  <= m_axi_arsize_q;
            m_axi_arburst <= m_axi_arburst_q;
            m_axi_arvalid <= m_axi_arvalid_q;
            m_axi_rready  <= m_axi_rready_q;
            debug_valid   <= debug_valid_q;
            debug_last    <= debug_last_q;
            debug_data    <= debug_data_q;
        end
    end

    always_comb begin
        m_axi_araddr_q  = 0;
        m_axi_arlen_q   = 0;
        m_axi_arsize_q  = 0;
        m_axi_arburst_q = 0;
        m_axi_arvalid_q = 0;
        m_axi_rready_q  = 0;
        debug_data_q    = 0;
        debug_valid_q   = 0;
        debug_last_q    = 0;
        case (state_q)
            StWriteAddress: begin
                m_axi_araddr_q  = ADDRESS;
                m_axi_arlen_q   = LEN;
                m_axi_arsize_q  = SIZE;
                m_axi_arburst_q = BURST;
                m_axi_arvalid_q = 1;
            end
            StReadData: begin
                debug_data_q   = m_axi_rdata;
                debug_valid_q  = m_axi_rvalid;
                debug_last_q   = m_axi_rlast;
                m_axi_rready_q = 1;
            end
            default: ;
        endcase
    end
endmodule
