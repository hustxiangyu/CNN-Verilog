`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-04-2025 20:11:59
// Design Name:
// Module Name: three_channel
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


module three_channel # (
	parameter BITWIDTH = 9,              //输入数据位宽
    parameter BITWIDTH_OUT   = 11				,     
	parameter PAD = 1,
    parameter stride = 1,                //步长
    parameter width = 28,                //图片的宽度
    parameter height = 28               //图片的高度
)(
	input clk,
	input rst_n,
	input signed [BITWIDTH-1:0] data_in,
	input valid_in,
	output signed [BITWIDTH_OUT:0] data_out,
	output valid_out,
	output wire signed [BITWIDTH_OUT-1:0] data_out1,
	output wire signed [BITWIDTH_OUT-1:0] data_out2,
	output wire signed [BITWIDTH_OUT-1:0] data_out3,
	output wire valid1,
	output wire valid2,
	output wire valid3
); 
	
top #( 
    .BITWIDTH(BITWIDTH),              //输入数据位宽
    .BITWIDTH_OUT(BITWIDTH_OUT)				,     
	.PAD(PAD),
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
	.CORE(1)	
)uut1 (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out1(valid1),
    .data_out1(data_out1)
);

top #( 
    .BITWIDTH(BITWIDTH),              //输入数据位宽
    .BITWIDTH_OUT(BITWIDTH_OUT)				,        
	.PAD(PAD),       
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
	.CORE(2)	
)uut2 (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out1(valid2),
    .data_out1(data_out2)
);

top #( 
    .BITWIDTH(BITWIDTH),              //输入数据位宽
    .BITWIDTH_OUT(BITWIDTH_OUT)				,           
	.PAD(PAD),    
    .stride(1),                //步长
    .width(width),                //图片的宽度
    .height(height),               //图片的高度
	.CORE(3)	
)uut3 (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out1(valid3),
    .data_out1(data_out3)
);

channel_add # (
	.BITWIDTH(BITWIDTH_OUT)              //输入数据位宽
) add (
	.clk(clk),
	.rst_n(rst_n),
	.in_valid(valid1 && valid2 && valid3),
	.data_in1(data_out1),
	.data_in2(data_out2),
	.data_in3(data_out3),
	.out_valid(valid_out),
	.data_out(data_out)
);
	
endmodule
