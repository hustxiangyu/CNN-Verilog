`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02-27-2025 22:18:34
// Design Name:
// Module Name: top
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


module top #(
	parameter BITWIDTH = 9,              //输入数据位宽
    parameter BITWIDTH_OUT   = 11				,     
	parameter PAD = 1,
    parameter stride = 1,                //步长
    parameter width = 28,                //图片的宽度
    parameter height = 28,               //图片的高度
	parameter CORE = 1							    //第几个卷积核，根绝不同的卷积核切换不同的weight
)(
	input clk,
	input rst_n,
	input [BITWIDTH-1:0] data_in,
	input valid_in,
	output [BITWIDTH_OUT-1:0] data_out1,
	output valid_out1
);
	
wire valid_out;
wire [BITWIDTH_OUT-1:0] data_out;
wire finish;
	
conv #( 
    .BITWIDTH(BITWIDTH),              //输入数据位宽
    .BITWIDTH_OUT(BITWIDTH_OUT)				, 
	.PAD(PAD),
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
    .CORE(CORE)							    //第几个卷积核，根绝不同的卷积核切换不同的weight
)uut1 (
    .clk(clk),
    .rst_n(rst_n),
    .w_en(valid_in),
    .data_in(data_in),
    .o_en_conv(valid_out),
    .data_out_conv(data_out),
	.finish(finish)
);

pool #( 
    .BITWIDTH(BITWIDTH_OUT),              //输入数据位宽
    .BITWIDTH_OUT(BITWIDTH_OUT)				, 
    .width(width-2*(!PAD)),                //图片的宽度
    .height(height-2*(!PAD))               //图片的高度
)uut (
    .clk(clk)										,
    .rst_n(rst_n)									,
    .w_en(valid_out)										,                                         
    .data_in(data_out)		,               
    .data_out_pool(data_out1)	,         
    .o_en_pool(valid_out1)   
);
	
endmodule
