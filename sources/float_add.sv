function logic [5:0] cz32 (input logic [31:0] in); 
    automatic logic [5:0] temp = 0;
    for (int i = 31; i >= 0; --i) begin
        if (temp == 0) begin 
            if (in[i] == 1'b1) begin 
                temp = i;
            end
        end 
    end
    return temp;
endfunction

module float_add
#(
    parameter integer EXPONENT_WIDTH = 8,
    parameter integer MANTISSA_WIDTH = 23
)
(
    input  logic [EXPONENT_WIDTH + MANTISSA_WIDTH : 0] in_a,
    input  logic [EXPONENT_WIDTH + MANTISSA_WIDTH : 0] in_b,
    output logic [EXPONENT_WIDTH + MANTISSA_WIDTH : 0] out_c,
    input logic clk
);
    //SIGN, EXPONENT, MANTISSA [MSB:LSB]
    typedef struct packed {
        logic unsigned sign; //MSB
        logic unsigned [EXPONENT_WIDTH - 1 : 0] exponent; 
        logic unsigned [MANTISSA_WIDTH : 0] mantissa; //LSB
    } float;

    float a, a_norm;
    float b, b_norm; 
    float c;
    
    logic [MANTISSA_WIDTH + 1:0] temp_mantissa;
    logic [5:0] c_shift;
    
    always_ff @(posedge clk) begin: Fetch_Data 
        a.sign <= in_a[31];
        a.exponent <= in_a[30:23];
        a.mantissa <= {1'b1, in_a[22:0]};
        b.sign <= in_b[31];
        b.exponent <= in_b[30:23];
        b.mantissa <= {1'b1, in_b[22:0]};
    end
    
    always_comb begin: Equalizing_Operand_Exponents
        a_norm.sign = a.sign;
        a_norm.mantissa = a.mantissa;
        a_norm.exponent = a.exponent;
        
        b_norm.sign = b.sign;
        b_norm.mantissa = b.mantissa;
        b_norm.exponent = b.exponent;
        
        if (a.exponent <= b.exponent) begin
            a_norm.mantissa = a.mantissa >> (b.exponent - a.exponent);
            a_norm.exponent = a.exponent + (b.exponent - a.exponent);
        end else if (a.exponent > b.exponent) begin 
            b_norm.mantissa = b.mantissa >> (a.exponent - b.exponent);
            b_norm.exponent = b.exponent + (a.exponent - b.exponent);
        end
    end
    
        //Convert operands from signed magnitude to 2's complement
        //--
        
    always_comb begin: Add_Mantissas
        temp_mantissa = a_norm.mantissa + b_norm.mantissa;
        c_shift = cz32(temp_mantissa);
    end    
    
        //Convert result from 2's complement to signed magnitude
        //--
        
    always_comb begin: Normalize_Result
        c.sign = a_norm.sign ^ b_norm.sign;
        if (temp_mantissa == 25'h1000000) begin //0+0 case 
            c.exponent = 0;
            c.mantissa = 0;
        end else if (c_shift >= 23) begin
            c.exponent = a_norm.exponent + (c_shift - 23);
            c.mantissa = temp_mantissa >> (c_shift - 23);
        end else begin 
            c.exponent = a_norm.exponent - (23 - c_shift);
            c.mantissa = temp_mantissa << (23 - c_shift);
        end
     end
     
     always_ff @(posedge clk) begin 
        out_c[31] <= c.sign;
        out_c[30:23] <= c.exponent;
        out_c[22:0] <= c.mantissa[22:0];
     end

endmodule
