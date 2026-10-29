`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:24:48 11/03/2019 
// Design Name: 
// Module Name:    rd_bram_ctrl 
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
module rd_bram_ctrl
(
	input         clock,
	input         reset,
	input         rd,
	input  [23:0] addr,
	output [15:0] rd_data,
	
	input         clka,
//	input         ena,
	input         wea,
	input  [11:0] addra,
	input  [15:0] dina
);


wire        clkb;
wire        enb;
wire [11:0] addrb;
wire [15:0] doutb;

//ram16x4096 ram16x4096_rd
//(
//  .clka(clka), // input clka
//  .ena(ena), // input ena
//  .wea(wea), // input [0 : 0] wea
//  .addra(addra), // input [11 : 0] addra
//  .dina(dina), // input [15 : 0] dina
//  
//  .clkb(clock), // input clkb
//  .enb(rd), // input enb
//  .addrb(addr[11:0]), // input [11 : 0] addrb
//  .doutb(doutb) // output [15 : 0] doutb
//);

ram16x4096 ram16x4096_rd
(
  .wrclock(clka), // input clka
  .wren(wea), // input [0 : 0] wea
  .wraddress(addra), // input [11 : 0] addra
  .data(dina), // input [15 : 0] dina
  
  .rdclock(clock), // input clkb
  .rden(rd), // input enb
  .rdaddress(addr[11:0]), // input [11 : 0] addrb
  .q(doutb) // output [15 : 0] doutb
);


assign rd_data = doutb;


endmodule



