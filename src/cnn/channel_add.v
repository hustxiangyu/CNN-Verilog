`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-04-2025 20:16:12
// Design Name:
// Module Name: channel_add
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


module channel_add # (
	parameter BITWIDTH = 9              //输入数据位宽
)(
	input clk,
	input rst_n,
	input in_valid,
	input [BITWIDTH-1:0] data_in1,
	input [BITWIDTH-1:0] data_in2,
	input [BITWIDTH-1:0] data_in3,
	output reg out_valid,
	output reg [BITWIDTH:0] data_out
);
	
always @(posedge clk) begin
	if (!rst_n) begin
		data_out <= 0;
		out_valid <= 0;
	end else if (in_valid) begin 
		data_out <= data_in1 + data_in2 + data_in3;
		out_valid <= 1;
	end else begin
		data_out <= 0;
		out_valid <= 0;
	end
end
	
endmodule
