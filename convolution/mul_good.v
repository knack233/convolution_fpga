module    mul_good
(
    input               sys_clk,
    input               rst_n,
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


mul0 mul1 (
  .a(mul_1),        // input [7:0]
  .b(mul_11),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S1)         // output [15:0]
);
mul0 mul2 (
  .a(mul_2),        // input [7:0]
  .b(mul_22),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S2)         // output [15:0]
);

mul0 mul3 (
  .a(mul_3),        // input [7:0]
  .b(mul_33),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S3)         // output [15:0]
);
mul0 mul4 (
  .a(mul_4),        // input [7:0]
  .b(mul_44),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S4)         // output [15:0]
);
mul0 mul5 (
  .a(mul_5),        // input [7:0]
  .b(mul_55),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S5)         // output [15:0]
);
mul0 mul6 (
  .a(mul_6),        // input [7:0]
  .b(mul_66),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S6)         // output [15:0]
);
mul0 mul7 (
  .a(mul_7),        // input [7:0]
  .b(mul_77),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S7)         // output [15:0]
);
mul0 mul8 (
  .a(mul_8),        // input [7:0]
  .b(mul_88),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S8)         // output [15:0]
);
mul0 mul9 (
  .a(mul_9),        // input [7:0]
  .b(mul_99),        // input [7:0]
  .clk(sys_clk),    // input
  .rst(~rst_n),    // input
  .ce(1'b1),      // input
  .p(mul_S9)         // output [15:0]
);

//wire signed   [15:0] mul_S11;
//wire signed   [15:0] mul_S12;
//wire signed   [15:0] mul_S13;
//
//assign mul_S11 = mul_S1+ mul_S2+mul_S3;
//assign mul_S12 = mul_S4+mul_S5+mul_S6;
//assign mul_S13 = mul_S7+mul_S8+mul_S9;
//
assign  mul_S=mul_S1+mul_S2+mul_S3+mul_S4+mul_S5+mul_S6+mul_S7+mul_S8+mul_S9;


endmodule