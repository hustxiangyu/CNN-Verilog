/*-----------------------------------------------------------------------
								 \\\|///
							   \\  - -  //
								(  @ @  )  
+-----------------------------oOOo-(_)-oOOo-----------------------------+
CONFIDENTIAL IN CONFIDENCE
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo (Thereturnofbingo).
In the event of publication, the following notice is applicable:
Copyright (C) 2012-20xx CrazyBingo Corporation
The entire notice above must be reproduced on all authorized copies.
Author				:		CrazyBingo
Technology blogs 	: 		www.crazyfpga.com
Email Address 		: 		crazyfpga@qq.com
Filename			:		KEY_2bit_Test.v
Date				:		2022-02-08
Description			:		Basic KEY Test design.
Modification History	:
Date			By			Version			Change Description
=========================================================================
22/02/08		CrazyBingo	1.0				Original
-------------------------------------------------------------------------
|                                     Oooo								|
+-------------------------------oooO--(   )-----------------------------+
                               (   )   ) /
                                \ (   (_/
                                 \_)
-----------------------------------------------------------------------*/

`timescale 1ns/1ns
module KEY_2bit_Test
(
	//global clock
//	input				clk,            //12MHz
//	input				rst_n,
    input               pll_inst1_CLKOUT0,
    input               pll_inst1_LOCKED,

    //key interface
    input   [3:0]       key_data,
    
	//led interface
	output  reg	[11:0]    	img_width,
	output  reg	[1:0]		gamma_light,
	output  reg	[1:0]		contrast_light,
	output	reg	[3:0]		display_choice,
	output 	key_flag
);
wire    clk_ref = pll_inst1_CLKOUT0;    //100MHz
wire    sys_rst_n = pll_inst1_LOCKED;


//----------------------------------
//Key scan with counter detect扫描部分
//wire			key_flag;
wire	[3:0]	key_value;
key_counter_scan		
#(
	.KEY_WIDTH	(4)
)
u_key_counter_scan
(
	//global
	.clk				(clk_ref),
	.rst_n				(sys_rst_n),
	
	//key interface
	.key_data			(key_data),		
	
	//user interface
	.key_flag			(key_flag),
	.key_value			(key_value)	
);

//key_action按键响应部分

always @ (posedge clk_ref or negedge sys_rst_n)
begin
    if(!sys_rst_n)	
	begin
		gamma_light <= 2'd2;
		display_choice <= 4'd0;
	end
	else if(key_flag && key_value[0]) 
		begin
			display_choice <= (display_choice+1)%16;
		end
    else if(key_flag && key_value[1])  //判断按键是否有效按下,按键有效是低电平,所以取反
		begin			
			gamma_light <= (gamma_light+1'b1)%3;
		end
	else if(key_flag && key_value[2]) 
		begin
			contrast_light <= (contrast_light+1'b1)%3;
		end
	else
		begin
			gamma_light<=gamma_light;
			display_choice <= display_choice;
		end
end


endmodule


