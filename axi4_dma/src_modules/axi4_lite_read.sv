//`timescale 1ns / 1ps
//`default_nettype none

module axi4_lite_read #(
    parameter DEPTH = 8,
    parameter DATA_SIZE = 32
) (
    //Read port
    input logic [$clog2(DEPTH) - 1 : 0] read_address_i,
    input logic read_address_valid_i,
    output logic read_address_ready_o,

    //Read port response
    output logic [1 : 0] read_data_response_o,
    output logic [DATA_SIZE-1:0] read_data_o,
    output logic read_data_valid_o,
    input logic read_data_ready_i,

    //Misc
    input logic clk_i,
    input logic rst_clk_ni,

    input logic [DATA_SIZE - 1 : 0] register_data_i,
    output logic [$clog2(DEPTH) - 1 : 0] register_address_o
);

    typedef enum logic [2:0] {
        IDLE     = 3'b001,
        READ     = 3'b010,
        RESPONSE = 3'b100
    } state_e;
    state_e state_q, state_d;

    typedef enum logic [1:0] {
        OKAY    = 2'b00,
        EXOKAY  = 2'b01,
        SLVERR  = 2'b10,
        DECERR  = 2'b11
    } read_response_e;
    read_response_e read_response_d;

    wire address_valid_and_ready = read_address_valid_i && read_address_ready_o;
    wire data_valid_and_ready = read_data_valid_o && read_data_ready_i;

    localparam READ_DELAY = 4;
    logic [$clog2(READ_DELAY) - 1 : 0] read_delay_q, read_delay_d;
    wire read_done = (read_delay_q == READ_DELAY - 1);

/*----------------------------------------------------------------------------*/
/*                             ASSERTIONS                                     */
/*----------------------------------------------------------------------------*/
    always @(posedge clk_i) begin
        if (read_address_valid_i) begin
            assert (read_address_i < DEPTH) else
                $error("Read address out of range.");
        end
    end

/*----------------------------------------------------------------------------*/
/*                             STATE MACHINE                                  */
/*----------------------------------------------------------------------------*/

    always_comb begin: state_fsm_comb
        if (rst_clk_ni == 0) begin
            state_d = IDLE;
        end else begin
            state_d = state_q;
            unique case (state_q)
                IDLE: begin
                    if (address_valid_and_ready) begin
                        state_d = READ;
                    end
                end
                READ: begin
                    if (read_done) begin
                        state_d = RESPONSE;
                    end
                end
                RESPONSE: begin
                    if (data_valid_and_ready) begin
                        state_d = IDLE;
                    end
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
    logic [$clog2(DEPTH) - 1 : 0] read_address_d;
    logic read_address_ready_d;
    logic read_data_valid_d;
    logic [DATA_SIZE - 1 : 0] read_data_d;

    always_comb begin: channels_comb
        if (rst_clk_ni == 0) begin
            read_response_d = OKAY;
            read_address_ready_d = 0;
            read_delay_d = 0;
            read_address_d = 0;
            read_data_d = 0;
            read_data_valid_d = 0;
        end else begin
            read_response_d = read_response_e'(read_data_response_o);
            read_address_ready_d = read_address_ready_o;
            read_address_d = register_address_o;
            read_data_valid_d = read_data_valid_o;
            read_delay_d = read_delay_q;
            read_data_d = read_data_o;
            unique case (state_q)
                IDLE: begin
                    read_address_ready_d = 1;
                    read_delay_d = 0;
                    if (address_valid_and_ready) begin
                        read_address_ready_d = 0;
                        read_address_d = read_address_i / (DATA_SIZE / 8);
                    end
                end
                READ: begin
                    read_delay_d = read_delay_q + 1;
                    if (read_done) begin
                        read_data_d = register_data_i;
                        read_response_d = (read_address_i < DEPTH) ? OKAY : DECERR;
                        read_data_valid_d = 1;
                    end
                end
                RESPONSE: begin
                    if (data_valid_and_ready) begin
                        read_data_valid_d = 0;
                    end
                end
                default:;
            endcase
        end
    end

    always_ff @(posedge clk_i) begin: channels_ff
        if (rst_clk_ni == 0) begin
            read_data_response_o <= 0;
            read_data_o <= 0;
            read_data_valid_o <= 0;
            read_address_ready_o <= 0;
            read_delay_q <= 0;
            register_address_o <= 0;
        end else begin
            read_address_ready_o <= read_address_ready_d;
            read_data_response_o <= read_response_d;
            read_delay_q <= read_delay_d;
            register_address_o <= read_address_d;
            read_data_o <= read_data_d;
            read_data_valid_o <= read_data_valid_d;
        end
    end

endmodule
