module    multiply
(
    input signed[7:0]   mul_A,
    input signed[7:0]   mul_B,
    
    output signed [15:0] mul_S
);

wire  [7:0]  x1;
wire  [7:0]  x2;
wire  [7:0]  x3;
wire  [7:0]  x4;
wire  [7:0]  x5;
wire  [7:0]  x6;
wire  [7:0]  x7;

wire  [7:0]  xa;
wire  [7:0]  xb;

assign    xa =mul_A[7] ? ~(mul_A[6:0]-1'b1) : mul_A[6:0];  
assign    xb =mul_B[7] ? ~(mul_B[6:0]-1'b1) : mul_B[6:0];  

wire  [14:0]  s2;
wire  [14:0]  s3;
wire  [14:0]  s4;
wire  [14:0]  s5;
wire  [14:0]  s6;
wire  [14:0]  s7;

assign    x1 = xb[0] ? xa[6:0] : 1'b0;
assign    x2 = xb[1] ? xa[6:0] : 1'b0;
assign    x3 = xb[2] ? xa[6:0] : 1'b0;
assign    x4 = xb[3] ? xa[6:0] : 1'b0;
assign    x5 = xb[4] ? xa[6:0] : 1'b0;
assign    x6 = xb[5] ? xa[6:0] : 1'b0;
assign    x7 = xb[6] ? xa[6:0] : 1'b0;



assign    s2 = {x2[6:0], 1'b0};
assign    s3 = {x3[6:0], 2'b0};
assign    s4 = {x4[6:0], 3'b0};
assign    s5 = {x5[6:0], 4'b0};
assign    s6 = {x6[6:0], 5'b0};
assign    s7 = {x7[6:0], 6'b0};

assign    mul_S[14:0]=((mul_A==0)||(mul_B==0))?15'd0:((mul_A[7]^mul_B[7]) ?(~(x1+s2+s3+s4+s5+s6+s7)+1'b1) :(x1+s2+s3+s4+s5+s6+s7));                
assign    mul_S[15] =((mul_A==0)||(mul_B==0))?(1'b0):((mul_A[7]^mul_B[7]) ? 1 :0);

endmodule


