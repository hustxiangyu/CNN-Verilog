`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04-16-2025 19:04:25
// Design Name:
// Module Name: hdmi_top
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


module hdmi_top 
(
	input	wire			clk_74m,
	input	wire			clk_100m,
	input 	wire			rst_n,
	
	input	wire  	[11:0]	h_real		 ,//输出目标水平分辨率
	input	wire   	[11:0]	v_real		 ,//输出目标垂直分辨率	 
	
	input	wire	[3:0]	cnn_result,
//	input	wire	[6:0]	cnn_fps_data,
	input	wire	[11:0]	uart_control,
	
	input	wire   	[15:0]	vga_rgb,
	output 	wire 			rdreq,
	output	wire			lcd_framesync,
		
	output  wire            hdmi_clk,
    output  wire   [23:0]   hdmi_d,
    output  wire            hdmi_de,
    output  wire            hdmi_hs,
	output  wire            hdmi_vs,
	output	wire			hdmi_nreset,
	output	wire			hdmi_cfg_error,
	output	wire			hdmi_cfg_done,
    inout                   hdmi_scl,
    inout                   hdmi_sda 
);

wire [31:0] lut_data;
wire [9:0 ] lut_index;

wire            vga_hs          ;
wire            vga_vs          ;
wire            vga_de          ;
wire    [7:0]   vga_r           ;
wire    [7:0]   vga_g           ;
wire    [7:0]   vga_b           ;

assign hdmi_clk = clk_74m;
assign hdmi_d = hdmi_d_r;
assign hdmi_de = hdmi_de_r;
assign hdmi_hs = hdmi_hs_r;
assign hdmi_vs = hdmi_vs_r;
assign hdmi_nreset = rst_n ;


	
i2c_config i2c_config_m0(
	.rst                        (~rst_n              ),
	.clk                        (clk_100m               ),
	.clk_div_cnt                (16'd499                  ),
	.i2c_addr_2byte             (1'b0                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (hdmi_cfg_error                ),
	.done                       (hdmi_cfg_done                 ),
	.i2c_scl                    (hdmi_scl                 ),
	.i2c_sda                    (hdmi_sda                 )
);
//configure look-up table
lut_si9134 lut_si9134_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
); 

vga_ctrl    vga_ctrl_inst
(
	.h_real			(h_real	 ),//目标水平分辨率
	.v_real			(v_real	 ),//目标垂直分辨率
    .vga_clk     	(clk_74m   ),   //输入工作时钟
    .sys_rst_n   	(rst_n ),//&& sys_init_done     ),   //输入复位信号,低电平有效
	.pix_data_req	(rdreq     ),  
	.pix_data    	({vga_rgb[15:11],vga_rgb[13:11],vga_rgb[10:5],vga_rgb[6:5],vga_rgb[4:0],vga_rgb[2:0]}),   
	//输出
    .hsync       	(vga_hs    ),  //输出行同步信号
    .vsync       	(vga_vs    ),  //输出场同步信号
	.rgb_valid		(vga_de		),
	.lcd_framesync	(lcd_framesync),
    .red         	(vga_r),
    .green       	(vga_g),
    .blue        	(vga_b),
);

reg   [23:0]   hdmi_d_r;
reg            hdmi_de_r;
reg            hdmi_hs_r;
reg            hdmi_vs_r;

always @(posedge clk_74m or negedge rst_n) begin
	if(!rst_n) begin
		hdmi_d_r<=24'd0;
		hdmi_vs_r<=0;
		hdmi_hs_r<=0;
		hdmi_de_r<=0;
	end else begin
		case(uart_control[2:0])
			4'd0:begin	//正常数据
				hdmi_d_r<=24'd0;
				hdmi_vs_r<=vga_vs;
				hdmi_hs_r<=vga_hs;
				hdmi_de_r<=vga_de;		
			end
			4'd1:begin	//正常数据
				hdmi_d_r<={vga_r,vga_g,vga_b};
				hdmi_vs_r<=vga_vs;
				hdmi_hs_r<=vga_hs;
				hdmi_de_r<=vga_de;		
			end
			4'd2:begin	//彩色对比度
				hdmi_d_r<={contrast_r,contrast_g,contrast_b};
				hdmi_vs_r<=contrast_vs;
				hdmi_hs_r<=contrast_hs;
				hdmi_de_r<=contrast_de;		
			end
			4'd3:begin	//灰度
				hdmi_d_r<={yuv_y,yuv_y,yuv_y};
				hdmi_vs_r<=yuv_vs;
				hdmi_hs_r<=yuv_hs;
				hdmi_de_r<=yuv_de;		
			end
			4'd4:begin	//gamma
				hdmi_d_r<={gamma_y,gamma_y,gamma_y};
				hdmi_vs_r<=gamma_vs;
				hdmi_hs_r<=gamma_hs;
				hdmi_de_r<=gamma_de;		
			end
			4'd5:begin	//中值滤波
				hdmi_d_r<={mid_y,mid_y,mid_y};
				hdmi_vs_r<=mid_vs;
				hdmi_hs_r<=mid_hs;
				hdmi_de_r<=mid_de;		
			end
			4'd6:begin	//帧率与水印显示
				hdmi_d_r<={watermark_r,watermark_g,watermark_b};
				hdmi_vs_r<=watermark_vsync;
				hdmi_hs_r<=watermark_hs;
				hdmi_de_r<=watermark_de;		
			end
		default : begin
			hdmi_d_r<={vga_r,vga_g,vga_b};
			hdmi_vs_r<=vga_vs;
			hdmi_hs_r<=vga_hs;
			hdmi_de_r<=vga_de;			
		end
		endcase
	end
end

wire contrast_de,contrast_hs,contrast_vs;
wire [7:0] contrast_r,contrast_g,contrast_b;
isp_contrast	isp_contrast_inst
(
	  .clk				(clk_74m),
      .i_data_r			(vga_r),
      .i_data_g			(vga_g),
      .i_data_b			(vga_b),
      .switch1			(uart_control[7]),
      .choice			(uart_control[11:10]),
      .i_data_valid		(vga_de),
      .i_href			(vga_hs),
      .i_vsync			(vga_vs),
      .o_vsync			(contrast_vs),
      .o_data_r			(contrast_r),
      .o_data_g			(contrast_g),
      .o_data_b			(contrast_b),
      .o_data_valid		(contrast_de),
	  .o_href			(contrast_hs)
 );

wire yuv_de,yuv_hs,yuv_vs;
wire [7:0] yuv_y,yuv_u,yuv_v;
isp_rgb2yuv
#(
	.BITS	 (8) ,
	.WIDTH	 (1280) ,
	.HEIGHT	 (720) 
) yuv_inst
(
	.pclk		(clk_74m),
	.rst_n		(rst_n),
	.switch		(uart_control[6]),

	.in_href	(contrast_de),
	.in_vsync	(contrast_vs),
	.in_en		(contrast_hs),
	.in_r		(contrast_r),
	.in_g		(contrast_g),
	.in_b		(contrast_b),

	.out_href	(yuv_de),
	.out_vsync	(yuv_vs),
	.out_en		(yuv_hs),
	.out_y		(yuv_y),
	.out_u		(yuv_u),
	.out_v		(yuv_v)
);

wire gamma_de,gamma_hs,gamma_vs;
wire [7:0] gamma_y,gamma_u,gamma_v;
isp_gamma
#(
	.BITS(8),
	.WIDTH(1280),
	.HEIGHT(720)
)isp_gamma_inst
(
	.pclk			(clk_74m),
	.rst_n			(rst_n)	,
	.switch1		(uart_control[5]),
	.day_night		(uart_control[9:8]),
	.in_href		(yuv_de),
    .in_hsync		(yuv_hs),
	.in_vsync		(yuv_vs),
	.in_data_y		(yuv_y),
    .in_data_u		(yuv_u),
    .in_data_v		(yuv_v),
	.out_href		(gamma_de),
    .out_hsync		(gamma_hs),
	.out_vsync		(gamma_vs),
	.out_data_y		(gamma_y),
    .out_data_u		(gamma_u),
    .out_data_v		(gamma_v)
);
//mid_filter
wire	mid_vs,mid_hs,mid_de;
wire [7:0] mid_y,mid_u,mid_v;
isp_mid_filter
#(
    .BITS 	(8),
    .WIDTH 	(1280),
    .HEIGHT (720)
)isp_mid_filter_inst
(
	.pclk        (clk_74m),
	.rst_n       (rst_n),
	.switch      (uart_control[4]),
	.in_href     (gamma_de),
	.in_hsync    (gamma_hs),
	.in_vsync    (gamma_vs),
	.in_y        (gamma_y),
	.in_u        (gamma_u),
	.in_v        (gamma_v),
	.out_href    (mid_de),
	.out_hsync   (mid_hs),
	.out_vsync   (mid_vs),
	.out_y       (mid_y),
	.out_u       (mid_u),
	.out_v 		 (mid_v)
);

wire	watermark_hs,watermark_vsync,watermark_de;
wire    [7:0]   watermark_r,watermark_g,watermark_b;
watermark_logo	watermark_logo_inst
(
	.i_clk			(clk_74m),
	.i_rst_n		(rst_n),
	.switch 		(1'b1),
	.i_hsyn			(vga_hs),
	.i_vsyn			(vga_vs),
	.i_en_pos		(vga_de),
	.i_r			(vga_r),
	.i_g			(vga_g),
	.i_b			(vga_b),
	.h_real			(h_real),
	.v_real			(v_real),
	.water_select0	(cnn_result),	
	.o_hs			(watermark_hs),
	.o_vs			(watermark_vsync),
	.o_en			(watermark_de),	
	.o_r			(watermark_r),
	.o_g			(watermark_g),
	.o_b			(watermark_b)
);

//wire	fps_hs,fps_vsync,fps_de;
//wire    [7:0]   fps_r,fps_g,fps_b;
//fps_show	fps_show_inst
//(
//	.i_clk			(clk_74m),
//	.i_rst_n		(rst_n),
//	.switch 		(1'b1),
//	.i_hsyn			(watermark_hs),
//	.i_vsyn			(watermark_vsync),
//	.i_en_pos		(watermark_de),
//	.i_r			(watermark_r),
//	.i_g			(watermark_g),
//	.i_b			(watermark_b),
//	.h_real			(h_real),
//	.v_real			(v_real),
//	.water_select0	(cnn_fps_data),	
//	.o_hs			(fps_hs),
//	.o_vs			(fps_vsync),
//	.o_en			(fps_de),	
//	.o_r			(fps_r),
//	.o_g			(fps_g),
//	.o_b			(fps_b)
//);



endmodule
