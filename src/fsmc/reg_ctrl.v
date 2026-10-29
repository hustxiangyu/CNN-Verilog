`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:50:41 11/03/2019 
// Design Name: 
// Module Name:    reg_ctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module reg_ctrl
(
	input             clock,
	input             reset,
	input             wr,
	input             rd,
	input      [23:0] addr,
	input      [15:0] wr_data,
	output reg [15:0] rd_data,

	output     [15:0] reg000_o,
	output     [15:0] reg001_o,
	output     [15:0] reg002_o,
	output     [15:0] reg003_o,
	output     [15:0] reg004_o,
	output     [15:0] reg005_o,
	output     [15:0] reg006_o,
	output     [15:0] reg007_o,
	output     [15:0] reg008_o,
	output     [15:0] reg009_o,
	output     [15:0] reg010_o,
	output     [15:0] reg011_o,
	output     [15:0] reg012_o,
	output     [15:0] reg013_o,
	output     [15:0] reg014_o,
	output     [15:0] reg015_o,
	output     [15:0] reg016_o,
	output     [15:0] reg017_o,
	output     [15:0] reg018_o,
	output     [15:0] reg019_o,
	output     [15:0] reg020_o,
	output     [15:0] reg021_o,
	output     [15:0] reg022_o,
	output     [15:0] reg023_o,
	output     [15:0] reg024_o,
	output     [15:0] reg025_o,
	output     [15:0] reg026_o,
	output     [15:0] reg027_o,
	output     [15:0] reg028_o,
	output     [15:0] reg029_o,
	output     [15:0] reg030_o,
	output     [15:0] reg031_o,

	input      [15:0] reg1024_i,
	input      [15:0] reg1025_i,
	input      [15:0] reg1026_i,
	input      [15:0] reg1027_i,
	input      [15:0] reg1028_i,
	input      [15:0] reg1029_i,
	input      [15:0] reg1030_i,
	input      [15:0] reg1031_i
);


reg [15:0] mem_out[0:31];//可根据需要修改大小

assign reg000_o = mem_out[16'd0];
assign reg001_o = mem_out[16'd1];
assign reg002_o = mem_out[16'd2];
assign reg003_o = mem_out[16'd3];
assign reg004_o = mem_out[16'd4];
assign reg005_o = mem_out[16'd5];
assign reg006_o = mem_out[16'd6];
assign reg007_o = mem_out[16'd7];
assign reg008_o = mem_out[16'd8];
assign reg009_o = mem_out[16'd9];
assign reg010_o = mem_out[16'd10];
assign reg011_o = mem_out[16'd11];
assign reg012_o = mem_out[16'd12];
assign reg013_o = mem_out[16'd13];
assign reg014_o = mem_out[16'd14];
assign reg015_o = mem_out[16'd15];
assign reg016_o = mem_out[16'd16];
assign reg017_o = mem_out[16'd17];
assign reg018_o = mem_out[16'd18];
assign reg019_o = mem_out[16'd19];
assign reg020_o = mem_out[16'd20];
assign reg021_o = mem_out[16'd21];
assign reg022_o = mem_out[16'd22];
assign reg023_o = mem_out[16'd23];
assign reg024_o = mem_out[16'd24];
assign reg025_o = mem_out[16'd25];
assign reg026_o = mem_out[16'd26];
assign reg027_o = mem_out[16'd27];
assign reg028_o = mem_out[16'd28];
assign reg029_o = mem_out[16'd29];
assign reg030_o = mem_out[16'd30];
assign reg031_o = mem_out[16'd31];


always @(posedge clock or posedge reset)
begin
	if(reset)
	begin	
		  mem_out[0] <= 16'h0000;	//0x00,
		  mem_out[1] <= 16'h0000;	//0x01,
		  mem_out[2] <= 16'h0000;	//0x02,
		  mem_out[3] <= 16'h0000;	//0x03,
		  mem_out[4] <= 16'h0000;	//0x04,
		  mem_out[5] <= 16'h0000;	//0x05,
		  mem_out[6] <= 16'h0000;	//0x06,
		  mem_out[7] <= 16'h0000;	//0x07,
		  mem_out[8] <= 16'h0000;	//0x08,
		  mem_out[9] <= 16'h0000;	//0x09,
		 mem_out[10] <= 16'h0000;	//0x0a,
		 mem_out[11] <= 16'h0000;	//0x0b,
		 mem_out[12] <= 16'h0000;	//0x0c,
		 mem_out[13] <= 16'h0000;	//0x0d,
		 mem_out[14] <= 16'h0000;	//0x0e,
		 mem_out[15] <= 16'h0000;	//0x0f,
		 mem_out[16] <= 16'h0000;	//0x10,
		 mem_out[17] <= 16'h0000;	//0x11,
		 mem_out[18] <= 16'h0000;	//0x12,
		 mem_out[19] <= 16'h0000;	//0x13,
		 mem_out[20] <= 16'h0000;	//0x14,
		 mem_out[21] <= 16'h0000;	//0x15,
		 mem_out[22] <= 16'h0000;	//0x16,
		 mem_out[23] <= 16'h0000;	//0x17,
		 mem_out[24] <= 16'h0000;	//0x18,
		 mem_out[25] <= 16'h0000;	//0x19,
		 mem_out[26] <= 16'h0000;	//0x1a,
		 mem_out[27] <= 16'h0000;	//0x1b,
		 mem_out[28] <= 16'h0000;	//0x1c,
		 mem_out[29] <= 16'h0000;	//0x1d,
		 mem_out[30] <= 16'h0000;	//0x1e,
		 mem_out[31] <= 16'h0000;	//0x1f,
	end
	else if(wr)
		mem_out[addr[15:0]] <= wr_data;	//注意寻址范围
	else
		;
end


always @(*)
begin
	if(reset)
		rd_data = 16'h0000;
	else
	begin
		if(addr[15:0] < 16'd10)				//可读写寄存器,根据需要修改条件
			rd_data = mem_out[addr[15:0]];
		else											//读寄存器
		case(addr[15:0])
			16'd1024 : rd_data = reg1024_i;	//0x0400,
			16'd1025 : rd_data = reg1025_i;	//0x0401,
			16'd1026 : rd_data = reg1026_i;	//0x0402,
			16'd1027 : rd_data = reg1027_i;	//0x0403,
			16'd1028 : rd_data = reg1028_i;	//0x0404,
			16'd1029 : rd_data = reg1029_i;	//0x0405,
			16'd1030 : rd_data = reg1030_i;	//0x0406,
			16'd1031 : rd_data = reg1031_i;	//0x0407,
			default  : rd_data = 16'h0000;
		endcase
	end	
end


endmodule


