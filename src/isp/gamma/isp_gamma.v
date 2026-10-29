/*************************************************************************
    > File Name: isp_gamma.v
    > Author: bxq
    > Mail: 544177215@qq.com
    > Created Time: Thu 21 Jan 2021 21:50:04 GMT
 ************************************************************************/
`timescale 1 ns / 1 ps

/*
 * ISP - Gamma (Look-up table)
 * 可以用np.uint8(np.power(np.double(range(256))/255, 1/2.2) * 255)生成g=1/2.2的gamma表
 * CFG_TABLE_BITS小于BITS时会损失精度
 */

module isp_gamma
#(
	parameter BITS = 16,
	parameter WIDTH = 1920,
	parameter HEIGHT = 1080
)
(
	input pclk,
	input rst_n,

    input  	 	switch1	,
	input [1:0]	day_night,
	input in_href,
    input in_hsync,
	input in_vsync,
	input [BITS-1:0] in_data_y,
    input [BITS-1:0] in_data_u,
    input [BITS-1:0] in_data_v,

	output out_href,
    output out_hsync,
	output out_vsync,
	output [BITS-1:0] out_data_y,
    output [BITS-1:0] out_data_u,
    output [BITS-1:0] out_data_v

);


//wire [BITS-1:0]	o_data_0p7;
wire [BITS-1:0]	o_data_0p5;
wire [BITS-1:0]	o_data_1p0;
wire [BITS-1:0]	o_data_1p5;
//wire [BITS-1:0]	o_data_1p2;

Curve_Gamma_0P5 Curve_Gamma_0P5_inst
(
   .Pre_Data        (in_data_y),
   .Post_Data       (o_data_0p5)
);
Curve_Gamma_1P0 Curve_Gamma_1P0_inst
(
   .Pre_Data	(in_data_y		)	,
   .Post_Data	(o_data_1p0	)
);
Curve_Gamma_1P5 Curve_Gamma_1P5_inst
(
   .Pre_Data	(in_data_y		)	,
   .Post_Data	(o_data_1p5	)
);

reg [BITS-1:0] data_y;
reg [BITS-1:0] data_u;
reg [BITS-1:0] data_v;
always @ (posedge pclk or negedge rst_n) 
begin
	if (!rst_n) begin
		data_y <= 0;
        data_u <= 0;
        data_v <= 0;
	end
	else if(switch1)begin
		case(day_night)
		2'd0:begin	
			data_y <= o_data_1p0;
			data_u <= in_data_u;
			data_v <= in_data_v;	
		end
		2'd1:begin	
			data_y <= o_data_0p5;
			data_u <= in_data_u;
			data_v <= in_data_v;	
		end
		2'd2:begin	
			data_y <= o_data_1p5;
			data_u <= in_data_u;
			data_v <= in_data_v;	
		end
		default : begin	
			data_y <= o_data_1p0;
			data_u <= in_data_u;
			data_v <= in_data_v;	
		end
		endcase
	end 
	else begin
			data_y <= in_data_y;
			data_u <= in_data_u;
			data_v <= in_data_v;	
	end
end

reg [1:0] href_dly;
reg [1:0] hsync_dly;
reg [1:0] vsync_dly;
always @ (posedge pclk or negedge rst_n) begin
	if (!rst_n) begin
		href_dly  <= 0;
        hsync_dly <= 0;
		vsync_dly <= 0;
	end
	else begin
		href_dly  <= {href_dly[0], in_href};
        hsync_dly <= {hsync_dly[0], in_hsync};
		vsync_dly <= {vsync_dly[0], in_vsync};
	end
end

assign out_href  = href_dly[1];
assign out_hsync = hsync_dly[1];
assign out_vsync = vsync_dly[1];
assign out_data_y  = out_href ? data_y : {BITS{1'b0}};
assign out_data_u  = out_href ? data_u : {BITS{1'b0}};
assign out_data_v  = out_href ? data_v : {BITS{1'b0}};
    
endmodule
