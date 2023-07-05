//Source https://youtu.be/aH11flclJDI

module float_add
#(
    parameter integer exponent_width = 8,
    parameter integer fraction_width = 23
)
(
    input  logic [exponent_width + fraction_width:0] a,
    input  logic [exponent_width + fraction_width:0] b,
    output logic [exponent_width + fraction_width:0] c,
    //Needed?
    output logic plus_inf,
    output logic minus_inf,
    output logic sNaN,
    output logic NaN,
    //?
    input  logic clk,
    input  logic rst_clk_n
);
    logic [exponent_width - 1 : 0] bias;
    assign bias = (1'b1 << (exponent_width - 1));
    
    logic [exponent_width - 1 : 0] a_biased_exponent;
    logic [exponent_width - 1: 0] b_biased_exponent;
    assign a_biased_exponent = a[exponent_width + fraction_width : fraction_width];
    assign b_biased_exponent = b[exponent_width + fraction_width: fraction_width];
    
    logic signed [exponent_width - 1 : 0] a_true_exponent;
    logic signed [exponent_width - 1 : 0] b_true_exponent;
    assign a_true_exponent = a_biased_exponent - bias;
    assign b_true_exponent = b_biased_exponent - bias;
    
    logic [fraction_width - 1 : 0] a_fraction;
    logic [fraction_width - 1 : 0] b_fraction;
    assign a_fraction = a[fraction_width:0];
    assign b_fraction = b[fraction_width:0];
    
    logic a_sign;
    logic b_sign;
    assign a_sign = a[exponent_width + fraction_width];
    assign b_sign = b[exponent_width + fraction_width];

    // idk just a template https://youtu.be/K-g-qtV_pC8
    assign inf = ({exponent_width{1'b1}} == a_biased_exponent);
    assign plus_inf = (inf * a_sign) * (a_fraction == 0);
    assign minus_inf = inf * !a_sign * (a_fraction == 0);
    
    
endmodule