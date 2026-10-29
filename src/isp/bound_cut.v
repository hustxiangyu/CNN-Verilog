`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 05-18-2025 19:26:47
// Design Name:
// Module Name: bound_cut
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


module bound_cut
#(
	parameter BITS = 8
)
(
	input	wire				clk,
	input	wire				rst_n,
	input	wire				valid,
	input	wire	[BITS-1:0]	data,
	input	wire				vs_n,
	input	wire	[15:0]		vin_xres,	
	input	wire	[15:0]		vin_yres,	
	input	wire	[15:0]		vout_xres,	
	input	wire	[15:0]		vout_yres,	
	output	reg 				valid_out,
	output	reg 	[BITS-1:0]	data_out			

    );
	
	reg	[15:0]		vin_x			= 0;	
	reg	[15:0]		vin_y			= 0;	
	
	wire [15:0] x_left;
	wire [15:0] x_right;
	wire [15:0] y_up;
	wire [15:0] y_down;
	
	assign x_left = (vin_xres-vout_xres)/2;
	assign x_right = (vin_xres+vout_xres)/2;
	assign y_up = (vin_yres-vout_yres)/2;
	assign y_down = (vin_yres+vout_yres)/2;
	
	
	always@(posedge	clk)
	begin	//输入视频水平计数和垂直计数，按像素个数计数。
		if(vs_n == 0 || rst_n == 0)begin
			vin_x			<= 0;
			vin_y			<= 0;
		end
		else if (valid == 1)begin		//当前输入视频数据有效
			if( vin_x < vin_xres -1 )begin						//vin_xres = 输入视频宽度
				vin_x	<= vin_x + 1;
			end
			else begin
				vin_x		<= 0;
				vin_y		<= vin_y + 1;
			end
		end
	end	//always
	
	always@(posedge clk) begin
		if(vin_x >= x_left && vin_x < x_right && vin_y >= y_up && vin_y < y_down&&valid)begin
			valid_out <= 1;
			data_out <= data;
		end else begin
			valid_out <= 0;
			data_out <= 0;
		end
	end
	
endmodule
