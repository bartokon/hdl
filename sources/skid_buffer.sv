//Warning: Can cause errors in V++
//`default_nettype wire

module skid_buffer #(
    parameter int unsigned DATA_SIZE = 8
) (
    // Input ports
    input logic [DATA_SIZE-1:0] data_i,
    input logic data_valid_i,
    output logic data_ready_o,
    // Output ports
    output logic [DATA_SIZE-1:0] data_o,
    output logic data_valid_o,
    input logic data_ready_i,
    // Misc
    input logic clk_i,
    input logic rst_clk_ni
);

typedef enum logic [0:0] {
    StFallThrough,
    StWaitForSlave
} fsm_state;

fsm_state state_q, state_d;

logic [DATA_SIZE-1:0] data_o_d, data_o_q;

assign slave_stall = data_valid_i && !data_ready_i;
assign slave_intf_ready_and_valid = data_valid_o && data_ready_i;

always_comb begin: main_fsm_logic
    //Assign default values -> default can be empty
    state_d = state_q;
    unique case (state_q)
        StWaitForSlave: begin
            state_d = slave_intf_ready_and_valid ? StFallThrough : StWaitForSlave;
        end
        StFallThrough: begin
            state_d = slave_stall ? StWaitForSlave : StFallThrough;
        end
        default: ;
    endcase
end

always_ff @(posedge clk_i) begin: main_fsm_ff
    if (rst_clk_ni == 0) begin
        state_q <= StFallThrough;
    end else begin
        state_q <= state_d;
    end
end

always_comb begin: io_logic
    //Assign default values -> default can be empty
    data_o_d = data_o_q;
    data_o = data_o_q;
    data_valid_o = 1'b0;
    data_ready_o = 1'b0;

    unique case (state_q)
        StFallThrough: begin
            data_o = data_i;
            data_o_d = data_i;
            data_valid_o = data_valid_i;
            data_ready_o = 1'b1;
        end
        StWaitForSlave: begin
            data_o = data_o_d;
            data_valid_o = 1'b1;
            data_ready_o = 1'b0;
        end
        default ;
    endcase
end

always_ff @(posedge clk_i) begin: io_ff
    if (rst_clk_ni == 0) begin
        data_o_q <= 0;
    end else begin
        data_o_q <= data_o_d;
    end
end

endmodule