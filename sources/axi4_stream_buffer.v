`timescale 1ns/10ps
`default_nettype none

module axi4_stream_buffer
#(
    parameter DATA_SIZE = 32
)
(
    //Read port
    input wire [DATA_SIZE - 1 :0] read_data,
    input wire read_data_valid,
    output wire read_data_ready,

    //Write port
    output wire [DATA_SIZE - 1 :0] write_data,
    output wire write_data_valid,
    input wire write_data_ready,

    //Misc
    input wire clk,
    input wire resetn
);

    localparam DEPTH = 4;
    reg [DATA_SIZE - 1 : 0] memory [DEPTH - 1 : 0];
    reg memory_valid [DEPTH - 1 : 0]; 

    assign write_data = memory[DEPTH - 1];
    assign write_data_valid = memory_valid[DEPTH - 1];
    assign read_data_ready = !memory_valid[DEPTH - 1] || !memory_valid[1] || write_data_ready; //Logic
    
    integer i;
    always @(posedge clk) begin: WORD_FALLTHROUGH
        if (resetn == 0) begin 
            for (i = 0; i < DEPTH; i = i + 1) begin: reset_loop
                memory[i] <= 0;
                memory_valid[i] <= 0;
            end
        end else begin       
            if (write_data_valid == 0 || write_data_ready == 1) begin
                for (i = 1; i < DEPTH; i = i + 1) begin: shift_loop
                        memory[i] <= memory[i - 1];
                        memory_valid[i] <= memory_valid[i - 1];
                end
                memory[0] <= read_data;
                memory_valid[0] <= read_data_valid;
            end
        end
    end

endmodule