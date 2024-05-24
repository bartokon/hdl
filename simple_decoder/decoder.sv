
module decoder(
    input logic [7:0] stream_i,
    output logic pattern_o [3:0],
    input logic clk_i,
    input logic rstn_clk_ni
);  

localparam [7:0] pattern [3:0]= {
    8'b0000_1111,
    8'b1111_0000,
    8'b0011_1100,
    8'b1100_0011
};

logic [15:0] shifted [7:0];
logic [7:0] actual_transaction;
logic [7:0] last_transaction;
logic [15:0] concat;
assign concat = {last_transaction, actual_transaction};

logic [7:0] slice [8:0];
generate
    genvar i;
    for (i = 0; i < 9; ++i) begin
        assign slice[i] = concat[15 - i: 8 - i];
    end
endgenerate

always_ff @(posedge clk_i) begin 
    if (rstn_clk_ni == 0) begin 
        last_transaction <= 0;
        actual_transaction <= 0;
    end else begin 
        actual_transaction <= stream_i;
        last_transaction <= actual_transaction;
    end  
end


always_comb begin: PATTERN_DETECT 
    begin
        for (int pattern_select = 0; pattern_select < 4; ++pattern_select) begin
            for (int shift = 0; shift < 9; ++shift) begin 
                pattern_o[pattern_select] |= (pattern[pattern_select] == slice[shift]);
            end
        end
    end
end

endmodule