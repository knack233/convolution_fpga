module    mul_bad
(
    input signed[7:0]   mul_1 ,
    input signed[7:0]   mul_2 ,
    input signed[7:0]   mul_3 ,
    input signed[7:0]   mul_4 ,
    input signed[7:0]   mul_5 ,
    input signed[7:0]   mul_6 ,
    input signed[7:0]   mul_7 ,
    input signed[7:0]   mul_8 ,
    input signed[7:0]   mul_9 ,
    input signed[7:0]   mul_11,
    input signed[7:0]   mul_22,
    input signed[7:0]   mul_33,
    input signed[7:0]   mul_44,
    input signed[7:0]   mul_55,
    input signed[7:0]   mul_66,
    input signed[7:0]   mul_77,
    input signed[7:0]   mul_88,
    input signed[7:0]   mul_99,    
    output signed [16:0] mul_S
);

wire signed   [15:0] mul_S1;
wire signed   [15:0] mul_S2;
wire signed   [15:0] mul_S3;
wire signed   [15:0] mul_S4;
wire signed   [15:0] mul_S5;
wire signed   [15:0] mul_S6;
wire signed   [15:0] mul_S7;
wire signed   [15:0] mul_S8;
wire signed   [15:0] mul_S9;

multiply    multiply_inst1
(
    .mul_A(mul_1),
    .mul_B(mul_11),    
    .mul_S(mul_S1)
);
multiply    multiply_inst2
(
    .mul_A(mul_2),
    .mul_B(mul_22),    
    .mul_S(mul_S2)
);
multiply    multiply_inst3
(
    .mul_A(mul_3),
    .mul_B(mul_33),    
    .mul_S(mul_S3)
);
multiply    multiply_inst4
(
    .mul_A(mul_4),
    .mul_B(mul_44),    
    .mul_S(mul_S4)
);
multiply    multiply_inst5
(
    .mul_A(mul_5),
    .mul_B(mul_55),    
    .mul_S(mul_S5)
);
multiply    multiply_inst6
(
    .mul_A(mul_6),
    .mul_B(mul_66),    
    .mul_S(mul_S6)
);
multiply    multiply_inst7
(
    .mul_A(mul_7),
    .mul_B(mul_77),    
    .mul_S(mul_S7)
);
multiply    multiply_inst8
(
    .mul_A(mul_8),
    .mul_B(mul_88),    
    .mul_S(mul_S8)
);
multiply    multiply_inst9
(
    .mul_A(mul_9),
    .mul_B(mul_99),    
    .mul_S(mul_S9)
);

//wire signed   [15:0] mul_S11;
//wire signed   [15:0] mul_S12;
//wire signed   [15:0] mul_S13;
//
//assign mul_S11 = mul_S1+ mul_S2+mul_S3;
//assign mul_S12 = mul_S4+mul_S5+mul_S6;
//assign mul_S13 = mul_S7+mul_S8+mul_S9;

assign  mul_S=mul_S1+mul_S2+mul_S3+mul_S4+mul_S5+mul_S6+mul_S7+mul_S8+mul_S9;

endmodule
