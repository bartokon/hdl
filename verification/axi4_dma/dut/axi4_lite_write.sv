//`timescale 1ns / 1ps
//`default_nettype none

module axi4_lite_write #(
    parameter DEPTH = 4,
    parameter DATA_SIZE = 32
) (
    //Write port
    input logic [$clog2(DEPTH) - 1 : 0] write_address_i,
    input logic write_address_valid_i,
    output logic write_address_ready_o,

    input logic [DATA_SIZE - 1 : 0] write_data_i,
    input logic [DATA_SIZE / 8 - 1 : 0] write_data_strb_i,
    input logic write_data_valid_i,
    output logic write_data_ready_o,

    //Write port response
    output logic [1 : 0] write_response_o,
    output logic write_response_valid_o,
    input logic write_response_ready_i,

    //Misc
    input logic clk_i,
    input logic rst_clk_ni,

    output logic [DATA_SIZE - 1 : 0] register_data_o,
    output logic [$clog2(DEPTH) - 1 : 0] register_address_o,
    output logic [DATA_SIZE / 8 - 1 : 0] enable_register_data_o
);
    typedef enum logic [2:0] {
        IDLE     = 3'b001,
        WRITE    = 3'b010,
        RESPONSE = 3'b100
    } state_e;
    state_e state_q, state_d;

    typedef enum logic [1:0] {
        OKAY    = 2'b00,
        EXOKAY  = 2'b01,
        SLVERR  = 2'b10,
        DECERR  = 2'b11
    }  write_response_e;

    write_response_e write_response_d;

    wire address_and_data_valid = write_address_valid_i && write_data_valid_i;
    wire address_and_data_ready = write_address_ready_o && write_data_ready_o;
    wire AND_valid_and_ready = address_and_data_valid && address_and_data_ready;
    wire RSP_valid_and_ready = write_response_valid_o && write_response_ready_i;

/*----------------------------------------------------------------------------*/
/*                             ASSERTIONS                                     */
/*----------------------------------------------------------------------------*/
    always @(posedge clk_i) begin
        if (write_address_valid_i) begin
            assert (write_address_i % (DATA_SIZE / 8) == 0) else
                $error("Address is not aligned to the data size.");
            assert (write_address_i < DEPTH) else
                $error("Address is out of range.");
        end
        if (write_data_valid_i) begin
            assert (write_data_strb_i != 0) else
                $error("Write strobe is not valid.");
        end
    end

/*----------------------------------------------------------------------------*/
/*                             STATE MACHINE                                  */
/*----------------------------------------------------------------------------*/
    always_comb begin : state_fsm_comb
        if (rst_clk_ni == 0) begin
            state_d = IDLE;
        end else begin
            state_d = state_q;
            unique case (state_q)
                IDLE: begin
                    state_d = AND_valid_and_ready ? WRITE : IDLE;
                end
                WRITE: begin
                    state_d = RESPONSE;
                end
                RESPONSE: begin
                    state_d = RSP_valid_and_ready ? IDLE : RESPONSE;
                end
                default:;
            endcase
        end
    end

    always_ff @(posedge clk_i) begin: state_fsm_ff
        if (rst_clk_ni == 0) begin
            state_q <= IDLE;
        end else begin
            state_q <= state_d;
        end
    end

/*----------------------------------------------------------------------------*/
/*                               CHANNELS                                     */
/*----------------------------------------------------------------------------*/
    logic write_address_ready_d;
    logic write_data_ready_d;
    logic write_response_valid_d;
    logic [DATA_SIZE - 1 : 0] register_data_d;
    logic [$clog2(DEPTH) - 1 : 0] register_address_d;
    logic [DATA_SIZE / 8 - 1 : 0] enable_register_data_d;

    always_comb begin : channels_comb
        if (rst_clk_ni == 0) begin
            write_address_ready_d   = 0;
            write_data_ready_d      = 0;
            write_response_d        = OKAY;
            write_response_valid_d  = 0;
            register_data_d         = 0;
            register_address_d      = 0;
            enable_register_data_d  = 0;
        end else begin
            write_response_d        = write_response_e'(write_response_o);
            write_address_ready_d   = write_address_ready_o;
            write_data_ready_d      = write_data_ready_o;
            write_response_valid_d  = write_response_valid_o;
            register_data_d         = register_data_o;
            register_address_d      = register_address_o;
            enable_register_data_d  = enable_register_data_o;
            unique case (state_q)
                IDLE: begin
                    write_address_ready_d = 1;
                    write_data_ready_d = 1;
                    if (AND_valid_and_ready) begin
                        register_data_d = write_data_i;
                        register_address_d = write_address_i / (DATA_SIZE / 8);
                        enable_register_data_d = write_data_strb_i;
                        write_address_ready_d = 0;
                        write_data_ready_d = 0;
                    end
                end
                WRITE: begin
                    //Empty
                    register_data_d = 0;
                    register_address_d = 0;
                    enable_register_data_d = 0;
                end
                RESPONSE: begin
                    write_response_d =
                        register_address_o <= DEPTH ? OKAY : DECERR;
                    write_response_valid_d = 1;
                    if (RSP_valid_and_ready) begin
                        write_response_valid_d = 0;
                    end
                end
                default:;
            endcase
        end
    end

    always_ff @(posedge clk_i) begin: channels_ff
        if (rst_clk_ni == 0) begin
            write_address_ready_o   <= 0;
            write_data_ready_o      <= 0;
            write_response_o        <= 0;
            write_response_valid_o  <= 0;
            register_data_o         <= 0;
            register_address_o      <= 0;
            enable_register_data_o  <= 0;
        end else begin
            write_address_ready_o <= write_address_ready_d;
            write_data_ready_o <= write_data_ready_d;
            write_response_o <= write_response_d;
            write_response_valid_o <= write_response_valid_d;
            register_data_o <= register_data_d;
            register_address_o <= register_address_d;
            enable_register_data_o <= enable_register_data_d;
        end
    end

endmodule
