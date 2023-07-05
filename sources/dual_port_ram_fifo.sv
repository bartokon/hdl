module dual_port_ram_fifo #(
    parameter int unsigned DATA_SIZE = 16
) (
    input logic [DATA_SIZE - 1 : 0] data_in_tdata,
    input logic data_in_tvalid,
    output logic data_in_tready,
    output logic [DATA_SIZE - 1 : 0] data_out_tdata,
    output logic data_out_tvalid,
    input logic data_out_tready,
    input logic clk_i,
    input logic clk_o,
    input logic rst_ni
);
localparam int unsigned DEPTH_SIZE = 2; //2bit counters
localparam int unsigned COUNTER_MAX_SIZE = $pow(2, DEPTH_SIZE);

logic unsigned [DEPTH_SIZE - 1: 0] counter_in;
logic unsigned [DEPTH_SIZE - 1: 0] counter_out;
logic [DATA_SIZE - 1: 0] memory [COUNTER_MAX_SIZE - 1 : 0];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (rst_ni == 0) begin
            counter_in <= 0;
        end else begin
            counter_in <= counter_in + (data_in_tvalid && data_in_tready);
        end
    end

    always_ff @(posedge clk_o or negedge rst_ni) begin
        if (rst_ni == 0) begin
            counter_out <= 0;
        end else begin
            counter_out <= counter_out + (data_out_tvalid && data_out_tready);
        end
    end

    logic unsigned [DEPTH_SIZE - 1 : 0] test;
    assign test = counter_out - 1;
    assign is_empty = counter_in == counter_out;
    assign is_full = (counter_in == test); //edge case not detected... x >= -1 (never)
    assign revers = (counter_out > counter_in);
    assign has_data = counter_in > counter_out;
    assign data_in_tready = (revers ? is_full : !is_full) || is_empty || (has_data && !is_full);

    always_ff @(posedge clk_i) begin: write_to_memory
        if (data_in_tvalid && data_in_tready) begin
            memory[counter_in] <= data_in_tdata;
        end
    end

    assign data_out_tdata = memory[counter_out];
    assign data_out_tvalid = !revers ? (counter_in > counter_out) : (counter_in < counter_out);

endmodule