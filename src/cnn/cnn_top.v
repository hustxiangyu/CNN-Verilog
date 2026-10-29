`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-05-2025 18:59:32
// Design Name:
// Module Name: cnn_top
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


module cnn_top #(
	parameter PAD = 1,
    parameter width = 28,                //图片的宽度
    parameter height = 28               //图片的高度
)(
	input clk,
	input rst_n,
	input valid_in,
	input signed [8:0] data_in,
	output valid_out,
	output signed [21:0] data_out
    );
	
wire floor1_valid;
wire signed [12:0] floor1_data;

wire signed [15-1:0] data_out1;
wire signed [15-1:0] data_out2;
wire signed [15-1:0] data_out3;
wire valid1;
wire valid2;
wire valid3;

wire flag;
	
three_channel # (
	.BITWIDTH(9),              //输入数据位宽
    .BITWIDTH_OUT(11)				,     
	.PAD(PAD),
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height)               //图片的高度
)uut1 (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out(floor1_valid),
    .data_out(floor1_data)
);

three_channel # (
	.BITWIDTH(12),              //输入数据位宽
    .BITWIDTH_OUT(15)				,   
	.PAD(PAD),
    .stride(1),                //步长
    .width(width/2 - !PAD),                //图片的宽度
    .height(height/2 - !PAD)               //图片的高度
)uut2 (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(floor1_valid),
    .data_in(floor1_data),
    //.valid_out(valid_out),
    //.data_out(data_out),
	.data_out1(data_out1),
	.data_out2(data_out2),
	.data_out3(data_out3),
	.valid1(valid1),
	.valid2(valid2),
	.valid3(valid3)
);

fc # (
	.BITWIDTH	(15)	,
    .WEIGHT_NUM (25)	,			//一个pool层输出的数据量
    .CLASEE_NUM (3)  ,
    .BIAS_NUM 	(10) 	
) uut (
    .clk	(clk)							,
	.rst_n	(rst_n)							,
	.en1	(valid1)							,
	.en2	(valid2)							,
	.en3	(valid3)							,                   
	.data_in_1	(data_out1)	,
	.data_in_2	(data_out2)	,
	.data_in_3	(data_out3)	,/*
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
	.compare_flag_fc(flag)		
);
	
endmodule
