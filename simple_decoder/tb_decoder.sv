`timescale 1ns/10ps

module tb_decoder();
    
    logic [7:0] stream_i;
    logic pattern_o [3:0];
    logic clk_i = 0;
    logic rstn_clk_ni = 0;
    
    always #10 clk_i = ~clk_i;
    
    decoder u0(
        .stream_i(stream_i),
        .pattern_o(pattern_o),
        .clk_i(clk_i),
        .rstn_clk_ni(rstn_clk_ni)
    );        
    
    initial begin 
        stream_i = 0;
        #50 rstn_clk_ni = ~rstn_clk_ni;
        #100 
        @(posedge clk_i) stream_i = 8'b0000_1111;
        @(posedge clk_i) stream_i = 0;
    end
endmodule