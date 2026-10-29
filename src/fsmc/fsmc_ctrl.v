`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:23:59 11/01/2019 
// Design Name: 
// Module Name:    fsmc_ctrl 
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
module fsmc_ctrl
(
	input				clock,
	input				reset,
	
	input				FSMC_CS,
	input				FSMC_CLK,
	input				FSMC_RD,
	input				FSMC_WR,
	output			FSMC_NWAIT,
	input				FSMC_NL,
	output			FSMC_INT,
	input	 [1:0]	FSMC_NBL,
	inout	 [15:0]	FSMC_ADDR_DATA,
	input	 [7:0]	FSMC_ADDR_H,
	
	output			bus_wr_en,
	output			bus_rd_en,
	output reg [23:0]	bus_addr,
	output reg [15:0]	bus_wr_data,
	input  [15:0]	bus_rd_data
);


wire FSMC_CS_WR;
assign FSMC_CS_WR = (!FSMC_CS) & (!FSMC_WR);


//reg [3:0] FSMC_CS_WR_sync;
//always@(posedge clock or posedge reset)
//begin
//	if(reset)
//		FSMC_CS_WR_sync <= 4'b1111;
//	else
//		FSMC_CS_WR_sync <= {FSMC_CS_WR_sync[2:0],FSMC_CS_WR};
//end


//wire FSMC_CS_WR_pos;
//assign FSMC_CS_WR_pos = (FSMC_CS_WR_sync[2:1] == 2'b01);//可以根据需要设定写使能的时刻


reg [7:0] FSMC_CS_WR_sync;
always@(posedge clock or posedge reset)
begin
	if(reset)
		FSMC_CS_WR_sync <= 8'b11111111;
	else
		FSMC_CS_WR_sync <= {FSMC_CS_WR_sync[6:0],FSMC_CS_WR};
end


wire FSMC_CS_WR_pos;
assign FSMC_CS_WR_pos = (FSMC_CS_WR_sync[5:4] == 2'b01);//可以根据需要设定写使能的时刻


assign bus_wr_en = FSMC_CS_WR_pos;//对外总线写使能


assign bus_rd_en = !bus_wr_en;//对外总线读使能，只要不写就读使能，把数据提前准备好，在bus_io_flag为高时把数据送出


//reg [23:0] bus_addr;
always@(posedge FSMC_NL or posedge reset)//对外总线地址锁存，也可以通过系统时钟先获取FSMC_NL的上升沿，再根据上升沿锁存地址，这样的话需要增加FSMC_AHT、FSMC_DST时间，同时bus_wr_en时刻需要往后平移
begin
	if(reset)
		bus_addr <= 24'd0;
	else
		bus_addr <= {FSMC_ADDR_H,FSMC_ADDR_DATA};//对外总线地址锁存
end


//reg [15:0] bus_wr_data;
always @(*)
begin
	if(reset)
		bus_wr_data = 16'h0000;
	else
		bus_wr_data = FSMC_ADDR_DATA;//对外总线写数据
end


wire bus_io_flag;
assign bus_io_flag = (!FSMC_CS) & (!FSMC_RD);//总线输入输出方向标志，在bus_io_flag为高时把数据送出


assign FSMC_ADDR_DATA = bus_io_flag ? bus_rd_data : 16'hzzzz;//对外总线读数据输出


endmodule




