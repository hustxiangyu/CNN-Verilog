`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:50:18 11/03/2019 
// Design Name: 
// Module Name:    wr_bram_ctrl 
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
module wr_bram_ctrl
(
	input         clock,
	input         reset,
	input         wr,
	input  [23:0] addr,
	input  [15:0] wr_data,
	
	input         clkb,
	input         enb,
	input  [11:0] addrb,
	output [15:0] doutb
);


wire        clka;
wire        ena;
wire        wea;
wire [11:0] addra;
wire [15:0] dina;

//ram16x4096 ram16x4096_wr
//(
//  .clka(clock), // input clka
//  .ena(1'b1), // input ena
//  .wea(wr), // input [0 : 0] wea
//  .addra(addr[11:0]), // input [11 : 0] addra
//  .dina(wr_data), // input [15 : 0] dina
//  
//  .clkb(clkb), // input clkb
//  .enb(enb), // input enb
//  .addrb(addrb), // input [11 : 0] addrb
//  .doutb(doutb) // output [15 : 0] doutb
//);

ram16x4096 ram16x4096_wr
(
  .wrclock(clock), // input clka
  .wren(wr), // input [0 : 0] wea
  .wraddress(addr[11:0]), // input [11 : 0] addra
  .data(wr_data), // input [15 : 0] dina
  
  .rdclock(clkb), // input clkb
  .rden(enb), // input enb
  .rdaddress(addrb), // input [11 : 0] addrb
  .q(doutb) // output [15 : 0] doutb
);


endmodule



