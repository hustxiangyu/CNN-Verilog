`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-06-2025 19:44:56
// Design Name:
// Module Name: cnn_mult
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


module cnn_mult # (
	parameter DATAA_WIDTH = 16,  //  ‰»ÎŒªøÌ
    parameter DATAB_WIDTH = 16,
    parameter RESULT_WIDTH = 32
)(
	input	[DATAA_WIDTH -1:0]    dataa1,
	input	[DATAB_WIDTH -1:0]    datab1,
	output	[RESULT_WIDTH-1:0]  result1,
	input	[DATAA_WIDTH -1:0]    dataa2,
	input	[DATAB_WIDTH -1:0]    datab2,
	output	[RESULT_WIDTH-1:0]  result2,
	input	[DATAA_WIDTH -1:0]    dataa3,
	input	[DATAB_WIDTH -1:0]    datab3,
	output	[RESULT_WIDTH-1:0]  result3,
	input	[DATAA_WIDTH -1:0]    dataa4,
	input	[DATAB_WIDTH -1:0]    datab4,
	output	[RESULT_WIDTH-1:0]  result4,
	input	[DATAA_WIDTH -1:0]    dataa5,
	input	[DATAB_WIDTH -1:0]    datab5,
	output	[RESULT_WIDTH-1:0]  result5,
	input	[DATAA_WIDTH -1:0]    dataa6,
	input	[DATAB_WIDTH -1:0]    datab6,
	output	[RESULT_WIDTH-1:0]  result6,
	input	[DATAA_WIDTH -1:0]    dataa7,
	input	[DATAB_WIDTH -1:0]    datab7,
	output	[RESULT_WIDTH-1:0]  result7,
	input	[DATAA_WIDTH -1:0]    dataa8,
	input	[DATAB_WIDTH -1:0]    datab8,
	output	[RESULT_WIDTH-1:0]  result8,
	input	[DATAA_WIDTH -1:0]    dataa9,
	input	[DATAB_WIDTH -1:0]    datab9,
	output	[RESULT_WIDTH-1:0]  result9
    );
	/*
	wire	[RESULT_WIDTH-1:0]	sub_wire1;
	assign result1 = sub_wire1;
	wire	[RESULT_WIDTH-1:0]	sub_wire2;
	assign result2 = sub_wire2;
	wire	[RESULT_WIDTH-1:0]	sub_wire3;
	assign result3 = sub_wire3;
	wire	[RESULT_WIDTH-1:0]	sub_wire4;
	assign result4 = sub_wire4;
	wire	[RESULT_WIDTH-1:0]	sub_wire5;
	assign result5 = sub_wire5;
	wire	[RESULT_WIDTH-1:0]	sub_wire6;
	assign result6 = sub_wire6;
	wire	[RESULT_WIDTH-1:0]	sub_wire7;
	assign result7 = sub_wire7;
	wire	[RESULT_WIDTH-1:0]	sub_wire8;
	assign result8 = sub_wire8;
	wire	[RESULT_WIDTH-1:0]	sub_wire9;
	assign result9 = sub_wire9;*/
	
	lpm_mult	lpm_mult_component1 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa1),
				.datab (datab1),
				.result (result1),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component2 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa2),
				.datab (datab2),
				.result (result2),
				.sum (1'b0));
	
	lpm_mult	lpm_mult_component3 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa3),
				.datab (datab3),
				.result (result3),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component4 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa4),
				.datab (datab4),
				.result (result4),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component5 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa5),
				.datab (datab5),
				.result (result5),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component6 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa6),
				.datab (datab6),
				.result (result6),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component7 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa7),
				.datab (datab7),
				.result (result7),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component8 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa8),
				.datab (datab8),
				.result (result8),
				.sum (1'b0));
				
	lpm_mult	lpm_mult_component9 (
				.aclr (1'b0),
				.clken (1'b1),
				.clock (1'b0),
				.dataa (dataa9),
				.datab (datab9),
				.result (result9),
				.sum (1'b0));
				
	defparam
		lpm_mult_component1.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component1.lpm_representation = "SIGNED",
		lpm_mult_component1.lpm_type = "LPM_MULT",
		lpm_mult_component1.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component1.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component1.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component1.lpm_widths = 1,
		
		lpm_mult_component2.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component2.lpm_representation = "SIGNED",
		lpm_mult_component2.lpm_type = "LPM_MULT",
		lpm_mult_component2.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component2.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component2.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component2.lpm_widths = 1,
		
		lpm_mult_component3.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component3.lpm_representation = "SIGNED",
		lpm_mult_component3.lpm_type = "LPM_MULT",
		lpm_mult_component3.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component3.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component3.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component3.lpm_widths = 1,
		
		lpm_mult_component4.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component4.lpm_representation = "SIGNED",
		lpm_mult_component4.lpm_type = "LPM_MULT",
		lpm_mult_component4.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component4.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component4.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component4.lpm_widths = 1,
		
		lpm_mult_component5.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component5.lpm_representation = "SIGNED",
		lpm_mult_component5.lpm_type = "LPM_MULT",
		lpm_mult_component5.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component5.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component5.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component5.lpm_widths = 1,
		
		lpm_mult_component6.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component6.lpm_representation = "SIGNED",
		lpm_mult_component6.lpm_type = "LPM_MULT",
		lpm_mult_component6.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component6.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component6.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component6.lpm_widths = 1,
		
		lpm_mult_component7.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component7.lpm_representation = "SIGNED",
		lpm_mult_component7.lpm_type = "LPM_MULT",
		lpm_mult_component7.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component7.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component7.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component7.lpm_widths = 1,
		
		lpm_mult_component8.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component8.lpm_representation = "SIGNED",
		lpm_mult_component8.lpm_type = "LPM_MULT",
		lpm_mult_component8.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component8.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component8.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component8.lpm_widths = 1,
		
		lpm_mult_component9.lpm_hint = "MAXIMIZE_SPEED=5",
		lpm_mult_component9.lpm_representation = "SIGNED",
		lpm_mult_component9.lpm_type = "LPM_MULT",
		lpm_mult_component9.lpm_widtha = DATAA_WIDTH,
		lpm_mult_component9.lpm_widthb = DATAB_WIDTH,
		lpm_mult_component9.lpm_widthp = RESULT_WIDTH,
		lpm_mult_component9.lpm_widths = 1;

	
endmodule
