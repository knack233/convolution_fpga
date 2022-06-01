module  convolution
#(
    parameter   IN_IJ_SIZE = 9'd208,
    parameter   IN_K_SIZE = 9'd16 ,
    parameter   FILTER_NUM= 9'd32 
)
(
    input           sys_clk          ,
    input           rst_n            ,
    input           sd_write_finish  ,
    input           conv_read_req_ack,
    input  [63:0]   ddr_read_data    ,
    
    output reg      read_en          ,
    output reg      conv_read_req    ,
    output reg      read_finish      ,
    output reg [7:0]   test_data     

);

localparam R_IDLE          = 0;
localparam R_KERNAL_INIT   = 1;
localparam R_KERNAL        = 2;
localparam R_M_INIT        = 3;
localparam R_M             = 4;
localparam R_BIAS_INIT     = 5;
localparam R_BIAS          = 6;
localparam R_END           = 7;
localparam R_INPUT         = 8; 
localparam CAL             = 9;  
localparam C_BIAS          = 10;  
localparam C_END           = 11;         

reg     [5:0]   state;

reg     [31:0]  num_cnt;
reg             kernal_init_finish;
reg             M_init_finish;
reg             BIAS_init_finish;
wire    [7:0]   read_data;
assign  read_data = ddr_read_data[7:0];

//calculate

reg    [15:0]  M[0:FILTER_NUM -1'b1]; // 3bit integer
reg    [31:0]  bias[0:FILTER_NUM -1'b1];


reg   signed  [7:0]   kernal000[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal001[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal002[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal010[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal011[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal012[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal020[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal021[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal022[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal100[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal101[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal102[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal110[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal111[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal112[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal120[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal121[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal122[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal200[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal201[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal202[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal210[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal211[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal212[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal220[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal221[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal222[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal300[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal301[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal302[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal310[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal311[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal312[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal320[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal321[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal322[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal400[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal401[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal402[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal410[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal411[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal412[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal420[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal421[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal422[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal500[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal501[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal502[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal510[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal511[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal512[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal520[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal521[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal522[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal600[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal601[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal602[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal610[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal611[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal612[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal620[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal621[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal622[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal700[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal701[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal702[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal710[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal711[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal712[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal720[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal721[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal722[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal800[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal801[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal802[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal810[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal811[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal812[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal820[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal821[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal822[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal900[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal901[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal902[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal910[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal911[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal912[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal920[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal921[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal922[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1000[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1001[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1002[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1010[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1011[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1012[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1020[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1021[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1022[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1100[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1101[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1102[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1110[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1111[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1112[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1120[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1121[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1122[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1200[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1201[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1202[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1210[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1211[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1212[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1220[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1221[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1222[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1300[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1301[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1302[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1310[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1311[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1312[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1320[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1321[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1322[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1400[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1401[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1402[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1410[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1411[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1412[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1420[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1421[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1422[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1500[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1501[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1502[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1510[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1511[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1512[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1520[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1521[0:FILTER_NUM -1'b1];
reg   signed  [7:0]   kernal1522[0:FILTER_NUM -1'b1];

wire   signed  [7:0]   cal_kernal000;
wire   signed  [7:0]   cal_kernal001;
wire   signed  [7:0]   cal_kernal002;
wire   signed  [7:0]   cal_kernal010;
wire   signed  [7:0]   cal_kernal011;
wire   signed  [7:0]   cal_kernal012;
wire   signed  [7:0]   cal_kernal020;
wire   signed  [7:0]   cal_kernal021;
wire   signed  [7:0]   cal_kernal022;
wire   signed  [7:0]   cal_kernal100;
wire   signed  [7:0]   cal_kernal101;
wire   signed  [7:0]   cal_kernal102;
wire   signed  [7:0]   cal_kernal110;
wire   signed  [7:0]   cal_kernal111;
wire   signed  [7:0]   cal_kernal112;
wire   signed  [7:0]   cal_kernal120;
wire   signed  [7:0]   cal_kernal121;
wire   signed  [7:0]   cal_kernal122;
wire   signed  [7:0]   cal_kernal200;
wire   signed  [7:0]   cal_kernal201;
wire   signed  [7:0]   cal_kernal202;
wire   signed  [7:0]   cal_kernal210;
wire   signed  [7:0]   cal_kernal211;
wire   signed  [7:0]   cal_kernal212;
wire   signed  [7:0]   cal_kernal220;
wire   signed  [7:0]   cal_kernal221;
wire   signed  [7:0]   cal_kernal222;
wire   signed  [7:0]   cal_kernal300;
wire   signed  [7:0]   cal_kernal301;
wire   signed  [7:0]   cal_kernal302;
wire   signed  [7:0]   cal_kernal310;
wire   signed  [7:0]   cal_kernal311;
wire   signed  [7:0]   cal_kernal312;
wire   signed  [7:0]   cal_kernal320;
wire   signed  [7:0]   cal_kernal321;
wire   signed  [7:0]   cal_kernal322;
wire   signed  [7:0]   cal_kernal400;
wire   signed  [7:0]   cal_kernal401;
wire   signed  [7:0]   cal_kernal402;
wire   signed  [7:0]   cal_kernal410;
wire   signed  [7:0]   cal_kernal411;
wire   signed  [7:0]   cal_kernal412;
wire   signed  [7:0]   cal_kernal420;
wire   signed  [7:0]   cal_kernal421;
wire   signed  [7:0]   cal_kernal422;
wire   signed  [7:0]   cal_kernal500;
wire   signed  [7:0]   cal_kernal501;
wire   signed  [7:0]   cal_kernal502;
wire   signed  [7:0]   cal_kernal510;
wire   signed  [7:0]   cal_kernal511;
wire   signed  [7:0]   cal_kernal512;
wire   signed  [7:0]   cal_kernal520;
wire   signed  [7:0]   cal_kernal521;
wire   signed  [7:0]   cal_kernal522;
wire   signed  [7:0]   cal_kernal600;
wire   signed  [7:0]   cal_kernal601;
wire   signed  [7:0]   cal_kernal602;
wire   signed  [7:0]   cal_kernal610;
wire   signed  [7:0]   cal_kernal611;
wire   signed  [7:0]   cal_kernal612;
wire   signed  [7:0]   cal_kernal620;
wire   signed  [7:0]   cal_kernal621;
wire   signed  [7:0]   cal_kernal622;
wire   signed  [7:0]   cal_kernal700;
wire   signed  [7:0]   cal_kernal701;
wire   signed  [7:0]   cal_kernal702;
wire   signed  [7:0]   cal_kernal710;
wire   signed  [7:0]   cal_kernal711;
wire   signed  [7:0]   cal_kernal712;
wire   signed  [7:0]   cal_kernal720;
wire   signed  [7:0]   cal_kernal721;
wire   signed  [7:0]   cal_kernal722;
wire   signed  [7:0]   cal_kernal800;
wire   signed  [7:0]   cal_kernal801;
wire   signed  [7:0]   cal_kernal802;
wire   signed  [7:0]   cal_kernal810;
wire   signed  [7:0]   cal_kernal811;
wire   signed  [7:0]   cal_kernal812;
wire   signed  [7:0]   cal_kernal820;
wire   signed  [7:0]   cal_kernal821;
wire   signed  [7:0]   cal_kernal822;
wire   signed  [7:0]   cal_kernal900;
wire   signed  [7:0]   cal_kernal901;
wire   signed  [7:0]   cal_kernal902;
wire   signed  [7:0]   cal_kernal910;
wire   signed  [7:0]   cal_kernal911;
wire   signed  [7:0]   cal_kernal912;
wire   signed  [7:0]   cal_kernal920;
wire   signed  [7:0]   cal_kernal921;
wire   signed  [7:0]   cal_kernal922;
wire   signed  [7:0]   cal_kernal1000;
wire   signed  [7:0]   cal_kernal1001;
wire   signed  [7:0]   cal_kernal1002;
wire   signed  [7:0]   cal_kernal1010;
wire   signed  [7:0]   cal_kernal1011;
wire   signed  [7:0]   cal_kernal1012;
wire   signed  [7:0]   cal_kernal1020;
wire   signed  [7:0]   cal_kernal1021;
wire   signed  [7:0]   cal_kernal1022;
wire   signed  [7:0]   cal_kernal1100;
wire   signed  [7:0]   cal_kernal1101;
wire   signed  [7:0]   cal_kernal1102;
wire   signed  [7:0]   cal_kernal1110;
wire   signed  [7:0]   cal_kernal1111;
wire   signed  [7:0]   cal_kernal1112;
wire   signed  [7:0]   cal_kernal1120;
wire   signed  [7:0]   cal_kernal1121;
wire   signed  [7:0]   cal_kernal1122;
wire   signed  [7:0]   cal_kernal1200;
wire   signed  [7:0]   cal_kernal1201;
wire   signed  [7:0]   cal_kernal1202;
wire   signed  [7:0]   cal_kernal1210;
wire   signed  [7:0]   cal_kernal1211;
wire   signed  [7:0]   cal_kernal1212;
wire   signed  [7:0]   cal_kernal1220;
wire   signed  [7:0]   cal_kernal1221;
wire   signed  [7:0]   cal_kernal1222;
wire   signed  [7:0]   cal_kernal1300;
wire   signed  [7:0]   cal_kernal1301;
wire   signed  [7:0]   cal_kernal1302;
wire   signed  [7:0]   cal_kernal1310;
wire   signed  [7:0]   cal_kernal1311;
wire   signed  [7:0]   cal_kernal1312;
wire   signed  [7:0]   cal_kernal1320;
wire   signed  [7:0]   cal_kernal1321;
wire   signed  [7:0]   cal_kernal1322;
wire   signed  [7:0]   cal_kernal1400;
wire   signed  [7:0]   cal_kernal1401;
wire   signed  [7:0]   cal_kernal1402;
wire   signed  [7:0]   cal_kernal1410;
wire   signed  [7:0]   cal_kernal1411;
wire   signed  [7:0]   cal_kernal1412;
wire   signed  [7:0]   cal_kernal1420;
wire   signed  [7:0]   cal_kernal1421;
wire   signed  [7:0]   cal_kernal1422;
wire   signed  [7:0]   cal_kernal1500;
wire   signed  [7:0]   cal_kernal1501;
wire   signed  [7:0]   cal_kernal1502;
wire   signed  [7:0]   cal_kernal1510;
wire   signed  [7:0]   cal_kernal1511;
wire   signed  [7:0]   cal_kernal1512;
wire   signed  [7:0]   cal_kernal1520;
wire   signed  [7:0]   cal_kernal1521;
wire   signed  [7:0]   cal_kernal1522;

wire signed   [16:0]  data_store0;
wire signed   [16:0]  data_store1;
wire signed   [16:0]  data_store2;
wire signed   [16:0]  data_store3;
wire signed   [16:0]  data_store4;
wire signed   [16:0]  data_store5;
wire signed   [16:0]  data_store6;
wire signed   [16:0]  data_store7;
wire signed   [16:0]  data_store8;
wire signed   [16:0]  data_store9;
wire signed   [16:0]  data_store10;
wire signed   [16:0]  data_store11;

wire   signed  [16:0]  sum_result ;
reg    signed  [16:0]  result[0:FILTER_NUM -1'b1][0:IN_IJ_SIZE - 1'b1][0:IN_IJ_SIZE - 1'b1];

wire  signed  [8:0]  input_write0;
wire  signed  [8:0]  input_write1;
wire  signed  [8:0]  input_write2;
wire  signed  [8:0]  input_write3;
wire  signed  [8:0]  input_write4;
wire  signed  [8:0]  input_write5;
wire  signed  [8:0]  input_write6;
wire  signed  [8:0]  input_write7;
wire  signed  [8:0]  input_write8;
wire  signed  [8:0]  input_write9;
wire  signed  [8:0]  input_write10;
wire  signed  [8:0]  input_write11;

reg         wr_en1;
reg         wr_en2;
reg         rd_en;
reg     signed  [8:0]   write_data01;
reg     signed  [8:0]   write_data02; 
wire    signed  [8:0]   rd_data01;
wire    signed  [8:0]   rd_data02;
reg     signed  [8:0]   write_data11;
reg     signed  [8:0]   write_data12; 
wire    signed  [8:0]   rd_data11;
wire    signed  [8:0]   rd_data12;  
reg     signed  [8:0]   write_data21;
reg     signed  [8:0]   write_data22; 
wire    signed  [8:0]   rd_data21;
wire    signed  [8:0]   rd_data22; 
reg     signed  [8:0]   write_data31;
reg     signed  [8:0]   write_data32; 
wire    signed  [8:0]   rd_data31;
wire    signed  [8:0]   rd_data32; 
reg     signed  [8:0]   write_data41;
reg     signed  [8:0]   write_data42; 
wire    signed  [8:0]   rd_data41;
wire    signed  [8:0]   rd_data42;
reg     signed  [8:0]   write_data51;
reg     signed  [8:0]   write_data52; 
wire    signed  [8:0]   rd_data51;
wire    signed  [8:0]   rd_data52;  


wire   [8:0]  f_input_store000;
wire   [8:0]  f_input_store001;
wire   [8:0]  f_input_store002;
reg   [8:0]  f_input_store010;
reg   [8:0]  f_input_store011;
reg   [8:0]  f_input_store012;
reg   [8:0]  f_input_store020;
reg   [8:0]  f_input_store021;
reg   [8:0]  f_input_store022;
wire   [8:0]  f_input_store100;
wire   [8:0]  f_input_store101;
wire   [8:0]  f_input_store102;
reg   [8:0]  f_input_store110;
reg   [8:0]  f_input_store111;
reg   [8:0]  f_input_store112;
reg   [8:0]  f_input_store120;
reg   [8:0]  f_input_store121;
reg   [8:0]  f_input_store122;
wire   [8:0]  f_input_store200;
wire   [8:0]  f_input_store201;
wire   [8:0]  f_input_store202;
reg   [8:0]  f_input_store210;
reg   [8:0]  f_input_store211;
reg   [8:0]  f_input_store212;
reg   [8:0]  f_input_store220;
reg   [8:0]  f_input_store221;
reg   [8:0]  f_input_store222;
wire   [8:0]  f_input_store300;
wire   [8:0]  f_input_store301;
wire   [8:0]  f_input_store302;
reg   [8:0]  f_input_store310;
reg   [8:0]  f_input_store311;
reg   [8:0]  f_input_store312;
reg   [8:0]  f_input_store320;
reg   [8:0]  f_input_store321;
reg   [8:0]  f_input_store322;
wire   [8:0]  f_input_store400;
wire   [8:0]  f_input_store401;
wire   [8:0]  f_input_store402;
reg   [8:0]  f_input_store410;
reg   [8:0]  f_input_store411;
reg   [8:0]  f_input_store412;
reg   [8:0]  f_input_store420;
reg   [8:0]  f_input_store421;
reg   [8:0]  f_input_store422;
wire   [8:0]  f_input_store500;
wire   [8:0]  f_input_store501;
wire   [8:0]  f_input_store502;
reg   [8:0]  f_input_store510;
reg   [8:0]  f_input_store511;
reg   [8:0]  f_input_store512;
reg   [8:0]  f_input_store520;
reg   [8:0]  f_input_store521;
reg   [8:0]  f_input_store522;
wire   [8:0]  b_input_store000;
wire   [8:0]  b_input_store001;
wire   [8:0]  b_input_store002;
reg   [8:0]  b_input_store010;
reg   [8:0]  b_input_store011;
reg   [8:0]  b_input_store012;
reg   [8:0]  b_input_store020;
reg   [8:0]  b_input_store021;
reg   [8:0]  b_input_store022;
wire   [8:0]  b_input_store100;
wire   [8:0]  b_input_store101;
wire   [8:0]  b_input_store102;
reg   [8:0]  b_input_store110;
reg   [8:0]  b_input_store111;
reg   [8:0]  b_input_store112;
reg   [8:0]  b_input_store120;
reg   [8:0]  b_input_store121;
reg   [8:0]  b_input_store122;
wire   [8:0]  b_input_store200;
wire   [8:0]  b_input_store201;
wire   [8:0]  b_input_store202;
reg   [8:0]  b_input_store210;
reg   [8:0]  b_input_store211;
reg   [8:0]  b_input_store212;
reg   [8:0]  b_input_store220;
reg   [8:0]  b_input_store221;
reg   [8:0]  b_input_store222;
wire   [8:0]  b_input_store300;
wire   [8:0]  b_input_store301;
wire   [8:0]  b_input_store302;
reg   [8:0]  b_input_store310;
reg   [8:0]  b_input_store311;
reg   [8:0]  b_input_store312;
reg   [8:0]  b_input_store320;
reg   [8:0]  b_input_store321;
reg   [8:0]  b_input_store322;
wire   [8:0]  b_input_store400;
wire   [8:0]  b_input_store401;
wire   [8:0]  b_input_store402;
reg   [8:0]  b_input_store410;
reg   [8:0]  b_input_store411;
reg   [8:0]  b_input_store412;
reg   [8:0]  b_input_store420;
reg   [8:0]  b_input_store421;
reg   [8:0]  b_input_store422;
wire   [8:0]  b_input_store500;
wire   [8:0]  b_input_store501;
wire   [8:0]  b_input_store502;
reg   [8:0]  b_input_store510;
reg   [8:0]  b_input_store511;
reg   [8:0]  b_input_store512;
reg   [8:0]  b_input_store520;
reg   [8:0]  b_input_store521;
reg   [8:0]  b_input_store522;

//delay

reg   [8:0]  f_input_store000_d0;
reg   [8:0]  f_input_store001_d0;
reg   [8:0]  f_input_store002_d0;
reg   [8:0]  f_input_store010_d0;
reg   [8:0]  f_input_store011_d0;
reg   [8:0]  f_input_store012_d0;
reg   [8:0]  f_input_store100_d0;
reg   [8:0]  f_input_store101_d0;
reg   [8:0]  f_input_store102_d0;
reg   [8:0]  f_input_store110_d0;
reg   [8:0]  f_input_store111_d0;
reg   [8:0]  f_input_store112_d0;
reg   [8:0]  f_input_store200_d0;
reg   [8:0]  f_input_store201_d0;
reg   [8:0]  f_input_store202_d0;
reg   [8:0]  f_input_store210_d0;
reg   [8:0]  f_input_store211_d0;
reg   [8:0]  f_input_store212_d0;
reg   [8:0]  f_input_store300_d0;
reg   [8:0]  f_input_store301_d0;
reg   [8:0]  f_input_store302_d0;
reg   [8:0]  f_input_store310_d0;
reg   [8:0]  f_input_store311_d0;
reg   [8:0]  f_input_store312_d0;
reg   [8:0]  f_input_store400_d0;
reg   [8:0]  f_input_store401_d0;
reg   [8:0]  f_input_store402_d0;
reg   [8:0]  f_input_store410_d0;
reg   [8:0]  f_input_store411_d0;
reg   [8:0]  f_input_store412_d0;
reg   [8:0]  f_input_store500_d0;
reg   [8:0]  f_input_store501_d0;
reg   [8:0]  f_input_store502_d0;
reg   [8:0]  f_input_store510_d0;
reg   [8:0]  f_input_store511_d0;
reg   [8:0]  f_input_store512_d0;
reg   [8:0]  b_input_store000_d0;
reg   [8:0]  b_input_store001_d0;
reg   [8:0]  b_input_store002_d0;
reg   [8:0]  b_input_store010_d0;
reg   [8:0]  b_input_store011_d0;
reg   [8:0]  b_input_store012_d0;
reg   [8:0]  b_input_store100_d0;
reg   [8:0]  b_input_store101_d0;
reg   [8:0]  b_input_store102_d0;
reg   [8:0]  b_input_store110_d0;
reg   [8:0]  b_input_store111_d0;
reg   [8:0]  b_input_store112_d0;
reg   [8:0]  b_input_store200_d0;
reg   [8:0]  b_input_store201_d0;
reg   [8:0]  b_input_store202_d0;
reg   [8:0]  b_input_store210_d0;
reg   [8:0]  b_input_store211_d0;
reg   [8:0]  b_input_store212_d0;
reg   [8:0]  b_input_store300_d0;
reg   [8:0]  b_input_store301_d0;
reg   [8:0]  b_input_store302_d0;
reg   [8:0]  b_input_store310_d0;
reg   [8:0]  b_input_store311_d0;
reg   [8:0]  b_input_store312_d0;
reg   [8:0]  b_input_store400_d0;
reg   [8:0]  b_input_store401_d0;
reg   [8:0]  b_input_store402_d0;
reg   [8:0]  b_input_store410_d0;
reg   [8:0]  b_input_store411_d0;
reg   [8:0]  b_input_store412_d0;
reg   [8:0]  b_input_store500_d0;
reg   [8:0]  b_input_store501_d0;
reg   [8:0]  b_input_store502_d0;
reg   [8:0]  b_input_store510_d0;
reg   [8:0]  b_input_store511_d0;
reg   [8:0]  b_input_store512_d0;


wire   [8:0]   cal_input_store000;
wire   [8:0]   cal_input_store001;
wire   [8:0]   cal_input_store002;
wire   [8:0]   cal_input_store010;
wire   [8:0]   cal_input_store011;
wire   [8:0]   cal_input_store012;
wire   [8:0]   cal_input_store020;
wire   [8:0]   cal_input_store021;
wire   [8:0]   cal_input_store022;
wire   [8:0]   cal_input_store100;
wire   [8:0]   cal_input_store101;
wire   [8:0]   cal_input_store102;
wire   [8:0]   cal_input_store110;
wire   [8:0]   cal_input_store111;
wire   [8:0]   cal_input_store112;
wire   [8:0]   cal_input_store120;
wire   [8:0]   cal_input_store121;
wire   [8:0]   cal_input_store122;
wire   [8:0]   cal_input_store200;
wire   [8:0]   cal_input_store201;
wire   [8:0]   cal_input_store202;
wire   [8:0]   cal_input_store210;
wire   [8:0]   cal_input_store211;
wire   [8:0]   cal_input_store212;
wire   [8:0]   cal_input_store220;
wire   [8:0]   cal_input_store221;
wire   [8:0]   cal_input_store222;
wire   [8:0]   cal_input_store300;
wire   [8:0]   cal_input_store301;
wire   [8:0]   cal_input_store302;
wire   [8:0]   cal_input_store310;
wire   [8:0]   cal_input_store311;
wire   [8:0]   cal_input_store312;
wire   [8:0]   cal_input_store320;
wire   [8:0]   cal_input_store321;
wire   [8:0]   cal_input_store322;
wire   [8:0]   cal_input_store400;
wire   [8:0]   cal_input_store401;
wire   [8:0]   cal_input_store402;
wire   [8:0]   cal_input_store410;
wire   [8:0]   cal_input_store411;
wire   [8:0]   cal_input_store412;
wire   [8:0]   cal_input_store420;
wire   [8:0]   cal_input_store421;
wire   [8:0]   cal_input_store422;
wire   [8:0]   cal_input_store500;
wire   [8:0]   cal_input_store501;
wire   [8:0]   cal_input_store502;
wire   [8:0]   cal_input_store510;
wire   [8:0]   cal_input_store511;
wire   [8:0]   cal_input_store512;
wire   [8:0]   cal_input_store520;
wire   [8:0]   cal_input_store521;
wire   [8:0]   cal_input_store522;

//cnt
reg     [11:0]  i_cnt;
reg     [11:0]  j_cnt;
reg     [8:0]   k_cnt;
reg     [10:0]   a_cnt;
reg     [2:0]   x_cnt;

reg             mul_finish;
reg             sum_finish;
reg             cal_finish;

//fifo_reset
reg     reset;

//ddr3
reg     sim_read_en;//ddr用的时候可能要提前;
reg     read_dly;
localparam DELAY = 115;

//calculation
wire   signed  [16:0]  sum_result1 ;
wire   signed  [16:0]  sum_result2 ;
wire   signed  [16:0]  sum_result3 ;
wire   signed  [16:0]  sum_result4 ;
wire   signed  [16:0]  sum_result5 ;
wire   signed  [16:0]  sum_result6 ;


reg    signed  [16:0]  data_store0_dly;
reg    signed  [16:0]  data_store1_dly;
reg    signed  [16:0]  data_store2_dly;
reg    signed  [16:0]  data_store3_dly;
reg    signed  [16:0]  data_store4_dly;
reg    signed  [16:0]  data_store5_dly;
reg    signed  [16:0]  data_store6_dly;
reg    signed  [16:0]  data_store7_dly;
reg    signed  [16:0]  data_store8_dly;
reg    signed  [16:0]  data_store9_dly;
reg    signed  [16:0]  data_store10_dly;
reg    signed  [16:0]  data_store11_dly;


//缓存32个通道
reg   signed  [8:0]   f_input_store020_channel;
reg   signed  [8:0]   f_input_store021_channel;
reg   signed  [8:0]   f_input_store022_channel;
reg   signed  [8:0]   f_input_store010_channel;
reg   signed  [8:0]   f_input_store011_channel;
reg   signed  [8:0]   f_input_store012_channel;
reg   signed  [8:0]   f_input_store000_channel;
reg   signed  [8:0]   f_input_store001_channel;
reg   signed  [8:0]   f_input_store002_channel;
reg   signed  [8:0]   f_input_store120_channel;
reg   signed  [8:0]   f_input_store121_channel;
reg   signed  [8:0]   f_input_store122_channel;
reg   signed  [8:0]   f_input_store110_channel;
reg   signed  [8:0]   f_input_store111_channel;
reg   signed  [8:0]   f_input_store112_channel;
reg   signed  [8:0]   f_input_store100_channel;
reg   signed  [8:0]   f_input_store101_channel;
reg   signed  [8:0]   f_input_store102_channel;
reg   signed  [8:0]   f_input_store220_channel;
reg   signed  [8:0]   f_input_store221_channel;
reg   signed  [8:0]   f_input_store222_channel;
reg   signed  [8:0]   f_input_store210_channel;
reg   signed  [8:0]   f_input_store211_channel;
reg   signed  [8:0]   f_input_store212_channel;
reg   signed  [8:0]   f_input_store200_channel;
reg   signed  [8:0]   f_input_store201_channel;
reg   signed  [8:0]   f_input_store202_channel;
reg   signed  [8:0]   f_input_store320_channel;
reg   signed  [8:0]   f_input_store321_channel;
reg   signed  [8:0]   f_input_store322_channel;
reg   signed  [8:0]   f_input_store310_channel;
reg   signed  [8:0]   f_input_store311_channel;
reg   signed  [8:0]   f_input_store312_channel;
reg   signed  [8:0]   f_input_store300_channel;
reg   signed  [8:0]   f_input_store301_channel;  
reg   signed  [8:0]   f_input_store302_channel;
reg   signed  [8:0]   f_input_store420_channel;
reg   signed  [8:0]   f_input_store421_channel;
reg   signed  [8:0]   f_input_store422_channel;
reg   signed  [8:0]   f_input_store410_channel;
reg   signed  [8:0]   f_input_store411_channel;
reg   signed  [8:0]   f_input_store412_channel;
reg   signed  [8:0]   f_input_store400_channel;
reg   signed  [8:0]   f_input_store401_channel;
reg   signed  [8:0]   f_input_store402_channel;
reg   signed  [8:0]   f_input_store520_channel;
reg   signed  [8:0]   f_input_store521_channel;
reg   signed  [8:0]   f_input_store522_channel;
reg   signed  [8:0]   f_input_store510_channel;
reg   signed  [8:0]   f_input_store511_channel;
reg   signed  [8:0]   f_input_store512_channel;
reg   signed  [8:0]   f_input_store500_channel;
reg   signed  [8:0]   f_input_store501_channel;
reg   signed  [8:0]   f_input_store502_channel;
reg   signed  [8:0]   b_input_store020_channel;
reg   signed  [8:0]   b_input_store021_channel;
reg   signed  [8:0]   b_input_store022_channel;
reg   signed  [8:0]   b_input_store010_channel;
reg   signed  [8:0]   b_input_store011_channel;
reg   signed  [8:0]   b_input_store012_channel;
reg   signed  [8:0]   b_input_store000_channel;
reg   signed  [8:0]   b_input_store001_channel;
reg   signed  [8:0]   b_input_store002_channel;
reg   signed  [8:0]   b_input_store120_channel;
reg   signed  [8:0]   b_input_store121_channel;
reg   signed  [8:0]   b_input_store122_channel;
reg   signed  [8:0]   b_input_store110_channel;
reg   signed  [8:0]   b_input_store111_channel;
reg   signed  [8:0]   b_input_store112_channel;
reg   signed  [8:0]   b_input_store100_channel;
reg   signed  [8:0]   b_input_store101_channel;
reg   signed  [8:0]   b_input_store102_channel;
reg   signed  [8:0]   b_input_store220_channel;
reg   signed  [8:0]   b_input_store221_channel;
reg   signed  [8:0]   b_input_store222_channel;
reg   signed  [8:0]   b_input_store210_channel;
reg   signed  [8:0]   b_input_store211_channel;
reg   signed  [8:0]   b_input_store212_channel;
reg   signed  [8:0]   b_input_store200_channel;
reg   signed  [8:0]   b_input_store201_channel;
reg   signed  [8:0]   b_input_store202_channel;
reg   signed  [8:0]   b_input_store320_channel;
reg   signed  [8:0]   b_input_store321_channel;
reg   signed  [8:0]   b_input_store322_channel;
reg   signed  [8:0]   b_input_store310_channel;
reg   signed  [8:0]   b_input_store311_channel;
reg   signed  [8:0]   b_input_store312_channel;
reg   signed  [8:0]   b_input_store300_channel;
reg   signed  [8:0]   b_input_store301_channel;  
reg   signed  [8:0]   b_input_store302_channel;
reg   signed  [8:0]   b_input_store420_channel;
reg   signed  [8:0]   b_input_store421_channel;
reg   signed  [8:0]   b_input_store422_channel;
reg   signed  [8:0]   b_input_store410_channel;
reg   signed  [8:0]   b_input_store411_channel;
reg   signed  [8:0]   b_input_store412_channel;
reg   signed  [8:0]   b_input_store400_channel;
reg   signed  [8:0]   b_input_store401_channel;
reg   signed  [8:0]   b_input_store402_channel;
reg   signed  [8:0]   b_input_store520_channel;
reg   signed  [8:0]   b_input_store521_channel;
reg   signed  [8:0]   b_input_store522_channel;
reg   signed  [8:0]   b_input_store510_channel;
reg   signed  [8:0]   b_input_store511_channel;
reg   signed  [8:0]   b_input_store512_channel;
reg   signed  [8:0]   b_input_store500_channel;
reg   signed  [8:0]   b_input_store501_channel;
reg   signed  [8:0]   b_input_store502_channel;



reg         pool_start;
wire [16:0]  pool_result;

reg          input_store_control;

//conv_1 conv_1_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en1),                  // input
//  .wr_data(write_data01),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data01),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_2_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en2),                  // input
//  .wr_data(write_data02),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data02),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_11_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en1),                  // input
//  .wr_data(write_data11),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data11),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_12_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en2),                  // input
//  .wr_data(write_data12),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data12),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_21_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en1),                  // input
//  .wr_data(write_data21),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data21),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_22_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en2),                  // input
//  .wr_data(write_data22),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data22),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_31_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en1),                  // input
//  .wr_data(write_data31),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data31),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_32_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en2),                  // input
//  .wr_data(write_data32),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data32),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_41_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en1),                  // input
//  .wr_data(write_data41),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data41),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_42_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en2),                  // input
//  .wr_data(write_data42),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data42),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_51_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en1),                  // input
//  .wr_data(write_data51),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data51),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//conv_1 conv_52_inst (
//  .clk(sys_clk),                      // input
//  .rst(reset),                      // input
//  .wr_en(wr_en2),                  // input
//  .wr_data(write_data52),              // input [7:0]
//  .wr_full(),              // output
//  .almost_full(),      // output
//  .rd_en(rd_en),                  // input
//  .rd_data(rd_data52),              // output [7:0]
//  .rd_empty(),            // output
//  .almost_empty()     // output
//);
//
//mul_good mul_good_inst0
//(
//    .sys_clk(sys_clk)       ,
//    .rst_n  (rst_n)        ,
//    .mul_1 (cal_input_store000),
//    .mul_2 (cal_input_store001),
//    .mul_3 (cal_input_store002),
//    .mul_4 (cal_input_store010),
//    .mul_5 (cal_input_store011),
//    .mul_6 (cal_input_store012),
//    .mul_7 (cal_input_store020),
//    .mul_8 (cal_input_store021),
//    .mul_9 (cal_input_store022),
//    .mul_11(cal_kernal000),
//    .mul_22(cal_kernal001),
//    .mul_33(cal_kernal002),
//    .mul_44(cal_kernal010),
//    .mul_55(cal_kernal011),
//    .mul_66(cal_kernal012),
//    .mul_77(cal_kernal020),
//    .mul_88(cal_kernal021),
//    .mul_99(cal_kernal022),    
//    . mul_S(data_store0)
//);
//mul_good mul_good_inst1
//(
//    .sys_clk(sys_clk)       ,
//    .rst_n  (rst_n)        ,
//    .mul_1 (cal_input_store100),
//    .mul_2 (cal_input_store101),
//    .mul_3 (cal_input_store102),
//    .mul_4 (cal_input_store110),
//    .mul_5 (cal_input_store111),
//    .mul_6 (cal_input_store112),
//    .mul_7 (cal_input_store120),
//    .mul_8 (cal_input_store121),
//    .mul_9 (cal_input_store122),
//    .mul_11(cal_kernal100),
//    .mul_22(cal_kernal101),
//    .mul_33(cal_kernal102),
//    .mul_44(cal_kernal110),
//    .mul_55(cal_kernal111),
//    .mul_66(cal_kernal112),
//    .mul_77(cal_kernal120),
//    .mul_88(cal_kernal121),
//    .mul_99(cal_kernal122),    
//    . mul_S(data_store1)
//);
//mul_good mul_good_inst2
//(
//    .sys_clk(sys_clk)       ,
//    .rst_n  (rst_n)        ,
//    .mul_1 (cal_input_store200),
//    .mul_2 (cal_input_store201),
//    .mul_3 (cal_input_store202),
//    .mul_4 (cal_input_store210),
//    .mul_5 (cal_input_store211),
//    .mul_6 (cal_input_store212),
//    .mul_7 (cal_input_store220),
//    .mul_8 (cal_input_store221),
//    .mul_9 (cal_input_store222),
//    .mul_11(cal_kernal200),
//    .mul_22(cal_kernal201),
//    .mul_33(cal_kernal202),
//    .mul_44(cal_kernal210),
//    .mul_55(cal_kernal211),
//    .mul_66(cal_kernal212),
//    .mul_77(cal_kernal220),
//    .mul_88(cal_kernal221),
//    .mul_99(cal_kernal022),    
//    . mul_S(data_store2)
//);
//mul_good mul_good_inst3
//(
//    .sys_clk(sys_clk)       ,
//    .rst_n  (rst_n)        ,
//    .mul_1 (cal_input_store300),
//    .mul_2 (cal_input_store301),
//    .mul_3 (cal_input_store302),
//    .mul_4 (cal_input_store310),
//    .mul_5 (cal_input_store311),
//    .mul_6 (cal_input_store312),
//    .mul_7 (cal_input_store320),
//    .mul_8 (cal_input_store321),
//    .mul_9 (cal_input_store322),
//    .mul_11(cal_kernal300),
//    .mul_22(cal_kernal301),
//    .mul_33(cal_kernal302),
//    .mul_44(cal_kernal310),
//    .mul_55(cal_kernal311),
//    .mul_66(cal_kernal312),
//    .mul_77(cal_kernal320),
//    .mul_88(cal_kernal321),
//    .mul_99(cal_kernal322),    
//    . mul_S(data_store3)
//);
//mul_good mul_good_inst4
//(
//    .sys_clk(sys_clk)       ,
//    .rst_n  (rst_n)        ,
//    .mul_1 (cal_input_store400),
//    .mul_2 (cal_input_store401),
//    .mul_3 (cal_input_store402),
//    .mul_4 (cal_input_store410),
//    .mul_5 (cal_input_store411),
//    .mul_6 (cal_input_store412),
//    .mul_7 (cal_input_store420),
//    .mul_8 (cal_input_store421),
//    .mul_9 (cal_input_store422),
//    .mul_11(cal_kernal400),
//    .mul_22(cal_kernal401),
//    .mul_33(cal_kernal402),
//    .mul_44(cal_kernal410),
//    .mul_55(cal_kernal411),
//    .mul_66(cal_kernal412),
//    .mul_77(cal_kernal420),
//    .mul_88(cal_kernal421),
//    .mul_99(cal_kernal422),    
//    . mul_S(data_store4)
//);
//mul_good mul_good_inst5
//(
//    .sys_clk(sys_clk)       ,
//    .rst_n  (rst_n)        ,
//    .mul_1 (cal_input_store500),
//    .mul_2 (cal_input_store501),
//    .mul_3 (cal_input_store502),
//    .mul_4 (cal_input_store510),
//    .mul_5 (cal_input_store511),
//    .mul_6 (cal_input_store512),
//    .mul_7 (cal_input_store520),
//    .mul_8 (cal_input_store521),
//    .mul_9 (cal_input_store522),
//    .mul_11(cal_kernal500),
//    .mul_22(cal_kernal501),
//    .mul_33(cal_kernal502),
//    .mul_44(cal_kernal510),
//    .mul_55(cal_kernal511),
//    .mul_66(cal_kernal512),
//    .mul_77(cal_kernal520),
//    .mul_88(cal_kernal521),
//    .mul_99(cal_kernal522),    
//    . mul_S(data_store5)
//);

// 状态机
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        begin
            state <= R_IDLE;
            read_finish <= 1'b0;
            write_data01 <= 1'b0;
            write_data02 <= 1'b0;
            write_data11 <= 1'b0;
            write_data12 <= 1'b0;
            write_data21 <= 1'b0;
            write_data22 <= 1'b0;
            write_data31 <= 1'b0;
            write_data32 <= 1'b0;
            write_data41 <= 1'b0;
            write_data42 <= 1'b0;
            write_data51 <= 1'b0;
            write_data52 <= 1'b0;     
        end    
    else if(sd_write_finish == 1'b0)
        begin
            state <= R_IDLE;
        end
    else 
        case(state)
            R_IDLE:
            begin
                state <= R_KERNAL_INIT;//state <= R_INPUT 
            end
            R_KERNAL_INIT:
            begin
                if(kernal_init_finish == 1'b1)
                    begin
                        state <= R_KERNAL;
                    end
                else
                    begin
                    state <= R_KERNAL_INIT;    
                    //kernal[0][0][0][0] <= read_data; 
                    end       
            end
            R_KERNAL:
            begin
                if(num_cnt == 3 * 3 * IN_K_SIZE * 32)//num_cnt == 3 * 3 * IN_K_SIZE * 32
                    begin
                        state <= R_M_INIT;
                    end
                else
                    begin
                        case(j_cnt)
                            12'd0 : kernal000[a_cnt] <= read_data;
                            12'd1 : kernal001[a_cnt] <= read_data;
                            12'd2 : kernal002[a_cnt] <= read_data;
                            12'd3 : kernal010[a_cnt] <= read_data;
                            12'd4 : kernal011[a_cnt] <= read_data;
                            12'd5 : kernal012[a_cnt] <= read_data;
                            12'd6 : kernal020[a_cnt] <= read_data;
                            12'd7 : kernal021[a_cnt] <= read_data;
                            12'd8 : kernal022[a_cnt] <= read_data;
                            12'd9 : kernal100[a_cnt] <= read_data;
                            12'd10: kernal101[a_cnt] <= read_data;
                            12'd11: kernal102[a_cnt] <= read_data;
                            12'd12: kernal110[a_cnt] <= read_data;
                            12'd13: kernal111[a_cnt] <= read_data;
                            12'd14: kernal112[a_cnt] <= read_data;
                            12'd15: kernal120[a_cnt] <= read_data;
                            12'd16: kernal121[a_cnt] <= read_data;
                            12'd17: kernal122[a_cnt] <= read_data;
                            12'd18: kernal200[a_cnt] <= read_data;
                            12'd19: kernal201[a_cnt] <= read_data;
                            12'd20: kernal202[a_cnt] <= read_data;
                            12'd21: kernal210[a_cnt] <= read_data;
                            12'd22: kernal211[a_cnt] <= read_data;
                            12'd23: kernal212[a_cnt] <= read_data;
                            12'd24: kernal220[a_cnt] <= read_data;
                            12'd25: kernal221[a_cnt] <= read_data;
                            12'd26: kernal222[a_cnt] <= read_data;
                            12'd27: kernal300[a_cnt] <= read_data;
                            12'd28: kernal301[a_cnt] <= read_data;
                            12'd29: kernal302[a_cnt] <= read_data;
                            12'd30: kernal310[a_cnt] <= read_data;
                            12'd31: kernal311[a_cnt] <= read_data;
                            12'd32: kernal312[a_cnt] <= read_data;
                            12'd33: kernal320[a_cnt] <= read_data;
                            12'd34: kernal321[a_cnt] <= read_data;
                            12'd35: kernal322[a_cnt] <= read_data;
                            12'd36: kernal400[a_cnt] <= read_data;
                            12'd37: kernal401[a_cnt] <= read_data;
                            12'd38: kernal402[a_cnt] <= read_data;
                            12'd39: kernal410[a_cnt] <= read_data;
                            12'd40: kernal411[a_cnt] <= read_data;
                            12'd41: kernal412[a_cnt] <= read_data;
                            12'd42: kernal420[a_cnt] <= read_data;
                            12'd43: kernal421[a_cnt] <= read_data;
                            12'd44: kernal422[a_cnt] <= read_data;
                            12'd45: kernal500[a_cnt] <= read_data;
                            12'd46: kernal501[a_cnt] <= read_data;
                            12'd47: kernal502[a_cnt] <= read_data;
                            12'd48: kernal510[a_cnt] <= read_data;
                            12'd49: kernal511[a_cnt] <= read_data;
                            12'd50: kernal512[a_cnt] <= read_data;
                            12'd51: kernal520[a_cnt] <= read_data;
                            12'd52: kernal521[a_cnt] <= read_data;
                            12'd53: kernal522[a_cnt] <= read_data;
                            12'd54: kernal600[a_cnt] <= read_data;
                            12'd55: kernal601[a_cnt] <= read_data;
                            12'd56: kernal602[a_cnt] <= read_data;
                            12'd57: kernal610[a_cnt] <= read_data;
                            12'd58: kernal611[a_cnt] <= read_data;
                            12'd59: kernal612[a_cnt] <= read_data;
                            12'd60: kernal620[a_cnt] <= read_data;
                            12'd61: kernal621[a_cnt] <= read_data;
                            12'd62: kernal622[a_cnt] <= read_data;
                            12'd63: kernal700[a_cnt] <= read_data;
                            12'd64: kernal701[a_cnt] <= read_data;
                            12'd65: kernal702[a_cnt] <= read_data;
                            12'd66: kernal710[a_cnt] <= read_data;
                            12'd67: kernal711[a_cnt] <= read_data;
                            12'd68: kernal712[a_cnt] <= read_data;
                            12'd69: kernal720[a_cnt] <= read_data;
                            12'd70: kernal721[a_cnt] <= read_data;
                            12'd71: kernal722[a_cnt] <= read_data;
                            12'd72: kernal800[a_cnt] <= read_data;
                            12'd73: kernal801[a_cnt] <= read_data;
                            12'd74: kernal802[a_cnt] <= read_data;
                            12'd75: kernal810[a_cnt] <= read_data;
                            12'd76: kernal811[a_cnt] <= read_data;
                            12'd77: kernal812[a_cnt] <= read_data;
                            12'd78: kernal820[a_cnt] <= read_data;
                            12'd79: kernal821[a_cnt] <= read_data;
                            12'd80: kernal822[a_cnt] <= read_data;
                            12'd81: kernal900[a_cnt] <= read_data;
                            12'd82: kernal901[a_cnt] <= read_data;
                            12'd83: kernal902[a_cnt] <= read_data;
                            12'd84: kernal910[a_cnt] <= read_data;
                            12'd85: kernal911[a_cnt] <= read_data;
                            12'd86: kernal912[a_cnt] <= read_data;
                            12'd87: kernal920[a_cnt] <= read_data;
                            12'd88: kernal921[a_cnt] <= read_data;
                            12'd89: kernal922[a_cnt] <= read_data;
                            12'd90: kernal1000[a_cnt] <= read_data;
                            12'd91: kernal1001[a_cnt] <= read_data;
                            12'd92: kernal1002[a_cnt] <= read_data;
                            12'd93: kernal1010[a_cnt] <= read_data;
                            12'd94: kernal1011[a_cnt] <= read_data;
                            12'd95: kernal1012[a_cnt] <= read_data;
                            12'd96: kernal1020[a_cnt] <= read_data;
                            12'd97: kernal1021[a_cnt] <= read_data;
                            12'd98: kernal1022[a_cnt] <= read_data;
                            12'd99: kernal1100[a_cnt] <= read_data;
                            12'd100: kernal1101[a_cnt] <= read_data;
                            12'd101: kernal1102[a_cnt] <= read_data;
                            12'd102: kernal1110[a_cnt] <= read_data;
                            12'd103: kernal1111[a_cnt] <= read_data;
                            12'd104: kernal1112[a_cnt] <= read_data;
                            12'd105: kernal1120[a_cnt] <= read_data;
                            12'd106: kernal1121[a_cnt] <= read_data;
                            12'd107: kernal1122[a_cnt] <= read_data;
                            12'd108: kernal1200[a_cnt] <= read_data;
                            12'd109: kernal1201[a_cnt] <= read_data;
                            12'd110: kernal1202[a_cnt] <= read_data;
                            12'd111: kernal1210[a_cnt] <= read_data;
                            12'd112: kernal1211[a_cnt] <= read_data;
                            12'd113: kernal1212[a_cnt] <= read_data;
                            12'd114: kernal1220[a_cnt] <= read_data;
                            12'd115: kernal1221[a_cnt] <= read_data;
                            12'd116: kernal1222[a_cnt] <= read_data;
                            12'd117: kernal1300[a_cnt] <= read_data;
                            12'd118: kernal1301[a_cnt] <= read_data;
                            12'd119: kernal1302[a_cnt] <= read_data;
                            12'd120: kernal1310[a_cnt] <= read_data;
                            12'd121: kernal1311[a_cnt] <= read_data;
                            12'd122: kernal1312[a_cnt] <= read_data;
                            12'd123: kernal1320[a_cnt] <= read_data;
                            12'd124: kernal1321[a_cnt] <= read_data;
                            12'd125: kernal1322[a_cnt] <= read_data;
                            12'd126: kernal1400[a_cnt] <= read_data;
                            12'd127: kernal1401[a_cnt] <= read_data;
                            12'd128: kernal1402[a_cnt] <= read_data; 
                            12'd129: kernal1410[a_cnt] <= read_data;
                            12'd130: kernal1411[a_cnt] <= read_data;
                            12'd131: kernal1412[a_cnt] <= read_data;
                            12'd132: kernal1420[a_cnt] <= read_data;
                            12'd133: kernal1421[a_cnt] <= read_data;
                            12'd134: kernal1422[a_cnt] <= read_data;
                            12'd135: kernal1500[a_cnt] <= read_data;
                            12'd136: kernal1501[a_cnt] <= read_data;
                            12'd137: kernal1502[a_cnt] <= read_data;
                            12'd138: kernal1510[a_cnt] <= read_data;
                            12'd139: kernal1511[a_cnt] <= read_data;
                            12'd140: kernal1512[a_cnt] <= read_data;
                            12'd141: kernal1520[a_cnt] <= read_data;
                            12'd142: kernal1521[a_cnt] <= read_data;
                            12'd143: kernal1522[a_cnt] <= read_data;                      
                            default: kernal000[0] <= 8'd2;
                        endcase
                    end
            end
            R_M_INIT:
            begin
                if(M_init_finish == 1'b1)
                    state <= R_M;
                else
                    state <= R_M_INIT;                        
            end
            R_M:
            begin
                if(num_cnt == 512 )
                    begin
                        state <= R_BIAS_INIT;
                    end
                else   
                    begin
                        M[j_cnt][i_cnt] <= read_data[0];
                    end
            end
            R_BIAS_INIT:
            begin
                if(BIAS_init_finish == 1'b1)
                    state <= R_BIAS;
                else
                    state <= R_BIAS_INIT;                        
            end
            R_BIAS:
            begin
                if(num_cnt == 1024 )
                    begin
                        state <= R_END;
                    end
                else   
                    begin
                        bias[j_cnt][i_cnt] <= read_data[0];
                    end
            
            end
            R_END:
            begin
                read_finish <= 1'b1;
                state <= CAL;
            end
            CAL:
            begin
                if((num_cnt ==  ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)+5)))//num_cnt == IN_IJ_SIZE * IN_IJ_SIZE * IN_K_SIZE
                    begin
                        state <= C_END;
                    end
                else
                    begin
                        if((num_cnt >= 1'b1 )&&(num_cnt <((IN_IJ_SIZE+2)*2+1)))
                            begin
                                write_data01 <=  input_write0;
                                write_data11 <=  input_write1;
                                write_data21 <=  input_write2;
                                write_data31 <=  input_write3;
                                write_data41 <=  input_write4;
                                write_data51 <=  input_write5;
                            end
                        else    if(((num_cnt >= ((IN_IJ_SIZE+2)*2+1))) && (num_cnt <((IN_IJ_SIZE+2)*4+1)))
                            begin
                                write_data02 <=  input_write0;
                                write_data12 <=  input_write1;
                                write_data22 <=  input_write2;
                                write_data32 <=  input_write3;
                                write_data42 <=  input_write4;
                                write_data52 <=  input_write5;
                            end
                        else    if((num_cnt >=((IN_IJ_SIZE+2)*4+1))&&(num_cnt <= ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +1)+5)))
                            begin
                                write_data01 <= rd_data02;
                                write_data02 <= input_write0;
                                write_data11 <= rd_data12;
                                write_data12 <= input_write1;
                                write_data21 <= rd_data22;
                                write_data22 <= input_write2;
                                write_data31 <= rd_data32;
                                write_data32 <= input_write3;
                                write_data41 <= rd_data42;
                                write_data42 <= input_write4;
                                write_data51 <= rd_data52;
                                write_data52 <= input_write5;                              
                            end
                        else
                            begin
                                write_data01 <= 1'b0;
                                write_data02 <= 1'b0;
                                write_data11 <= 1'b0;
                                write_data12 <= 1'b0;
                                write_data21 <= 1'b0;
                                write_data22 <= 1'b0;
                                write_data31 <= 1'b0;
                                write_data32 <= 1'b0;
                                write_data41 <= 1'b0;
                                write_data42 <= 1'b0;
                                write_data51 <= 1'b0;
                                write_data52 <= 1'b0;                          
                            end
                    end                
            end
            C_BIAS:
            begin
                if(cal_finish == 1'b1)
                    state <= C_END;
                else
                    state <= C_BIAS;
            end
            C_END:
            begin
                state <= C_END;
            end
            
   
            default:
            begin
                read_finish <= 1'b0;
            end
    endcase
end

//模拟生成输入数

simulate    simulate_inst_0
(
    .sys_clk    (sys_clk) ,
    .rst_n      (rst_n) ,
    .num_cnt    (num_cnt) ,
    .sim_read_en(sim_read_en),
    .a_cnt      (a_cnt),
    .input_store_control(input_store_control),
    .state      (state),

    .input_write(input_write0)  
);
simulate    simulate_inst_1
(
    .sys_clk    (sys_clk) ,
    .rst_n      (rst_n) ,
    .num_cnt    (num_cnt) ,
    .sim_read_en(sim_read_en),
    .a_cnt      (a_cnt),
    .input_store_control(input_store_control),
    .state(state),

    .input_write(input_write1)  
);
simulate    simulate_inst_2
(
    .sys_clk    (sys_clk) ,
    .rst_n      (rst_n) ,
    .num_cnt    (num_cnt) ,
    .sim_read_en(sim_read_en),
    .a_cnt      (a_cnt),
    .input_store_control(input_store_control),  
    .state(state),

    .input_write(input_write2)  
);
simulate    simulate_inst_3
(
    .sys_clk    (sys_clk) ,
    .rst_n      (rst_n) ,
    .num_cnt    (num_cnt) ,
    .sim_read_en(sim_read_en),
    .a_cnt      (a_cnt),
    .input_store_control(input_store_control),    
    .state(state),
    
    .input_write(input_write3)  
);
simulate    simulate_inst_4
(
    .sys_clk    (sys_clk) ,
    .rst_n      (rst_n) ,
    .num_cnt    (num_cnt) ,
    .sim_read_en(sim_read_en),
    .a_cnt      (a_cnt),
    .input_store_control(input_store_control),
    .state(state),

    .input_write(input_write4)  
);
simulate    simulate_inst_5
(
    .sys_clk    (sys_clk) ,
    .rst_n      (rst_n) ,
    .num_cnt    (num_cnt) ,
    .sim_read_en(sim_read_en),
    .a_cnt      (a_cnt),
    .input_store_control(input_store_control),
    .state(state),
    
    .input_write(input_write5)  
);


//ddr_read
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
    begin
        read_dly <= 1'b0;
    end
    else    if(state == R_KERNAL_INIT )
    begin
        if(conv_read_req_ack == 1'b1)
        begin
            read_dly <= 1'b1;
        end
        else
        begin
            read_dly <= read_dly;
        end
    end
    else
    begin
        read_dly <= 1'b0;
    end  
end

always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
    begin
        conv_read_req <= 1'b0;  
    end
    else    if(state == R_KERNAL_INIT )
    begin
        if(conv_read_req_ack == 1'b1)
        begin
            conv_read_req <= 1'b0;
        end
        else    if(read_dly == 1'b0 && conv_read_req_ack == 1'b0 )
        begin
            conv_read_req <= 1'b1;
        end
        else
        begin
            conv_read_req <= 1'b0;
        end
    end
    else
    begin
        conv_read_req <= 1'b0;
    end  
end

//下一个时钟周期开始计数与传递信号，所以计数值加一 num_cnt
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
        begin
            num_cnt <= 1'b0;
            read_en <= 1'b0;
            kernal_init_finish <= 1'b0;
            M_init_finish <= 1'b0;
            BIAS_init_finish <= 1'b0;  
        end
    else    if(state == R_KERNAL_INIT)
        begin
            if(read_dly == 1'b1)
            begin
                if(num_cnt == DELAY)
                begin
                    kernal_init_finish <= 1'b1;
                    num_cnt <= 1'b0;
                end
                else
                begin
                    num_cnt <= num_cnt + 1'b1;
                    kernal_init_finish <= 1'b0;
                end
            end
            else
            begin
                num_cnt <= 1'b0;
                kernal_init_finish <= 1'b0;
                if(conv_read_req_ack == 1'b1)
                    read_en <= 1'b1;
                else
                    read_en <= read_en;
            end
        end
    else    if(state == R_KERNAL)
        begin
            if(num_cnt == 3 * 3 * IN_K_SIZE * 32 )
            begin
                num_cnt <= 1'b0;
                read_en <= 1'b0;
            end
            else
                begin
                num_cnt <= num_cnt + 1'b1;
                read_en <= 1'b1;
                end
        end   
    else    if(state == R_M_INIT)
        begin
            num_cnt <= 1'b0;
            M_init_finish <= 1'b1;
        end
    else    if(state == R_M)
        begin
        if(num_cnt == 512 )
            begin
                num_cnt <= 1'b0;
                read_en <= 1'b0;
            end
            else
                begin
                num_cnt <= num_cnt + 1'b1;
                read_en <= 1'b1;
                end
        end
    else    if(state == R_BIAS_INIT)
        begin
            num_cnt <= 1'b0;
            BIAS_init_finish <= 1'b1;
        end
    else    if(state == R_BIAS)
        begin
         if(num_cnt == 1024)
            begin
                num_cnt <= 1'b0;
                read_en <= 1'b0;
            end
            else
                begin
                num_cnt <= num_cnt + 1'b1;
                read_en <= 1'b1;
                end           
        end
    else    if(state == R_END)
        begin
            num_cnt <= 1'b0;
            read_en <= 1'b0;
        end
    else    if(state == CAL)
        begin  
           if(num_cnt == ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2) +5))
                begin
                    num_cnt <= 1'b0;       
                end
           else  if(num_cnt >= 1'b0 && num_cnt <= 32'd845)
                begin
                    num_cnt <= num_cnt + 1'b1;
                end   
            else    if((num_cnt >= (IN_IJ_SIZE +2)*2*2+6 )&& num_cnt <= ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)+5))
                begin
                    if(a_cnt == 31 && input_store_control== 1'b1)
                        num_cnt <= num_cnt + 1'b1;
                    else
                        num_cnt <= num_cnt;
                end
            begin
                
            end
        end 
    else
    begin
        num_cnt <= 1'b0;
    end    
        
end

//原计划846赋值给cal,开始算，等3个周期（849）出结果 ，delay，850出最后结果
//模拟ddr读使能
always@(posedge    sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0||num_cnt==32'd0)
    begin
        sim_read_en <= 1'b0;
    end
    else    if(state == CAL && num_cnt >= 32'd1)
    begin
        if(num_cnt >= (IN_IJ_SIZE+2)*2*2+6)
        begin
            if(a_cnt == 31 &&input_store_control == 1'b1)
                begin
                    sim_read_en<= 1'b1;                     
                end
            else    if(a_cnt == 1'b0 && input_store_control == 1'b0)
                begin
                    sim_read_en<= 1'b1;  
                end
            else    
                begin
                    sim_read_en<= 1'b0;
                end
        end
        else
        begin
            sim_read_en<= 1'b1; 
        end 
    end
    else
        sim_read_en <= sim_read_en;
end       

// i_cnt
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
        begin
            i_cnt <= 1'b1;
        end
    else    if(state == R_INPUT)
        begin
            if(read_en == 1'b1 )
            begin
                if(i_cnt == IN_IJ_SIZE )
                    begin
                        i_cnt <= 1'b1;
                    end
                else
                    begin
                        i_cnt <= i_cnt + 1'b1;
                    end
            end
            else
                i_cnt <= 1'b1;
        end 
    else    if(state == R_KERNAL_INIT)
        begin
            i_cnt <= 1'b0;
        end
    else    if(state == R_KERNAL)
        begin
            if(read_en == 1'b1)
            begin
                if(i_cnt == 9'd8 )
                    begin
                        i_cnt <= 1'b0;
                    end
                else
                    begin
                        i_cnt <= i_cnt + 1'b1;
                    end
            end
            else
                i_cnt <= 1'b0;
        end
    else    if(state == R_M_INIT)
        begin
            i_cnt <= 12'd15;
        end
    else    if(state == R_M)
        begin
            if(i_cnt == 9'd0 )
                begin
                    i_cnt <= 12'd15;
                end
            else
                begin
                    i_cnt <= i_cnt - 1'b1;
                end
        end
    else    if(state == R_BIAS_INIT)
        begin
            i_cnt <= 12'd31;
        end
    else    if(state == R_BIAS)
        begin
         if(i_cnt == 9'd0 )
            begin
                i_cnt <= 12'd31;
            end
        else
            begin
                i_cnt <= i_cnt - 1'b1;
            end
        end
    else    if(state == R_END )
        begin
            i_cnt <= 12'd207;
        end
    else
        begin
            i_cnt <= 1'b0;      
        end 
end 

//j_Cnt 
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0)
        begin
            j_cnt <= 1'b1;
        end
    else    if(state == R_INPUT)
        begin 
            if((i_cnt == IN_IJ_SIZE )&&(j_cnt == IN_IJ_SIZE ))
                j_cnt <= 1'b1;
            else    if(i_cnt == IN_IJ_SIZE)
                j_cnt <= j_cnt + 1'b1;
            else
                j_cnt <= j_cnt;              
        end 
    else    if(state == R_KERNAL_INIT)
    begin
        j_cnt <= 1'b0;
    end
    else    if(state == R_KERNAL)
    begin
        if(j_cnt == 3*3 * IN_K_SIZE -1)
            begin
                j_cnt <= 1'b0;
            end
        else   
            begin
                j_cnt <= j_cnt + 1'b1;
            end  
    end
    else    if(state == R_M_INIT)
        begin
            j_cnt <= 1'b0;
        end
    else    if(state == R_M)
        begin
            if((i_cnt == 12'd0 )&&(j_cnt == 12'd31 ))
                j_cnt <= 1'b0;
            else    if(i_cnt == 12'd0)
                j_cnt <= j_cnt + 1'b1;
            else
                j_cnt <= j_cnt;  
        end
    else    if(state == R_BIAS_INIT)
        begin
            j_cnt <= 1'b0;
        end
    else    if(state == R_BIAS)
        begin
            if((i_cnt == 12'd0 )&&(j_cnt == 12'd31 ))
                j_cnt <= 1'b0;
            else    if(i_cnt == 12'd0)
                j_cnt <= j_cnt + 1'b1;
            else
                j_cnt <= j_cnt;              
        end
    else    if(state == R_END)
        begin
            j_cnt <= 12'd207;
        end
    else
            j_cnt <= j_cnt;
end            

//k_cnt
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
        begin
            k_cnt <= 1'b0;
        end
    else    if(state == R_INPUT)
    begin
        if((i_cnt == IN_IJ_SIZE )&&(j_cnt == IN_IJ_SIZE )&&(k_cnt == IN_K_SIZE-1'b1))
            begin
                k_cnt <= 1'b0;
            end
        else    if((i_cnt == IN_IJ_SIZE ) && (j_cnt  == IN_IJ_SIZE ))
            k_cnt <= k_cnt + 1'b1;
        else
            k_cnt <= k_cnt;
    end
    else    if(state == R_KERNAL_INIT)
        begin
            k_cnt <= 1'b0;
        end
    else    if(state == R_KERNAL)
        begin
            if((i_cnt == 9'd8 )&&(k_cnt == IN_K_SIZE-1'b1))
                begin
                    k_cnt <= 1'b0;
                end
            else    if(i_cnt == 9'd8 )
                k_cnt <= k_cnt + 1'b1;
            else
                k_cnt <= k_cnt;
        end
    else    if(state == R_END)
        k_cnt <= 1'b0;
    else    if(state == CAL)
        begin
            k_cnt <= 1'b0;
        end
    else    
            k_cnt <= 1'b0;
end            

//kernal_use_cnt            
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
        begin
            a_cnt <= 1'b0;
            mul_finish <= 1'b0;
            sum_finish <= 1'b0;
        end
    else    if(state == R_KERNAL)   
        begin
        if((j_cnt == 3*3 * IN_K_SIZE-1)&&(a_cnt == FILTER_NUM -1'b1))
                begin
                    a_cnt <= 1'b0;
                end
            else    if(j_cnt == 3*3 * IN_K_SIZE-1)
                a_cnt <= a_cnt + 1'b1;
            else
                a_cnt <= a_cnt;
        end
    else    if(state == CAL)
        begin
            if(num_cnt >= (IN_IJ_SIZE+2)*2*2+6)
            begin
                if(a_cnt == 31&&input_store_control== 1'b1)
                    a_cnt <= 1'b0;
                else    if(input_store_control== 1'b1)
                    a_cnt <= a_cnt + 1'b1;
                else  
                    a_cnt <= a_cnt;
            end
            else
            begin
                a_cnt <= a_cnt;
            end
        end
    else    if(state == C_BIAS)
        begin
            if((i_cnt == IN_IJ_SIZE - 1'b1 )&&(j_cnt == IN_IJ_SIZE - 1'b1 )&&(a_cnt == FILTER_NUM -1'b1))
            begin
                a_cnt <= 1'b0;
                cal_finish <= 1'b1;
            end
            else    if((i_cnt == IN_IJ_SIZE - 1'b1 ) && (j_cnt  == IN_IJ_SIZE - 1'b1 ))
            a_cnt <= a_cnt + 1'b1;
            else
            a_cnt <= a_cnt;
        end
    else
        begin
            a_cnt <= 1'b0;
        end
end

// write_en
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 ||state ==R_IDLE)
        begin
            wr_en1<= 1'b0;
            wr_en2<= 1'b0;     
        end
    else    if((state == CAL)&&(num_cnt >= 1'b1 )&&(num_cnt <((IN_IJ_SIZE+2)*2+1)) )
        begin
            wr_en1 <= 1'b1;
            wr_en2 <= 1'b0;
        end
    else    if((state == CAL)&&(num_cnt >= ((IN_IJ_SIZE+2)*2+1))&&(num_cnt <((IN_IJ_SIZE+2)*4+2)))
        begin
            wr_en1 <= 1'b0;
            wr_en2 <= 1'b1;
        end
    else    if((state == CAL)&&(num_cnt >=((IN_IJ_SIZE+2)*4+1))&&(num_cnt <= ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)*2)))
        begin
            if(num_cnt >= (IN_IJ_SIZE+2)*2*2+2)
            begin
                if(a_cnt == 1'b0 )
                    begin
                        wr_en1<= 1'b1;
                        wr_en2<= 1'b1;
                    end
                else
                    begin
                        wr_en1<= 1'b0;
                        wr_en2<= 1'b0;  
                    end
            end
            else
            begin
                wr_en1<= 1'b1;
                wr_en2<= 1'b1;    
            end 
        end
    else
        begin
            wr_en1<= 1'b0;
            wr_en2<= 1'b0;         
        end
end


//rd_en
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
        begin
            rd_en <= 1'b0;
        end
    else    if((state == CAL)&&(num_cnt >= 1'b0 )&&(num_cnt <((IN_IJ_SIZE+2)*4+1)) )
        begin
            rd_en <= 1'b0;
        end
    else    if(state == CAL)
        begin
            if(num_cnt >= (IN_IJ_SIZE+2)*2*2+6)
            begin
                if((a_cnt == 31 &&input_store_control == 1'b1 )||(a_cnt==0&&input_store_control == 1'b0))
                    begin
                        rd_en<= 1'b1;                     
                    end
                else
                    begin
                        rd_en<= 1'b0;
                    end
            end
            else
            begin
                rd_en<= 1'b1; 
            end 
        end
    else
        begin
            rd_en <= 1'b0;
        end        

end

//reset

always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
        begin
            reset <= 1'b1;
        end
    else     if((num_cnt == ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)+5))||(num_cnt ==1'b0))
        begin
            reset <= 1'b1;
        end
    else    
            reset <= 1'b0;
end

/////////////////////////////////////////////calculate/////////////////////////////////////////////////////////////////////////////////

//input_store_control
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
    begin
        input_store_control <= 1'b0;
    end
    else    if(state == CAL &&((num_cnt >=((IN_IJ_SIZE+2)*4+2)))&&(num_cnt <=(IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)+5))
    begin
        input_store_control <= ~input_store_control;
    end
    else
        input_store_control <= 1'b0;
        

end
//cal_input_store  
assign     cal_input_store020  = (input_store_control== 1'b0)?f_input_store020_channel:b_input_store020_channel;
assign     cal_input_store021  = (input_store_control== 1'b0)?f_input_store021_channel:b_input_store021_channel;
assign     cal_input_store022  = (input_store_control== 1'b0)?f_input_store022_channel:b_input_store022_channel;
assign     cal_input_store010  = (input_store_control== 1'b0)?f_input_store010_channel:b_input_store010_channel;
assign     cal_input_store011  = (input_store_control== 1'b0)?f_input_store011_channel:b_input_store011_channel;
assign     cal_input_store012  = (input_store_control== 1'b0)?f_input_store012_channel:b_input_store012_channel;
assign     cal_input_store000  = (input_store_control== 1'b0)?f_input_store000_channel:b_input_store000_channel;
assign     cal_input_store001  = (input_store_control== 1'b0)?f_input_store001_channel:b_input_store001_channel;
assign     cal_input_store002  = (input_store_control== 1'b0)?f_input_store002_channel:b_input_store002_channel;
assign     cal_input_store120  = (input_store_control== 1'b0)?f_input_store120_channel:b_input_store120_channel;
assign     cal_input_store121  = (input_store_control== 1'b0)?f_input_store121_channel:b_input_store121_channel;
assign     cal_input_store122  = (input_store_control== 1'b0)?f_input_store122_channel:b_input_store122_channel;
assign     cal_input_store110  = (input_store_control== 1'b0)?f_input_store110_channel:b_input_store110_channel;
assign     cal_input_store111  = (input_store_control== 1'b0)?f_input_store111_channel:b_input_store111_channel;
assign     cal_input_store112  = (input_store_control== 1'b0)?f_input_store112_channel:b_input_store112_channel;
assign     cal_input_store100  = (input_store_control== 1'b0)?f_input_store100_channel:b_input_store100_channel;
assign     cal_input_store101  = (input_store_control== 1'b0)?f_input_store101_channel:b_input_store101_channel;
assign     cal_input_store102  = (input_store_control== 1'b0)?f_input_store102_channel:b_input_store102_channel;
assign     cal_input_store220  = (input_store_control== 1'b0)?f_input_store220_channel:b_input_store220_channel;
assign     cal_input_store221  = (input_store_control== 1'b0)?f_input_store221_channel:b_input_store221_channel;
assign     cal_input_store222  = (input_store_control== 1'b0)?f_input_store222_channel:b_input_store222_channel;
assign     cal_input_store210  = (input_store_control== 1'b0)?f_input_store210_channel:b_input_store210_channel;
assign     cal_input_store211  = (input_store_control== 1'b0)?f_input_store211_channel:b_input_store211_channel;
assign     cal_input_store212  = (input_store_control== 1'b0)?f_input_store212_channel:b_input_store212_channel;
assign     cal_input_store200  = (input_store_control== 1'b0)?f_input_store200_channel:b_input_store200_channel;
assign     cal_input_store201  = (input_store_control== 1'b0)?f_input_store201_channel:b_input_store201_channel;
assign     cal_input_store202  = (input_store_control== 1'b0)?f_input_store202_channel:b_input_store202_channel;
assign     cal_input_store320  = (input_store_control== 1'b0)?f_input_store320_channel:b_input_store320_channel;
assign     cal_input_store321  = (input_store_control== 1'b0)?f_input_store321_channel:b_input_store321_channel;
assign     cal_input_store322  = (input_store_control== 1'b0)?f_input_store322_channel:b_input_store322_channel;
assign     cal_input_store310  = (input_store_control== 1'b0)?f_input_store310_channel:b_input_store310_channel;
assign     cal_input_store311  = (input_store_control== 1'b0)?f_input_store311_channel:b_input_store311_channel;
assign     cal_input_store312  = (input_store_control== 1'b0)?f_input_store312_channel:b_input_store312_channel;
assign     cal_input_store300  = (input_store_control== 1'b0)?f_input_store300_channel:b_input_store300_channel;
assign     cal_input_store301  = (input_store_control== 1'b0)?f_input_store301_channel:b_input_store301_channel;
assign     cal_input_store302  = (input_store_control== 1'b0)?f_input_store302_channel:b_input_store302_channel;
assign     cal_input_store420  = (input_store_control== 1'b0)?f_input_store420_channel:b_input_store420_channel;
assign     cal_input_store421  = (input_store_control== 1'b0)?f_input_store421_channel:b_input_store421_channel;
assign     cal_input_store422  = (input_store_control== 1'b0)?f_input_store422_channel:b_input_store422_channel;
assign     cal_input_store410  = (input_store_control== 1'b0)?f_input_store410_channel:b_input_store410_channel;
assign     cal_input_store411  = (input_store_control== 1'b0)?f_input_store411_channel:b_input_store411_channel;
assign     cal_input_store412  = (input_store_control== 1'b0)?f_input_store412_channel:b_input_store412_channel;
assign     cal_input_store400  = (input_store_control== 1'b0)?f_input_store400_channel:b_input_store400_channel;
assign     cal_input_store401  = (input_store_control== 1'b0)?f_input_store401_channel:b_input_store401_channel;
assign     cal_input_store402  = (input_store_control== 1'b0)?f_input_store402_channel:b_input_store402_channel;
assign     cal_input_store520  = (input_store_control== 1'b0)?f_input_store520_channel:b_input_store520_channel;
assign     cal_input_store521  = (input_store_control== 1'b0)?f_input_store521_channel:b_input_store521_channel;
assign     cal_input_store522  = (input_store_control== 1'b0)?f_input_store522_channel:b_input_store522_channel;
assign     cal_input_store510  = (input_store_control== 1'b0)?f_input_store510_channel:b_input_store510_channel;
assign     cal_input_store511  = (input_store_control== 1'b0)?f_input_store511_channel:b_input_store511_channel;
assign     cal_input_store512  = (input_store_control== 1'b0)?f_input_store512_channel:b_input_store512_channel;
assign     cal_input_store500  = (input_store_control== 1'b0)?f_input_store500_channel:b_input_store500_channel;
assign     cal_input_store501  = (input_store_control== 1'b0)?f_input_store501_channel:b_input_store501_channel;
assign     cal_input_store502  = (input_store_control== 1'b0)?f_input_store502_channel:b_input_store502_channel;

always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
    begin
        f_input_store020_channel<=1'b0;
        f_input_store021_channel<=1'b0;
        f_input_store022_channel<=1'b0;
        f_input_store010_channel<=1'b0;
        f_input_store011_channel<=1'b0;
        f_input_store012_channel<=1'b0;
        f_input_store000_channel<=1'b0;
        f_input_store001_channel<=1'b0;
        f_input_store002_channel<=1'b0;
        f_input_store120_channel<=1'b0;
        f_input_store121_channel<=1'b0;
        f_input_store122_channel<=1'b0;
        f_input_store110_channel<=1'b0;
        f_input_store111_channel<=1'b0;
        f_input_store112_channel<=1'b0;
        f_input_store100_channel<=1'b0;
        f_input_store101_channel<=1'b0;
        f_input_store102_channel<=1'b0;
        f_input_store220_channel<=1'b0;
        f_input_store221_channel<=1'b0;
        f_input_store222_channel<=1'b0;
        f_input_store210_channel<=1'b0;
        f_input_store211_channel<=1'b0;
        f_input_store212_channel<=1'b0;
        f_input_store200_channel<=1'b0;
        f_input_store201_channel<=1'b0;
        f_input_store202_channel<=1'b0;
        f_input_store320_channel<=1'b0;
        f_input_store321_channel<=1'b0;
        f_input_store322_channel<=1'b0;
        f_input_store310_channel<=1'b0;
        f_input_store311_channel<=1'b0;
        f_input_store312_channel<=1'b0;
        f_input_store300_channel<=1'b0;
        f_input_store301_channel<=1'b0;  
        f_input_store302_channel<=1'b0;
        f_input_store420_channel<=1'b0;
        f_input_store421_channel<=1'b0;
        f_input_store422_channel<=1'b0;
        f_input_store410_channel<=1'b0;
        f_input_store411_channel<=1'b0;
        f_input_store412_channel<=1'b0;
        f_input_store400_channel<=1'b0;
        f_input_store401_channel<=1'b0;
        f_input_store402_channel<=1'b0;
        f_input_store520_channel<=1'b0;
        f_input_store521_channel<=1'b0;
        f_input_store522_channel<=1'b0;
        f_input_store510_channel<=1'b0;
        f_input_store511_channel<=1'b0;
        f_input_store512_channel<=1'b0;
        f_input_store500_channel<=1'b0;
        f_input_store501_channel<=1'b0;
        f_input_store502_channel<=1'b0;
        b_input_store020_channel<=1'b0;
        b_input_store021_channel<=1'b0;
        b_input_store022_channel<=1'b0;
        b_input_store010_channel<=1'b0;
        b_input_store011_channel<=1'b0;
        b_input_store012_channel<=1'b0;
        b_input_store000_channel<=1'b0;
        b_input_store001_channel<=1'b0;
        b_input_store002_channel<=1'b0;
        b_input_store120_channel<=1'b0;
        b_input_store121_channel<=1'b0;
        b_input_store122_channel<=1'b0;
        b_input_store110_channel<=1'b0;
        b_input_store111_channel<=1'b0;
        b_input_store112_channel<=1'b0;
        b_input_store100_channel<=1'b0;
        b_input_store101_channel<=1'b0;
        b_input_store102_channel<=1'b0;
        b_input_store220_channel<=1'b0;
        b_input_store221_channel<=1'b0;
        b_input_store222_channel<=1'b0;
        b_input_store210_channel<=1'b0;
        b_input_store211_channel<=1'b0;
        b_input_store212_channel<=1'b0;
        b_input_store200_channel<=1'b0;
        b_input_store201_channel<=1'b0;
        b_input_store202_channel<=1'b0;
        b_input_store320_channel<=1'b0;
        b_input_store321_channel<=1'b0;
        b_input_store322_channel<=1'b0;
        b_input_store310_channel<=1'b0;
        b_input_store311_channel<=1'b0;
        b_input_store312_channel<=1'b0;
        b_input_store300_channel<=1'b0;
        b_input_store301_channel<=1'b0;  
        b_input_store302_channel<=1'b0;
        b_input_store420_channel<=1'b0;
        b_input_store421_channel<=1'b0;
        b_input_store422_channel<=1'b0;
        b_input_store410_channel<=1'b0;
        b_input_store411_channel<=1'b0;
        b_input_store412_channel<=1'b0;
        b_input_store400_channel<=1'b0;
        b_input_store401_channel<=1'b0;
        b_input_store402_channel<=1'b0;
        b_input_store520_channel<=1'b0;
        b_input_store521_channel<=1'b0;
        b_input_store522_channel<=1'b0;
        b_input_store510_channel<=1'b0;
        b_input_store511_channel<=1'b0;
        b_input_store512_channel<=1'b0;
        b_input_store500_channel<=1'b0;
        b_input_store501_channel<=1'b0;
        b_input_store502_channel<=1'b0;  
    end
    else    if(a_cnt == 1'b0 && input_store_control == 1'b1)
    begin
        f_input_store020_channel<=f_input_store020;
        f_input_store021_channel<=f_input_store021;
        f_input_store022_channel<=f_input_store022;
        f_input_store010_channel<=f_input_store010;
        f_input_store011_channel<=f_input_store011;
        f_input_store012_channel<=f_input_store012;
        f_input_store000_channel<=f_input_store000;
        f_input_store001_channel<=f_input_store001;
        f_input_store002_channel<=f_input_store002;
        f_input_store120_channel<=f_input_store120;
        f_input_store121_channel<=f_input_store121;
        f_input_store122_channel<=f_input_store122;
        f_input_store110_channel<=f_input_store110;
        f_input_store111_channel<=f_input_store111;
        f_input_store112_channel<=f_input_store112;
        f_input_store100_channel<=f_input_store100;
        f_input_store101_channel<=f_input_store101;
        f_input_store102_channel<=f_input_store102;
        f_input_store220_channel<=f_input_store220;
        f_input_store221_channel<=f_input_store221;
        f_input_store222_channel<=f_input_store222;
        f_input_store210_channel<=f_input_store210;
        f_input_store211_channel<=f_input_store211;
        f_input_store212_channel<=f_input_store212;
        f_input_store200_channel<=f_input_store200;
        f_input_store201_channel<=f_input_store201;
        f_input_store202_channel<=f_input_store202;
        f_input_store320_channel<=f_input_store320;
        f_input_store321_channel<=f_input_store321;
        f_input_store322_channel<=f_input_store322;
        f_input_store310_channel<=f_input_store310;
        f_input_store311_channel<=f_input_store311;
        f_input_store312_channel<=f_input_store312;
        f_input_store300_channel<=f_input_store300;
        f_input_store301_channel<=f_input_store301;  
        f_input_store302_channel<=f_input_store302;
        f_input_store420_channel<=f_input_store420;
        f_input_store421_channel<=f_input_store421;
        f_input_store422_channel<=f_input_store422;
        f_input_store410_channel<=f_input_store410;
        f_input_store411_channel<=f_input_store411;
        f_input_store412_channel<=f_input_store412;
        f_input_store400_channel<=f_input_store400;
        f_input_store401_channel<=f_input_store401;
        f_input_store402_channel<=f_input_store402;
        f_input_store520_channel<=f_input_store520;
        f_input_store521_channel<=f_input_store521;
        f_input_store522_channel<=f_input_store522;
        f_input_store510_channel<=f_input_store510;
        f_input_store511_channel<=f_input_store511;
        f_input_store512_channel<=f_input_store512;
        f_input_store500_channel<=f_input_store500;
        f_input_store501_channel<=f_input_store501;
        f_input_store502_channel<=f_input_store502;
        b_input_store020_channel<=b_input_store020;
        b_input_store021_channel<=b_input_store021;
        b_input_store022_channel<=b_input_store022;
        b_input_store010_channel<=b_input_store010;
        b_input_store011_channel<=b_input_store011;
        b_input_store012_channel<=b_input_store012;
        b_input_store000_channel<=b_input_store000;
        b_input_store001_channel<=b_input_store001;
        b_input_store002_channel<=b_input_store002;
        b_input_store120_channel<=b_input_store120;
        b_input_store121_channel<=b_input_store121;
        b_input_store122_channel<=b_input_store122;
        b_input_store110_channel<=b_input_store110;
        b_input_store111_channel<=b_input_store111;
        b_input_store112_channel<=b_input_store112;
        b_input_store100_channel<=b_input_store100;
        b_input_store101_channel<=b_input_store101;
        b_input_store102_channel<=b_input_store102;
        b_input_store220_channel<=b_input_store220;
        b_input_store221_channel<=b_input_store221;
        b_input_store222_channel<=b_input_store222;
        b_input_store210_channel<=b_input_store210;
        b_input_store211_channel<=b_input_store211;
        b_input_store212_channel<=b_input_store212;
        b_input_store200_channel<=b_input_store200;
        b_input_store201_channel<=b_input_store201;
        b_input_store202_channel<=b_input_store202;
        b_input_store320_channel<=b_input_store320;
        b_input_store321_channel<=b_input_store321;
        b_input_store322_channel<=b_input_store322;
        b_input_store310_channel<=b_input_store310;
        b_input_store311_channel<=b_input_store311;
        b_input_store312_channel<=b_input_store312;
        b_input_store300_channel<=b_input_store300;
        b_input_store301_channel<=b_input_store301;  
        b_input_store302_channel<=b_input_store302;
        b_input_store420_channel<=b_input_store420;
        b_input_store421_channel<=b_input_store421;
        b_input_store422_channel<=b_input_store422;
        b_input_store410_channel<=b_input_store410;
        b_input_store411_channel<=b_input_store411;
        b_input_store412_channel<=b_input_store412;
        b_input_store400_channel<=b_input_store400;
        b_input_store401_channel<=b_input_store401;
        b_input_store402_channel<=b_input_store402;
        b_input_store520_channel<=b_input_store520;
        b_input_store521_channel<=b_input_store521;
        b_input_store522_channel<=b_input_store522;
        b_input_store510_channel<=b_input_store510;
        b_input_store511_channel<=b_input_store511;
        b_input_store512_channel<=b_input_store512;
        b_input_store500_channel<=b_input_store500;
        b_input_store501_channel<=b_input_store501;
        b_input_store502_channel<=b_input_store502;  
      
    end
    else
    begin
        f_input_store020_channel<=f_input_store020_channel;
        f_input_store021_channel<=f_input_store021_channel;
        f_input_store022_channel<=f_input_store022_channel;
        f_input_store010_channel<=f_input_store010_channel;
        f_input_store011_channel<=f_input_store011_channel;
        f_input_store012_channel<=f_input_store012_channel;
        f_input_store000_channel<=f_input_store000_channel;
        f_input_store001_channel<=f_input_store001_channel;
        f_input_store002_channel<=f_input_store002_channel;
        f_input_store120_channel<=f_input_store120_channel;
        f_input_store121_channel<=f_input_store121_channel;
        f_input_store122_channel<=f_input_store122_channel;
        f_input_store110_channel<=f_input_store110_channel;
        f_input_store111_channel<=f_input_store111_channel;
        f_input_store112_channel<=f_input_store112_channel;
        f_input_store100_channel<=f_input_store100_channel;
        f_input_store101_channel<=f_input_store101_channel;
        f_input_store102_channel<=f_input_store102_channel;
        f_input_store220_channel<=f_input_store220_channel;
        f_input_store221_channel<=f_input_store221_channel;
        f_input_store222_channel<=f_input_store222_channel;
        f_input_store210_channel<=f_input_store210_channel;
        f_input_store211_channel<=f_input_store211_channel;
        f_input_store212_channel<=f_input_store212_channel;
        f_input_store200_channel<=f_input_store200_channel;
        f_input_store201_channel<=f_input_store201_channel;
        f_input_store202_channel<=f_input_store202_channel;
        f_input_store320_channel<=f_input_store320_channel;
        f_input_store321_channel<=f_input_store321_channel;
        f_input_store322_channel<=f_input_store322_channel;
        f_input_store310_channel<=f_input_store310_channel;
        f_input_store311_channel<=f_input_store311_channel;
        f_input_store312_channel<=f_input_store312_channel;
        f_input_store300_channel<=f_input_store300_channel;
        f_input_store301_channel<=f_input_store301_channel;  
        f_input_store302_channel<=f_input_store302_channel;
        f_input_store420_channel<=f_input_store420_channel;
        f_input_store421_channel<=f_input_store421_channel;
        f_input_store422_channel<=f_input_store422_channel;
        f_input_store410_channel<=f_input_store410_channel;
        f_input_store411_channel<=f_input_store411_channel;
        f_input_store412_channel<=f_input_store412_channel;
        f_input_store400_channel<=f_input_store400_channel;
        f_input_store401_channel<=f_input_store401_channel;
        f_input_store402_channel<=f_input_store402_channel;
        f_input_store520_channel<=f_input_store520_channel;
        f_input_store521_channel<=f_input_store521_channel;
        f_input_store522_channel<=f_input_store522_channel;
        f_input_store510_channel<=f_input_store510_channel;
        f_input_store511_channel<=f_input_store511_channel;
        f_input_store512_channel<=f_input_store512_channel;
        f_input_store500_channel<=f_input_store500_channel;
        f_input_store501_channel<=f_input_store501_channel;
        f_input_store502_channel<=f_input_store502_channel;
        b_input_store020_channel<=b_input_store020_channel;
        b_input_store021_channel<=b_input_store021_channel;
        b_input_store022_channel<=b_input_store022_channel;
        b_input_store010_channel<=b_input_store010_channel;
        b_input_store011_channel<=b_input_store011_channel;
        b_input_store012_channel<=b_input_store012_channel;
        b_input_store000_channel<=b_input_store000_channel;
        b_input_store001_channel<=b_input_store001_channel;
        b_input_store002_channel<=b_input_store002_channel;
        b_input_store120_channel<=b_input_store120_channel;
        b_input_store121_channel<=b_input_store121_channel;
        b_input_store122_channel<=b_input_store122_channel;
        b_input_store110_channel<=b_input_store110_channel;
        b_input_store111_channel<=b_input_store111_channel;
        b_input_store112_channel<=b_input_store112_channel;
        b_input_store100_channel<=b_input_store100_channel;
        b_input_store101_channel<=b_input_store101_channel;
        b_input_store102_channel<=b_input_store102_channel;
        b_input_store220_channel<=b_input_store220_channel;
        b_input_store221_channel<=b_input_store221_channel;
        b_input_store222_channel<=b_input_store222_channel;
        b_input_store210_channel<=b_input_store210_channel;
        b_input_store211_channel<=b_input_store211_channel;
        b_input_store212_channel<=b_input_store212_channel;
        b_input_store200_channel<=b_input_store200_channel;
        b_input_store201_channel<=b_input_store201_channel;
        b_input_store202_channel<=b_input_store202_channel;
        b_input_store320_channel<=b_input_store320_channel;
        b_input_store321_channel<=b_input_store321_channel;
        b_input_store322_channel<=b_input_store322_channel;
        b_input_store310_channel<=b_input_store310_channel;
        b_input_store311_channel<=b_input_store311_channel;
        b_input_store312_channel<=b_input_store312_channel;
        b_input_store300_channel<=b_input_store300_channel;
        b_input_store301_channel<=b_input_store301_channel;  
        b_input_store302_channel<=b_input_store302_channel;
        b_input_store420_channel<=b_input_store420_channel;
        b_input_store421_channel<=b_input_store421_channel;
        b_input_store422_channel<=b_input_store422_channel;
        b_input_store410_channel<=b_input_store410_channel;
        b_input_store411_channel<=b_input_store411_channel;
        b_input_store412_channel<=b_input_store412_channel;
        b_input_store400_channel<=b_input_store400_channel;
        b_input_store401_channel<=b_input_store401_channel;
        b_input_store402_channel<=b_input_store402_channel;
        b_input_store520_channel<=b_input_store520_channel;
        b_input_store521_channel<=b_input_store521_channel;
        b_input_store522_channel<=b_input_store522_channel;
        b_input_store510_channel<=b_input_store510_channel;
        b_input_store511_channel<=b_input_store511_channel;
        b_input_store512_channel<=b_input_store512_channel;
        b_input_store500_channel<=b_input_store500_channel;
        b_input_store501_channel<=b_input_store501_channel;
        b_input_store502_channel<=b_input_store502_channel;      
    
    end
end


assign  f_input_store000 = (input_store_control== 1'b0)?rd_data01:f_input_store000;
assign  f_input_store001 = (input_store_control== 1'b0)?rd_data02:f_input_store001;
assign  f_input_store002 = (input_store_control== 1'b0)?input_write0:f_input_store002;
assign  f_input_store100 = (input_store_control== 1'b0)?rd_data11:f_input_store100;
assign  f_input_store101 = (input_store_control== 1'b0)?rd_data12:f_input_store101;
assign  f_input_store102 = (input_store_control== 1'b0)?input_write1:f_input_store102; 
assign  f_input_store200 = (input_store_control== 1'b0)?rd_data21:f_input_store200;
assign  f_input_store201 = (input_store_control== 1'b0)?rd_data22:f_input_store201;
assign  f_input_store202 = (input_store_control== 1'b0)?input_write2:f_input_store202;
assign  f_input_store300 = (input_store_control== 1'b0)?rd_data31:f_input_store300;
assign  f_input_store301 = (input_store_control== 1'b0)?rd_data32:f_input_store301;
assign  f_input_store302 = (input_store_control== 1'b0)?input_write3:f_input_store302;
assign  f_input_store400 = (input_store_control== 1'b0)?rd_data41:f_input_store400;
assign  f_input_store401 = (input_store_control== 1'b0)?rd_data42:f_input_store401;
assign  f_input_store402 = (input_store_control== 1'b0)?input_write4:f_input_store402;
assign  f_input_store500 = (input_store_control== 1'b0)?rd_data51:f_input_store500;
assign  f_input_store501 = (input_store_control== 1'b0)?rd_data52:f_input_store501;
assign  f_input_store502 = (input_store_control== 1'b0)?input_write5:f_input_store502;
assign  b_input_store000 = (input_store_control== 1'b1)?rd_data01:b_input_store000;
assign  b_input_store001 = (input_store_control== 1'b1)?rd_data02:b_input_store001;
assign  b_input_store002 = (input_store_control== 1'b1)?input_write0:b_input_store002;
assign  b_input_store100 = (input_store_control== 1'b1)?rd_data11:b_input_store100;
assign  b_input_store101 = (input_store_control== 1'b1)?rd_data12:b_input_store101;
assign  b_input_store102 = (input_store_control== 1'b1)?input_write1:b_input_store102; 
assign  b_input_store200 = (input_store_control== 1'b1)?rd_data21:b_input_store200;
assign  b_input_store201 = (input_store_control== 1'b1)?rd_data22:b_input_store201;
assign  b_input_store202 = (input_store_control== 1'b1)?input_write2:b_input_store202;
assign  b_input_store300 = (input_store_control== 1'b1)?rd_data31:b_input_store300;
assign  b_input_store301 = (input_store_control== 1'b1)?rd_data32:b_input_store301;
assign  b_input_store302 = (input_store_control== 1'b1)?input_write3:b_input_store302;
assign  b_input_store400 = (input_store_control== 1'b1)?rd_data41:b_input_store400;
assign  b_input_store401 = (input_store_control== 1'b1)?rd_data42:b_input_store401;
assign  b_input_store402 = (input_store_control== 1'b1)?input_write4:b_input_store402;
assign  b_input_store500 = (input_store_control== 1'b1)?rd_data51:b_input_store500;
assign  b_input_store501 = (input_store_control== 1'b1)?rd_data52:b_input_store501;
assign  b_input_store502 = (input_store_control== 1'b1)?input_write5:b_input_store502;
  

//input_store
always@(posedge sys_clk or negedge  rst_n)
begin
    if(rst_n == 1'b0 || state == R_IDLE)
    begin
           f_input_store010 <= 1'b0;
           f_input_store011 <= 1'b0;
           f_input_store012 <= 1'b0;
           f_input_store020 <= 1'b0;
           f_input_store021 <= 1'b0;
           f_input_store022 <= 1'b0;
           f_input_store110 <= 1'b0;
           f_input_store111 <= 1'b0;
           f_input_store112 <= 1'b0;
           f_input_store120 <= 1'b0;
           f_input_store121 <= 1'b0;
           f_input_store122 <= 1'b0;
           f_input_store210 <= 1'b0;
           f_input_store211 <= 1'b0;
           f_input_store212 <= 1'b0;
           f_input_store220 <= 1'b0;
           f_input_store221 <= 1'b0;
           f_input_store222 <= 1'b0;
           f_input_store310 <= 1'b0;
           f_input_store311 <= 1'b0;
           f_input_store312 <= 1'b0;
           f_input_store320 <= 1'b0;
           f_input_store321 <= 1'b0;
           f_input_store322 <= 1'b0;
           f_input_store410 <= 1'b0;
           f_input_store411 <= 1'b0;
           f_input_store412 <= 1'b0;
           f_input_store420 <= 1'b0;
           f_input_store421 <= 1'b0;
           f_input_store422 <= 1'b0;
           f_input_store510 <= 1'b0;
           f_input_store511 <= 1'b0;
           f_input_store512 <= 1'b0;
           f_input_store520 <= 1'b0;
           f_input_store521 <= 1'b0;
           f_input_store522 <= 1'b0;
           b_input_store010 <= 1'b0;
           b_input_store011 <= 1'b0;
           b_input_store012 <= 1'b0;
           b_input_store020 <= 1'b0;
           b_input_store021 <= 1'b0;
           b_input_store022 <= 1'b0;
           b_input_store110 <= 1'b0;
           b_input_store111 <= 1'b0;
           b_input_store112 <= 1'b0;
           b_input_store120 <= 1'b0;
           b_input_store121 <= 1'b0;
           b_input_store122 <= 1'b0;
           b_input_store210 <= 1'b0;
           b_input_store211 <= 1'b0;
           b_input_store212 <= 1'b0;
           b_input_store220 <= 1'b0;
           b_input_store221 <= 1'b0;
           b_input_store222 <= 1'b0;
           b_input_store310 <= 1'b0;
           b_input_store311 <= 1'b0;
           b_input_store312 <= 1'b0;
           b_input_store320 <= 1'b0;
           b_input_store321 <= 1'b0;
           b_input_store322 <= 1'b0;
           b_input_store410 <= 1'b0;
           b_input_store411 <= 1'b0;
           b_input_store412 <= 1'b0;
           b_input_store420 <= 1'b0;
           b_input_store421 <= 1'b0;
           b_input_store422 <= 1'b0;
           b_input_store510 <= 1'b0;
           b_input_store511 <= 1'b0;
           b_input_store512 <= 1'b0;
           b_input_store520 <= 1'b0;
           b_input_store521 <= 1'b0;
           b_input_store522 <= 1'b0;
        f_input_store000_d0 <= 1'b0;
        f_input_store001_d0 <= 1'b0;
        f_input_store002_d0 <= 1'b0;
        f_input_store010_d0 <= 1'b0;
        f_input_store011_d0 <= 1'b0;
        f_input_store012_d0 <= 1'b0;
        f_input_store100_d0 <= 1'b0;
        f_input_store101_d0 <= 1'b0;
        f_input_store102_d0 <= 1'b0;
        f_input_store110_d0 <= 1'b0;
        f_input_store111_d0 <= 1'b0;
        f_input_store112_d0 <= 1'b0;
        f_input_store200_d0 <= 1'b0;
        f_input_store201_d0 <= 1'b0;
        f_input_store202_d0 <= 1'b0;
        f_input_store210_d0 <= 1'b0;
        f_input_store211_d0 <= 1'b0;
        f_input_store212_d0 <= 1'b0;
        f_input_store300_d0 <= 1'b0;
        f_input_store301_d0 <= 1'b0;
        f_input_store302_d0 <= 1'b0;
        f_input_store310_d0 <= 1'b0;
        f_input_store311_d0 <= 1'b0;
        f_input_store312_d0 <= 1'b0;
        f_input_store400_d0 <= 1'b0;
        f_input_store401_d0 <= 1'b0;
        f_input_store402_d0 <= 1'b0;
        f_input_store410_d0 <= 1'b0;
        f_input_store411_d0 <= 1'b0;
        f_input_store412_d0 <= 1'b0;
        f_input_store500_d0 <= 1'b0;
        f_input_store501_d0 <= 1'b0;
        f_input_store502_d0 <= 1'b0;
        f_input_store510_d0 <= 1'b0;
        f_input_store511_d0 <= 1'b0;
        f_input_store512_d0 <= 1'b0;
        b_input_store000_d0 <= 1'b0;
        b_input_store001_d0 <= 1'b0;
        b_input_store002_d0 <= 1'b0;
        b_input_store010_d0 <= 1'b0;
        b_input_store011_d0 <= 1'b0;
        b_input_store012_d0 <= 1'b0;
        b_input_store100_d0 <= 1'b0;
        b_input_store101_d0 <= 1'b0;
        b_input_store102_d0 <= 1'b0;
        b_input_store110_d0 <= 1'b0;
        b_input_store111_d0 <= 1'b0;
        b_input_store112_d0 <= 1'b0;
        b_input_store200_d0 <= 1'b0;
        b_input_store201_d0 <= 1'b0;
        b_input_store202_d0 <= 1'b0;
        b_input_store210_d0 <= 1'b0;
        b_input_store211_d0 <= 1'b0;
        b_input_store212_d0 <= 1'b0;
        b_input_store300_d0 <= 1'b0;
        b_input_store301_d0 <= 1'b0;
        b_input_store302_d0 <= 1'b0;
        b_input_store310_d0 <= 1'b0;
        b_input_store311_d0 <= 1'b0;
        b_input_store312_d0 <= 1'b0;
        b_input_store400_d0 <= 1'b0;
        b_input_store401_d0 <= 1'b0;
        b_input_store402_d0 <= 1'b0;
        b_input_store410_d0 <= 1'b0;
        b_input_store411_d0 <= 1'b0;
        b_input_store412_d0 <= 1'b0;
        b_input_store500_d0 <= 1'b0;
        b_input_store501_d0 <= 1'b0;
        b_input_store502_d0 <= 1'b0;
        b_input_store510_d0 <= 1'b0;
        b_input_store511_d0 <= 1'b0;
        b_input_store512_d0 <= 1'b0;
    end
    else    if(state == CAL &&((num_cnt >=((IN_IJ_SIZE+2)*4))&&(num_cnt <= ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)+5))))
        begin
        if(a_cnt == 31&&input_store_control== 1'b1)//如果以后出问题了，想想这里
        begin
        f_input_store000_d0<=cal_input_store000;
        f_input_store001_d0<=cal_input_store001;
        f_input_store002_d0<=cal_input_store002;
        f_input_store100_d0<=cal_input_store100;
        f_input_store101_d0<=cal_input_store101;
        f_input_store102_d0<=cal_input_store102;
        f_input_store200_d0<=cal_input_store200;
        f_input_store201_d0<=cal_input_store201;
        f_input_store202_d0<=cal_input_store202;
        f_input_store300_d0<=cal_input_store300;
        f_input_store301_d0<=cal_input_store301;
        f_input_store302_d0<=cal_input_store302;
        f_input_store400_d0<=cal_input_store400;
        f_input_store401_d0<=cal_input_store401;
        f_input_store402_d0<=cal_input_store402;
        f_input_store500_d0<=cal_input_store500;
        f_input_store501_d0<=cal_input_store501;
        f_input_store502_d0<=cal_input_store502;
        f_input_store010_d0<=cal_input_store010;
        f_input_store011_d0<=cal_input_store011;
        f_input_store012_d0<=cal_input_store012;
        f_input_store110_d0<=cal_input_store110;
        f_input_store111_d0<=cal_input_store111;
        f_input_store112_d0<=cal_input_store112;
        f_input_store210_d0<=cal_input_store210;
        f_input_store211_d0<=cal_input_store211;
        f_input_store212_d0<=cal_input_store212;
        f_input_store310_d0<=cal_input_store310;
        f_input_store311_d0<=cal_input_store311;
        f_input_store312_d0<=cal_input_store312;
        f_input_store410_d0<=cal_input_store410;
        f_input_store411_d0<=cal_input_store411;
        f_input_store412_d0<=cal_input_store412;
        f_input_store510_d0<=cal_input_store510;
        f_input_store511_d0<=cal_input_store511;
        f_input_store512_d0<=cal_input_store512; 
        end
        else if(a_cnt == 0&&input_store_control== 1'b0)
        begin
        b_input_store000_d0<=cal_input_store000;
        b_input_store001_d0<=cal_input_store001;
        b_input_store002_d0<=cal_input_store002;  
        b_input_store100_d0<=cal_input_store100;
        b_input_store101_d0<=cal_input_store101;
        b_input_store102_d0<=cal_input_store102; 
        b_input_store200_d0<=cal_input_store200;
        b_input_store201_d0<=cal_input_store201;
        b_input_store202_d0<=cal_input_store202;  
        b_input_store300_d0<=cal_input_store300;
        b_input_store301_d0<=cal_input_store301;
        b_input_store302_d0<=cal_input_store302;   
        b_input_store400_d0<=cal_input_store400;
        b_input_store401_d0<=cal_input_store401;
        b_input_store402_d0<=cal_input_store402;  
        b_input_store500_d0<=cal_input_store500;
        b_input_store501_d0<=cal_input_store501;
        b_input_store502_d0<=cal_input_store502;
        b_input_store010_d0<=cal_input_store010;
        b_input_store011_d0<=cal_input_store011;
        b_input_store012_d0<=cal_input_store012;  
        b_input_store110_d0<=cal_input_store110;
        b_input_store111_d0<=cal_input_store111;
        b_input_store112_d0<=cal_input_store112; 
        b_input_store210_d0<=cal_input_store210;
        b_input_store211_d0<=cal_input_store211;
        b_input_store212_d0<=cal_input_store212;  
        b_input_store310_d0<=cal_input_store310;
        b_input_store311_d0<=cal_input_store311;
        b_input_store312_d0<=cal_input_store312;   
        b_input_store410_d0<=cal_input_store410;
        b_input_store411_d0<=cal_input_store411;
        b_input_store412_d0<=cal_input_store412;  
        b_input_store510_d0<=cal_input_store510;
        b_input_store511_d0<=cal_input_store511;
        b_input_store512_d0<=cal_input_store512;          
        end
        else
        begin       
        f_input_store000_d0 <= f_input_store000;
        f_input_store001_d0 <= f_input_store001;
        f_input_store002_d0 <= f_input_store002;
           f_input_store010 <= f_input_store000_d0;
           f_input_store011 <= f_input_store001_d0;
           f_input_store012 <= f_input_store002_d0;
        f_input_store010_d0 <= f_input_store010;
        f_input_store011_d0 <= f_input_store011;
        f_input_store012_d0 <= f_input_store012; 
           f_input_store020 <= f_input_store010_d0;
           f_input_store021 <= f_input_store011_d0;
           f_input_store022 <= f_input_store012_d0;        
        b_input_store000_d0 <= b_input_store000;
        b_input_store001_d0 <= b_input_store001;
        b_input_store002_d0 <= b_input_store002; 
           b_input_store010 <= b_input_store000_d0;
           b_input_store011 <= b_input_store001_d0;
           b_input_store012 <= b_input_store002_d0;   
        b_input_store010_d0 <= b_input_store010;
        b_input_store011_d0 <= b_input_store011;
        b_input_store012_d0 <= b_input_store012;  
           b_input_store020 <= b_input_store010_d0;
           b_input_store021 <= b_input_store011_d0;
           b_input_store022 <= b_input_store012_d0;    
        f_input_store100_d0 <= f_input_store100;
        f_input_store101_d0 <= f_input_store101;
        f_input_store102_d0 <= f_input_store102;
           f_input_store110 <= f_input_store100_d0;
           f_input_store111 <= f_input_store101_d0;
           f_input_store112 <= f_input_store102_d0;
        f_input_store110_d0 <= f_input_store110;
        f_input_store111_d0 <= f_input_store111;
        f_input_store112_d0 <= f_input_store112; 
           f_input_store120 <= f_input_store110_d0;
           f_input_store121 <= f_input_store111_d0;
           f_input_store122 <= f_input_store112_d0;        
        b_input_store100_d0 <= b_input_store100;
        b_input_store101_d0 <= b_input_store101;
        b_input_store102_d0 <= b_input_store102; 
           b_input_store110 <= b_input_store100_d0;
           b_input_store111 <= b_input_store101_d0;
           b_input_store112 <= b_input_store102_d0;   
        b_input_store110_d0 <= b_input_store110;
        b_input_store111_d0 <= b_input_store111;
        b_input_store112_d0 <= b_input_store112;  
           b_input_store120 <= b_input_store110_d0;
           b_input_store121 <= b_input_store111_d0;
           b_input_store122 <= b_input_store112_d0;    
        f_input_store200_d0 <= f_input_store200;
        f_input_store201_d0 <= f_input_store201;
        f_input_store202_d0 <= f_input_store202;
           f_input_store210 <= f_input_store200_d0;
           f_input_store211 <= f_input_store201_d0;
           f_input_store212 <= f_input_store202_d0;
        f_input_store210_d0 <= f_input_store210;
        f_input_store211_d0 <= f_input_store211;
        f_input_store212_d0 <= f_input_store212; 
           f_input_store220 <= f_input_store210_d0;
           f_input_store221 <= f_input_store211_d0;
           f_input_store222 <= f_input_store212_d0;        
        b_input_store200_d0 <= b_input_store200;
        b_input_store201_d0 <= b_input_store201;
        b_input_store202_d0 <= b_input_store202; 
           b_input_store210 <= b_input_store200_d0;
           b_input_store211 <= b_input_store201_d0;
           b_input_store212 <= b_input_store202_d0;   
        b_input_store210_d0 <= b_input_store210;
        b_input_store211_d0 <= b_input_store211;
        b_input_store212_d0 <= b_input_store212;  
           b_input_store220 <= b_input_store210_d0;
           b_input_store221 <= b_input_store211_d0;
           b_input_store222 <= b_input_store212_d0; 
        f_input_store300_d0 <= f_input_store300;
        f_input_store301_d0 <= f_input_store301;
        f_input_store302_d0 <= f_input_store302;
           f_input_store310 <= f_input_store300_d0;
           f_input_store311 <= f_input_store301_d0;
           f_input_store312 <= f_input_store302_d0;
        f_input_store310_d0 <= f_input_store310;
        f_input_store311_d0 <= f_input_store311;
        f_input_store312_d0 <= f_input_store312; 
           f_input_store320 <= f_input_store310_d0;
           f_input_store321 <= f_input_store311_d0;
           f_input_store322 <= f_input_store312_d0;        
        b_input_store300_d0 <= b_input_store300;
        b_input_store301_d0 <= b_input_store301;
        b_input_store302_d0 <= b_input_store302; 
           b_input_store310 <= b_input_store300_d0;
           b_input_store311 <= b_input_store301_d0;
           b_input_store312 <= b_input_store302_d0;   
        b_input_store310_d0 <= b_input_store310;
        b_input_store311_d0 <= b_input_store311;
        b_input_store312_d0 <= b_input_store312;  
           b_input_store320 <= b_input_store310_d0;
           b_input_store321 <= b_input_store311_d0;
           b_input_store322 <= b_input_store312_d0;   
        f_input_store400_d0 <= f_input_store400;
        f_input_store401_d0 <= f_input_store401;
        f_input_store402_d0 <= f_input_store402;
           f_input_store410 <= f_input_store400_d0;
           f_input_store411 <= f_input_store401_d0;
           f_input_store412 <= f_input_store402_d0;
        f_input_store410_d0 <= f_input_store410;
        f_input_store411_d0 <= f_input_store411;
        f_input_store412_d0 <= f_input_store412; 
           f_input_store420 <= f_input_store410_d0;
           f_input_store421 <= f_input_store411_d0;
           f_input_store422 <= f_input_store412_d0;        
        b_input_store400_d0 <= b_input_store400;
        b_input_store401_d0 <= b_input_store401;
        b_input_store402_d0 <= b_input_store402; 
           b_input_store410 <= b_input_store400_d0;
           b_input_store411 <= b_input_store401_d0;
           b_input_store412 <= b_input_store402_d0;   
        b_input_store410_d0 <= b_input_store410;
        b_input_store411_d0 <= b_input_store411;
        b_input_store412_d0 <= b_input_store412;  
           b_input_store420 <= b_input_store410_d0;
           b_input_store421 <= b_input_store411_d0;
           b_input_store422 <= b_input_store412_d0; 
        f_input_store500_d0 <= f_input_store500;
        f_input_store501_d0 <= f_input_store501;
        f_input_store502_d0 <= f_input_store502;
           f_input_store510 <= f_input_store500_d0;
           f_input_store511 <= f_input_store501_d0;
           f_input_store512 <= f_input_store502_d0;
        f_input_store510_d0 <= f_input_store510;
        f_input_store511_d0 <= f_input_store511;
        f_input_store512_d0 <= f_input_store512; 
           f_input_store520 <= f_input_store510_d0;
           f_input_store521 <= f_input_store511_d0;
           f_input_store522 <= f_input_store512_d0;        
        b_input_store500_d0 <= b_input_store500;
        b_input_store501_d0 <= b_input_store501;
        b_input_store502_d0 <= b_input_store502; 
           b_input_store510 <= b_input_store500_d0;
           b_input_store511 <= b_input_store501_d0;
           b_input_store512 <= b_input_store502_d0;   
        b_input_store510_d0 <= b_input_store510;
        b_input_store511_d0 <= b_input_store511;
        b_input_store512_d0 <= b_input_store512;  
           b_input_store520 <= b_input_store510_d0;
           b_input_store521 <= b_input_store511_d0;
           b_input_store522 <= b_input_store512_d0;   
        end
        end
    else    
        begin
           f_input_store010 <= 1'b0;
           f_input_store011 <= 1'b0;
           f_input_store012 <= 1'b0;
           f_input_store020 <= 1'b0;
           f_input_store021 <= 1'b0;
           f_input_store022 <= 1'b0;
           f_input_store110 <= 1'b0;
           f_input_store111 <= 1'b0;
           f_input_store112 <= 1'b0;
           f_input_store120 <= 1'b0;
           f_input_store121 <= 1'b0;
           f_input_store122 <= 1'b0;
           f_input_store210 <= 1'b0;
           f_input_store211 <= 1'b0;
           f_input_store212 <= 1'b0;
           f_input_store220 <= 1'b0;
           f_input_store221 <= 1'b0;
           f_input_store222 <= 1'b0;
           f_input_store310 <= 1'b0;
           f_input_store311 <= 1'b0;
           f_input_store312 <= 1'b0;
           f_input_store320 <= 1'b0;
           f_input_store321 <= 1'b0;
           f_input_store322 <= 1'b0;
           f_input_store410 <= 1'b0;
           f_input_store411 <= 1'b0;
           f_input_store412 <= 1'b0;
           f_input_store420 <= 1'b0;
           f_input_store421 <= 1'b0;
           f_input_store422 <= 1'b0;
           f_input_store510 <= 1'b0;
           f_input_store511 <= 1'b0;
           f_input_store512 <= 1'b0;
           f_input_store520 <= 1'b0;
           f_input_store521 <= 1'b0;
           f_input_store522 <= 1'b0;
           b_input_store010 <= 1'b0;
           b_input_store011 <= 1'b0;
           b_input_store012 <= 1'b0;
           b_input_store020 <= 1'b0;
           b_input_store021 <= 1'b0;
           b_input_store022 <= 1'b0;
           b_input_store110 <= 1'b0;
           b_input_store111 <= 1'b0;
           b_input_store112 <= 1'b0;
           b_input_store120 <= 1'b0;
           b_input_store121 <= 1'b0;
           b_input_store122 <= 1'b0;
           b_input_store210 <= 1'b0;
           b_input_store211 <= 1'b0;
           b_input_store212 <= 1'b0;
           b_input_store220 <= 1'b0;
           b_input_store221 <= 1'b0;
           b_input_store222 <= 1'b0;
           b_input_store310 <= 1'b0;
           b_input_store311 <= 1'b0;
           b_input_store312 <= 1'b0;
           b_input_store320 <= 1'b0;
           b_input_store321 <= 1'b0;
           b_input_store322 <= 1'b0;
           b_input_store410 <= 1'b0;
           b_input_store411 <= 1'b0;
           b_input_store412 <= 1'b0;
           b_input_store420 <= 1'b0;
           b_input_store421 <= 1'b0;
           b_input_store422 <= 1'b0;
           b_input_store510 <= 1'b0;
           b_input_store511 <= 1'b0;
           b_input_store512 <= 1'b0;
           b_input_store520 <= 1'b0;
           b_input_store521 <= 1'b0;
           b_input_store522 <= 1'b0;
        f_input_store000_d0 <= 1'b0;
        f_input_store001_d0 <= 1'b0;
        f_input_store002_d0 <= 1'b0;
        f_input_store010_d0 <= 1'b0;
        f_input_store011_d0 <= 1'b0;
        f_input_store012_d0 <= 1'b0;
        f_input_store100_d0 <= 1'b0;
        f_input_store101_d0 <= 1'b0;
        f_input_store102_d0 <= 1'b0;
        f_input_store110_d0 <= 1'b0;
        f_input_store111_d0 <= 1'b0;
        f_input_store112_d0 <= 1'b0;
        f_input_store200_d0 <= 1'b0;
        f_input_store201_d0 <= 1'b0;
        f_input_store202_d0 <= 1'b0;
        f_input_store210_d0 <= 1'b0;
        f_input_store211_d0 <= 1'b0;
        f_input_store212_d0 <= 1'b0;
        f_input_store300_d0 <= 1'b0;
        f_input_store301_d0 <= 1'b0;
        f_input_store302_d0 <= 1'b0;
        f_input_store310_d0 <= 1'b0;
        f_input_store311_d0 <= 1'b0;
        f_input_store312_d0 <= 1'b0;
        f_input_store400_d0 <= 1'b0;
        f_input_store401_d0 <= 1'b0;
        f_input_store402_d0 <= 1'b0;
        f_input_store410_d0 <= 1'b0;
        f_input_store411_d0 <= 1'b0;
        f_input_store412_d0 <= 1'b0;
        f_input_store500_d0 <= 1'b0;
        f_input_store501_d0 <= 1'b0;
        f_input_store502_d0 <= 1'b0;
        f_input_store510_d0 <= 1'b0;
        f_input_store511_d0 <= 1'b0;
        f_input_store512_d0 <= 1'b0;
        b_input_store000_d0 <= 1'b0;
        b_input_store001_d0 <= 1'b0;
        b_input_store002_d0 <= 1'b0;
        b_input_store010_d0 <= 1'b0;
        b_input_store011_d0 <= 1'b0;
        b_input_store012_d0 <= 1'b0;
        b_input_store100_d0 <= 1'b0;
        b_input_store101_d0 <= 1'b0;
        b_input_store102_d0 <= 1'b0;
        b_input_store110_d0 <= 1'b0;
        b_input_store111_d0 <= 1'b0;
        b_input_store112_d0 <= 1'b0;
        b_input_store200_d0 <= 1'b0;
        b_input_store201_d0 <= 1'b0;
        b_input_store202_d0 <= 1'b0;
        b_input_store210_d0 <= 1'b0;
        b_input_store211_d0 <= 1'b0;
        b_input_store212_d0 <= 1'b0;
        b_input_store300_d0 <= 1'b0;
        b_input_store301_d0 <= 1'b0;
        b_input_store302_d0 <= 1'b0;
        b_input_store310_d0 <= 1'b0;
        b_input_store311_d0 <= 1'b0;
        b_input_store312_d0 <= 1'b0;
        b_input_store400_d0 <= 1'b0;
        b_input_store401_d0 <= 1'b0;
        b_input_store402_d0 <= 1'b0;
        b_input_store410_d0 <= 1'b0;
        b_input_store411_d0 <= 1'b0;
        b_input_store412_d0 <= 1'b0;
        b_input_store500_d0 <= 1'b0;
        b_input_store501_d0 <= 1'b0;
        b_input_store502_d0 <= 1'b0;
        b_input_store510_d0 <= 1'b0;
        b_input_store511_d0 <= 1'b0;
        b_input_store512_d0 <= 1'b0;              
        end
end
//kernal


assign  cal_kernal000 = (input_store_control == 1'b0)?kernal000[a_cnt]:kernal600[a_cnt]; 
assign  cal_kernal001 = (input_store_control == 1'b0)?kernal001[a_cnt]:kernal601[a_cnt]; 
assign  cal_kernal002 = (input_store_control == 1'b0)?kernal002[a_cnt]:kernal602[a_cnt]; 
assign  cal_kernal010 = (input_store_control == 1'b0)?kernal010[a_cnt]:kernal610[a_cnt]; 
assign  cal_kernal011 = (input_store_control == 1'b0)?kernal011[a_cnt]:kernal611[a_cnt]; 
assign  cal_kernal012 = (input_store_control == 1'b0)?kernal012[a_cnt]:kernal612[a_cnt]; 
assign  cal_kernal020 = (input_store_control == 1'b0)?kernal020[a_cnt]:kernal620[a_cnt]; 
assign  cal_kernal021 = (input_store_control == 1'b0)?kernal021[a_cnt]:kernal621[a_cnt]; 
assign  cal_kernal022 = (input_store_control == 1'b0)?kernal022[a_cnt]:kernal622[a_cnt]; 
assign  cal_kernal100 = (input_store_control == 1'b0)?kernal100[a_cnt]:kernal700[a_cnt]; 
assign  cal_kernal101 = (input_store_control == 1'b0)?kernal101[a_cnt]:kernal701[a_cnt]; 
assign  cal_kernal102 = (input_store_control == 1'b0)?kernal102[a_cnt]:kernal702[a_cnt]; 
assign  cal_kernal110 = (input_store_control == 1'b0)?kernal110[a_cnt]:kernal710[a_cnt]; 
assign  cal_kernal111 = (input_store_control == 1'b0)?kernal111[a_cnt]:kernal711[a_cnt]; 
assign  cal_kernal112 = (input_store_control == 1'b0)?kernal112[a_cnt]:kernal712[a_cnt]; 
assign  cal_kernal120 = (input_store_control == 1'b0)?kernal120[a_cnt]:kernal720[a_cnt]; 
assign  cal_kernal121 = (input_store_control == 1'b0)?kernal121[a_cnt]:kernal721[a_cnt]; 
assign  cal_kernal122 = (input_store_control == 1'b0)?kernal122[a_cnt]:kernal722[a_cnt]; 
assign  cal_kernal200 = (input_store_control == 1'b0)?kernal200[a_cnt]:kernal800[a_cnt]; 
assign  cal_kernal201 = (input_store_control == 1'b0)?kernal201[a_cnt]:kernal801[a_cnt]; 
assign  cal_kernal202 = (input_store_control == 1'b0)?kernal202[a_cnt]:kernal802[a_cnt]; 
assign  cal_kernal210 = (input_store_control == 1'b0)?kernal210[a_cnt]:kernal810[a_cnt]; 
assign  cal_kernal211 = (input_store_control == 1'b0)?kernal211[a_cnt]:kernal811[a_cnt]; 
assign  cal_kernal212 = (input_store_control == 1'b0)?kernal212[a_cnt]:kernal812[a_cnt]; 
assign  cal_kernal220 = (input_store_control == 1'b0)?kernal220[a_cnt]:kernal820[a_cnt]; 
assign  cal_kernal221 = (input_store_control == 1'b0)?kernal221[a_cnt]:kernal821[a_cnt]; 
assign  cal_kernal222 = (input_store_control == 1'b0)?kernal222[a_cnt]:kernal822[a_cnt]; 
assign  cal_kernal300 = (input_store_control == 1'b0)?kernal300[a_cnt]:kernal900[a_cnt]; 
assign  cal_kernal301 = (input_store_control == 1'b0)?kernal301[a_cnt]:kernal901[a_cnt]; 
assign  cal_kernal302 = (input_store_control == 1'b0)?kernal302[a_cnt]:kernal902[a_cnt]; 
assign  cal_kernal310 = (input_store_control == 1'b0)?kernal310[a_cnt]:kernal910[a_cnt]; 
assign  cal_kernal311 = (input_store_control == 1'b0)?kernal311[a_cnt]:kernal911[a_cnt]; 
assign  cal_kernal312 = (input_store_control == 1'b0)?kernal312[a_cnt]:kernal912[a_cnt]; 
assign  cal_kernal320 = (input_store_control == 1'b0)?kernal320[a_cnt]:kernal920[a_cnt]; 
assign  cal_kernal321 = (input_store_control == 1'b0)?kernal321[a_cnt]:kernal921[a_cnt]; 
assign  cal_kernal322 = (input_store_control == 1'b0)?kernal322[a_cnt]:kernal922[a_cnt]; 
assign  cal_kernal400 = (input_store_control == 1'b0)?kernal400[a_cnt]:kernal1000[a_cnt];
assign  cal_kernal401 = (input_store_control == 1'b0)?kernal401[a_cnt]:kernal1001[a_cnt];
assign  cal_kernal402 = (input_store_control == 1'b0)?kernal402[a_cnt]:kernal1002[a_cnt];
assign  cal_kernal410 = (input_store_control == 1'b0)?kernal410[a_cnt]:kernal1010[a_cnt];
assign  cal_kernal411 = (input_store_control == 1'b0)?kernal411[a_cnt]:kernal1011[a_cnt];
assign  cal_kernal412 = (input_store_control == 1'b0)?kernal412[a_cnt]:kernal1012[a_cnt];
assign  cal_kernal420 = (input_store_control == 1'b0)?kernal420[a_cnt]:kernal1020[a_cnt];
assign  cal_kernal421 = (input_store_control == 1'b0)?kernal421[a_cnt]:kernal1021[a_cnt];
assign  cal_kernal422 = (input_store_control == 1'b0)?kernal422[a_cnt]:kernal1022[a_cnt];
assign  cal_kernal500 = (input_store_control == 1'b0)?kernal500[a_cnt]:kernal1100[a_cnt];
assign  cal_kernal501 = (input_store_control == 1'b0)?kernal501[a_cnt]:kernal1101[a_cnt];
assign  cal_kernal502 = (input_store_control == 1'b0)?kernal502[a_cnt]:kernal1102[a_cnt];
assign  cal_kernal510 = (input_store_control == 1'b0)?kernal510[a_cnt]:kernal1110[a_cnt];
assign  cal_kernal511 = (input_store_control == 1'b0)?kernal511[a_cnt]:kernal1111[a_cnt];
assign  cal_kernal512 = (input_store_control == 1'b0)?kernal512[a_cnt]:kernal1112[a_cnt];
assign  cal_kernal520 = (input_store_control == 1'b0)?kernal520[a_cnt]:kernal1120[a_cnt];
assign  cal_kernal521 = (input_store_control == 1'b0)?kernal521[a_cnt]:kernal1121[a_cnt];
assign  cal_kernal522 = (input_store_control == 1'b0)?kernal522[a_cnt]:kernal1122[a_cnt];



//test

//assign  test_data = sum_result[207][207][7:0];

wire    [16:0]  test12321;
assign test12321 = cal_input_store022+cal_input_store021+cal_input_store020+cal_input_store010+cal_input_store011+cal_input_store012+cal_input_store000+cal_input_store001+cal_input_store002;
//assign  test12321 = (kernal021[0]+kernal022[0]);
//assign  test12321 = cal_kernal011+cal_kernal010+cal_kernal012+cal_kernal021+cal_kernal020+cal_kernal022+cal_kernal000+cal_kernal001+cal_kernal002;
//assign  test12321 = (input_store000_dly3+input_store001_dly3+input_store002_dly3+input_store010_dly3+input_store011_dly3+input_store012_dly3 +input_store020_dly3+input_store021_dly3+input_store1022_dly3);
//assign  test12321 = input_store420+input_store421+input_store411+input_store410+input_store422+input_store412+input_store400+input_store401+input_store402;


reg    [7:0]   test_data_dly;


always@(posedge sys_clk or negedge  rst_n)
    if(rst_n == 1'b0)
    begin
        test_data <= 1'b0;
        test_data_dly <= 1'b0;
    end
    else    if((((state == CAL)&&(num_cnt ==(846)&&(a_cnt == 0)&&(input_store_control== 1'b0)))))//(((state == CAL)&&(num_cnt ==(850))&&(a_cnt == 9'd31)))
    begin   //846 850   ((IN_IJ_SIZE +2)*(IN_IJ_SIZE +2)+3)  //846 2 0  第一个  84621 84630 84631   // 1053 20 1058
        test_data_dly <= test12321[7:0];
    end    
    else  
        begin
        test_data <= test_data_dly;
        test_data_dly <= test_data_dly;
        end

// 1 430 186         -263
// 31 430 
//data_store_delay
reg  signed  [16:0]  data_store0_d1;
reg  signed  [16:0]  data_store1_d1;
reg  signed  [16:0]  data_store2_d1;
reg  signed  [16:0]  data_store3_d1;
reg  signed  [16:0]  data_store4_d1;
reg  signed  [16:0]  data_store5_d1;
always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0||state == R_IDLE)
        begin
            data_store0_dly <=1'b0;
            data_store1_dly <=1'b0;
            data_store2_dly <=1'b0;
            data_store3_dly <=1'b0;
            data_store4_dly <=1'b0;
            data_store5_dly <=1'b0;
            data_store0_d1  <=1'b0;
            data_store1_d1  <=1'b0;
            data_store2_d1  <=1'b0;
            data_store3_d1  <=1'b0;
            data_store4_d1  <=1'b0;
            data_store5_d1  <=1'b0;
        end
    else
        begin
            data_store0_dly <=data_store0;
            data_store1_dly <=data_store1;
            data_store2_dly <=data_store2;
            data_store3_dly <=data_store3;
            data_store4_dly <=data_store4;
            data_store5_dly <=data_store5;
            data_store0_d1  <=data_store0_dly;
            data_store1_d1  <=data_store1_dly;
            data_store2_d1  <=data_store2_dly;
            data_store3_d1  <=data_store3_dly;
            data_store4_d1  <=data_store4_dly;
            data_store5_d1  <=data_store5_dly;
        end
end
assign sum_result1 =  data_store0_d1+data_store0_dly;//13  //-8//126  116
assign sum_result2 =  data_store1_d1+data_store1_dly;//145//104//-39   -8
assign sum_result3 =  data_store2_d1+data_store2_dly;//34//8  18  26//-172 -149
assign sum_result4 =  data_store3_d1+data_store3_dly;//-6 -42   -48 // -57//24 29
assign sum_result5 =  data_store4_d1+data_store4_dly;//1//-5//7  -1
assign sum_result6 =  data_store5_d1+data_store5_dly;//9//14//-9  -7
assign sum_result  = sum_result1+sum_result2+sum_result3+sum_result4+sum_result5+sum_result6;



//pooling     pool_inst
//(
//    .sys_clk   (sys_clk)  ,
//    .rst_n     (rst_n)  ,
//    .pool_start(pool_start)  ,
//    .input_num (sum_result)  ,
//
//    .output_num(pool_result)  
//);
//

always@(posedge sys_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
       pool_start <= 1'b0;
    else    if(state == CAL && num_cnt >= 430)
       pool_start <= 1'b1;
    else
       pool_start <= 1'b0;
end











endmodule

            