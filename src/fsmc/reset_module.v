`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:32:08 11/01/2019 
// Design Name: 
// Module Name:    reset_module 
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
module reset_module
(
	input  clock,
	input  reset_in,
	output reg reset_out
);

reg [15:0] cnt;
always@(posedge clock or posedge reset_in)//Delay for steady state
begin
	if(reset_in)
		cnt <= 0;
	else if(cnt < 16'hff)
		cnt <= cnt + 1'b1;
	else
		cnt <= cnt;
end


//reg reset_out;
always@(posedge clock or posedge reset_in)//reset_sync
begin
	if(reset_in)
		reset_out <= 1'b1;
	else if(cnt == 16'hff)
		reset_out <= 1'b0;
	else
		reset_out <= 1'b1;
end


endmodule

 
 