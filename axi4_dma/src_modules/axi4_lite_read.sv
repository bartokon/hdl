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
    localparam DELAY = 3;
    logic [1 : 0] state;
    always_ff @(posedge clk_i) begin
        read_data_o <= register_data_i;
        if (rst_clk_ni == 0) begin
            state <= 0;
            read_data_response_o <= 0;
            read_data_valid_o <= 0;
            read_address_ready_o <= 0;
            register_address_o <= 0;
        end else begin
            if (state == 0) begin
                read_data_valid_o <= 1'b0;
                read_address_ready_o <=
                    (read_address_ready_o && read_address_valid_i) ? 1'b0 : 1'b1;
                register_address_o <= read_address_i;
                state <= state + read_address_ready_o && read_address_valid_i;
            end else if (state < DELAY) begin
                state <= state + 1'b1;
            end else begin
                read_address_ready_o <= 1'b0;
                read_data_response_o <= 2'b00;
                read_data_valid_o <=
                    (read_data_valid_o && read_data_ready_i) ? 1'b0 : 1'b1;
                state <= (read_data_valid_o && read_data_ready_i) ? 0 : state;
            end
        end
    end

endmodule
