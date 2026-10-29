`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-19-2025 19:28:48
// Design Name:
// Module Name: cnn_test
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module cnn_test#(
	parameter PAD = 1,
    parameter width = 28,                //图片的宽度
    parameter height = 28               //图片的高度
)(
	input clk,
	input rst_n,
	input valid_in,
	input signed [8:0] data_in,
	output valid_out,
	output wire [3:0] result,
	output signed [35:0] data_out
    );
	
//---------------------CONV1---------------------------

wire valid_out1_1,valid_out1_2,valid_out1_3;
wire signed [11:0] data_out1_1;
wire signed [11:0] data_out1_2;
wire signed [11:0] data_out1_3;

conv #( 
    .BITWIDTH(9),              //输入数据位宽
    .BITWIDTH_OUT(12)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
    .CORE(1)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv1_1 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(valid_in),
    .data_in(data_in),
    .o_en_conv(valid_out1_1),
    .data_out_conv(data_out1_1)
);

conv #( 
    .BITWIDTH(9),              //输入数据位宽
    .BITWIDTH_OUT(12)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
    .CORE(2)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv1_2 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(valid_in),
    .data_in(data_in),
    .o_en_conv(valid_out1_2),
    .data_out_conv(data_out1_2)
);

conv #( 
    .BITWIDTH(9),              //输入数据位宽
    .BITWIDTH_OUT(12)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
    .CORE(3)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv1_3 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(valid_in),
    .data_in(data_in),
    .o_en_conv(valid_out1_3),
    .data_out_conv(data_out1_3)
);

//---------------------------------RELU1-------------------------------------

wire signed [11:0] relu_out1_1;
wire signed [11:0] relu_out1_2;
wire signed [11:0] relu_out1_3;
assign relu_out1_1 = data_out1_1 < 0 ? 0 : data_out1_1;
assign relu_out1_2 = data_out1_2 < 0 ? 0 : data_out1_2;
assign relu_out1_3 = data_out1_3 < 0 ? 0 : data_out1_3;

//---------------------------------POOL1---------------------------------------

wire pool_valid1_1,pool_valid1_2,pool_valid1_3;
wire signed [11:0] pool_out1_1;
wire signed [11:0] pool_out1_2;
wire signed [11:0] pool_out1_3;

pool #(              
    .BITWIDTH_OUT(12)				, //输入数据位宽
    .width(width-2*(!PAD)),                //图片的宽度
    .height(height-2*(!PAD))               //图片的高度
) pool1_1 (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out1_1)										,                                         
    .data_in(relu_out1_1)		,               
    .data_out_pool(pool_out1_1)	,         
    .o_en_pool(pool_valid1_1)   
);

pool #(              
    .BITWIDTH_OUT(12)				, //输入数据位宽
    .width(width-2*(!PAD)),                //图片的宽度
    .height(height-2*(!PAD))               //图片的高度
) pool1_2 (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out1_2)										,                                         
    .data_in(relu_out1_2)		,               
    .data_out_pool(pool_out1_2)	,         
    .o_en_pool(pool_valid1_2)   
);

pool #(              
    .BITWIDTH_OUT(12)				, //输入数据位宽
    .width(width-2*(!PAD)),                //图片的宽度
    .height(height-2*(!PAD))               //图片的高度
) pool1_3 (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out1_3)										,                                         
    .data_in(relu_out1_3)		,               
    .data_out_pool(pool_out1_3)	,         
    .o_en_pool(pool_valid1_3)   
);

//---------------------CONV2---------------------------

wire valid_out2_11,valid_out2_21,valid_out2_31;
wire signed [15:0] conv_out2_11;
wire signed [15:0] conv_out2_21;
wire signed [15:0] conv_out2_31;
wire valid_out2_12,valid_out2_22,valid_out2_32;
wire signed [15:0] conv_out2_12;
wire signed [15:0] conv_out2_22;
wire signed [15:0] conv_out2_32;
wire valid_out2_13,valid_out2_23,valid_out2_33;
wire signed [15:0] conv_out2_13;
wire signed [15:0] conv_out2_23;
wire signed [15:0] conv_out2_33;

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(11)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_11 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_1),
    .data_in(pool_out1_1),
    .o_en_conv(valid_out2_11),
    .data_out_conv(conv_out2_11)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(14)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_21 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_1),
    .data_in(pool_out1_1),
    .o_en_conv(valid_out2_21),
    .data_out_conv(conv_out2_21)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(17)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_31 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_1),
    .data_in(pool_out1_1),
    .o_en_conv(valid_out2_31),
    .data_out_conv(conv_out2_31)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(12)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_12 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_2),
    .data_in(pool_out1_2),
    .o_en_conv(valid_out2_12),
    .data_out_conv(conv_out2_12)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(15)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_22 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_2),
    .data_in(pool_out1_2),
    .o_en_conv(valid_out2_22),
    .data_out_conv(conv_out2_22)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(18)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_32 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_2),
    .data_in(pool_out1_2),
    .o_en_conv(valid_out2_32),
    .data_out_conv(conv_out2_32)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(13)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_13 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_3),
    .data_in(pool_out1_3),
    .o_en_conv(valid_out2_13),
    .data_out_conv(conv_out2_13)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(16)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_23 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_3),
    .data_in(pool_out1_3),
    .o_en_conv(valid_out2_23),
    .data_out_conv(conv_out2_23)
);

conv #( 
    .BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(16)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width((width-2*(!PAD))/2),                //图片的宽度
    .height((height-2*(!PAD))/2),               //图片的高度
    .CORE(19)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
) conv2_33 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(pool_valid1_3),
    .data_in(pool_out1_3),
    .o_en_conv(valid_out2_33),
    .data_out_conv(conv_out2_33)
);

//------------------------------SUM-----------------------------

wire valid_out2_1,valid_out2_2,valid_out2_3;
wire signed [17:0] conv_out2_1;
wire signed [17:0] conv_out2_2;
wire signed [17:0] conv_out2_3;
assign valid_out2_1 = valid_out2_11 && valid_out2_12 && valid_out2_13;
assign valid_out2_2 = valid_out2_21 && valid_out2_22 && valid_out2_23;
assign valid_out2_3 = valid_out2_31 && valid_out2_32 && valid_out2_33;
assign conv_out2_1 = valid_out2_1 ? conv_out2_11 + conv_out2_12 + conv_out2_13 : 0;
assign conv_out2_2 = valid_out2_1 ? conv_out2_21 + conv_out2_22 + conv_out2_23 : 0;
assign conv_out2_3 = valid_out2_1 ? conv_out2_31 + conv_out2_32 + conv_out2_33 : 0;

//--------------------------------RELU2---------------------------------

wire signed [17:0] relu_out2_1;
wire signed [17:0] relu_out2_2;
wire signed [17:0] relu_out2_3;
assign relu_out2_1 = conv_out2_1 < 0 ? 0 : conv_out2_1;
assign relu_out2_2 = conv_out2_2 < 0 ? 0 : conv_out2_2;
assign relu_out2_3 = conv_out2_3 < 0 ? 0 : conv_out2_3;

//--------------------------------POOL2-----------------------------------

wire pool_valid2_1,pool_valid2_2,pool_valid2_3;
wire signed [17:0] pool_out2_1;
wire signed [17:0] pool_out2_2;
wire signed [17:0] pool_out2_3;

pool #(              
    .BITWIDTH_OUT(18)				, //输入数据位宽
    .width((width-2*(!PAD))/2-2*(!PAD)),                //图片的宽度
    .height((height-2*(!PAD))/2-2*(!PAD))               //图片的高度
) pool2_1 (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out2_1)										,                                         
    .data_in(relu_out2_1)		,               
    .data_out_pool(pool_out2_1)	,         
    .o_en_pool(pool_valid2_1)   
);

pool #(              
    .BITWIDTH_OUT(18)				, //输入数据位宽
    .width((width-2*(!PAD))/2-2*(!PAD)),                //图片的宽度
    .height((height-2*(!PAD))/2-2*(!PAD))               //图片的高度
) pool2_2 (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out2_2)										,                                         
    .data_in(relu_out2_2)		,               
    .data_out_pool(pool_out2_2)	,         
    .o_en_pool(pool_valid2_2)   
);

pool #(              
    .BITWIDTH_OUT(18)				, //输入数据位宽
    .width((width-2*(!PAD))/2-2*(!PAD)),                //图片的宽度
    .height((height-2*(!PAD))/2-2*(!PAD))               //图片的高度
) pool2_3 (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out2_3)										,                                         
    .data_in(relu_out2_3)		,               
    .data_out_pool(pool_out2_3)	,         
    .o_en_pool(pool_valid2_3)   
);

//---------------------------------FC-------------------------------

fc # (
	.BITWIDTH	(18)	,
    .WEIGHT_NUM (100)	,			//一个pool层输出的数据量
    .CLASEE_NUM (3)  ,
    .BIAS_NUM 	(10) 	
) uut (
    .clk	(clk)							,
	.rst_n	(rst_n)							,
	.en1	(pool_valid2_1)							,
	.en2	(pool_valid2_2)							,
	.en3	(pool_valid2_3)							,                   
	.data_in_1	(pool_out2_1)	,
	.data_in_2	(pool_out2_2)	,
	.data_in_3	(pool_out2_3)	,/*
	.calc_out1 (tem1),
	.calc_out2 (tem2),
	.calc_out3 (tem3),
	.calc_out4 (tem4),
	.calc_out5 (tem5),
	.calc_out6 (tem6),
	.calc_out7 (tem7),
	.calc_out8 (tem8),
	.calc_out9 (tem9),
	.calc_out10(tem10),	*/		 
	.output_en_fc(valid_out)					,
	.max(data_out),
	.result(result),
	.compare_flag_fc(flag)		
);

	
endmodule
