`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07-02-2025 22:00:37
// Design Name:
// Module Name: vga_test
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


module vga_test(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [23:0]  pix_data    ,   //输入像素点色彩信息

	input	wire 	[11:0]	h_real		,//输出目标水平分辨率
	input	wire 	[11:0]	v_real		,//输出目标垂直分辨率	 
    output  reg             pix_data_req,
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
	
	output	wire	[7:0]	vga_xpos	,		//horizontal coordinate
	output	wire	[7:0]	vga_ypos	,		//vertical coordinate
	
	output	wire 			lcd_framesync,
    output  reg             rgb_valid   ,
    output  wire    [7:0]   red         ,
    output  wire    [7:0]   green       ,
    output  wire    [7:0]   blue		,		 
    output  wire    [15:0]  rgb_out     ,       //输出像素点色彩信息
	output	wire	[7:0]	y_out				//输出缩小后得到的y信息

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
//640*480
//parameter H_SYNC    =   10'd96  ,   //行同步
//          H_BACK    =   10'd40  ,   //行时序后沿
//          H_LEFT    =   10'd8   ,   //行时序左边框
//          H_VALID   =   10'd640 ,   //行有效数据
//          H_RIGHT   =   10'd8   ,   //行时序右边框
//          H_FRONT   =   10'd8   ,   //行时序前沿
//          H_TOTAL   =   10'd800 ;   //行扫描周期
//parameter V_SYNC    =   10'd2   ,   //场同步
//          V_BACK    =   10'd25  ,   //场时序后沿
//          V_TOP     =   10'd8   ,   //场时序上边框
//          V_VALID   =   10'd480 ,   //场有效数据
//          V_BOTTOM  =   10'd8   ,   //场时序下边框
//          V_FRONT   =   10'd2   ,   //场时序前沿
//          V_TOTAL   =   10'd525 ;   //场扫描周期
//1280*720@60Hz
parameter H_SYNC    =   12'd40  ,   //行同步
          H_BACK    =   12'd0 ,   //行时序后沿
          H_LEFT    =   12'd0   ,   //行时序左边框
          H_VALID   =   12'd40,   //行有效数据
          H_RIGHT   =   12'd0   ,   //行时序右边框
          H_FRONT   =   12'd40 ,   //行时序前沿
          H_TOTAL   =   12'd120;   //行扫描周期
parameter V_SYNC    =   12'd40   ,   //场同步
          V_BACK    =   12'd0  ,   //场时序后沿
          V_TOP     =   12'd0   ,   //场时序上边框
          V_VALID   =   12'd40 ,   //场有效数据
          V_BOTTOM  =   12'd0   ,   //场时序下边框
          V_FRONT   =   12'd40   ,   //场时序前沿
          V_TOTAL   =   12'd120 ;   //场扫描周期
//1280*720@30Hz
//parameter H_SYNC    =   12'd40  ,   //行同步
//          H_BACK    =   12'd220 ,   //行时序后沿
//          H_LEFT    =   12'd0   ,   //行时序左边框
//          H_VALID   =   12'd1280,   //行有效数据
//          H_RIGHT   =   12'd0   ,   //行时序右边框
//          H_FRONT   =   12'd1760,   //行时序前沿
//          H_TOTAL   =   12'd3300;   //行扫描周期
//parameter V_SYNC    =   12'd5   ,   //场同步
//          V_BACK    =   12'd20  ,   //场时序后沿
//          V_TOP     =   12'd0   ,   //场时序上边框
//          V_VALID   =   12'd720 ,   //场有效数据
//          V_BOTTOM  =   12'd0   ,   //场时序下边框
//          V_FRONT   =   12'd5   ,   //场时序前沿
//          V_TOTAL   =   12'd750 ;   //场扫描周期
//1920*1080
//parameter H_SYNC    =   12'd44  ,   //行同步
//          H_BACK    =   12'd148 ,   //行时序后沿
//          H_LEFT    =   12'd0   ,   //行时序左边框
//          H_VALID   =   12'd1920,   //行有效数据
//          H_RIGHT   =   12'd0   ,   //行时序右边框
//          H_FRONT   =   12'd88 ,   //行时序前沿
//          H_TOTAL   =   12'd2200;   //行扫描周期
//parameter V_SYNC    =   12'd5   ,   //场同步
//          V_BACK    =   12'd36  ,   //场时序后沿
//          V_TOP     =   12'd0   ,   //场时序上边框
//          V_VALID   =   12'd1080 ,   //场有效数据
//          V_BOTTOM  =   12'd0   ,   //场时序下边框
//          V_FRONT   =   12'd4   ,   //场时序前沿
//          V_TOTAL   =   12'd1125 ;   //场扫描周期


//reg   define
reg     [11:0]   cnt_h           ;   //行同步信号计数器
reg     [11:0]   cnt_v           ;   //场同步信号计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_h:行同步信号计数器
always@(posedge vga_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h   <=  12'd0   ;
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_h   <=  12'd0   ;
    else
        cnt_h   <=  cnt_h + 1'd1   ;

//hsync:行同步信号
assign  hsync = (cnt_h  <=  H_SYNC - 1'd1) ? 1'b1 : 1'b0 ;

//cnt_v:场同步信号计数器
always@(posedge vga_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
		begin
        cnt_v   <=  12'd0 ;
		end
    else    if((cnt_v == V_TOTAL - 1'd1) &&  (cnt_h == H_TOTAL-1'd1))
		begin
        cnt_v   <=  12'd0 ;
		end
    else    if(cnt_h == H_TOTAL - 1'd1)
        cnt_v   <=  cnt_v + 1'd1 ;
    else
        cnt_v   <=  cnt_v ;

//vsync:场同步信号
assign  vsync = (cnt_v  <=  V_SYNC - 1'd1) ? 1'b1 : 1'b0  ;
assign  lcd_framesync = vsync;
//rgb_valid:VGA有效显示区域
//rgb输出色彩
reg     [23:0]  r_lcd_rgb = 0; 
always@(posedge vga_clk) begin
//  rgb_valid <= 	(((cnt_h >= H_SYNC + H_BACK + H_LEFT)
//                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID))
//                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP)
//                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID)))
//                    ? 1'b1 : 1'b0;
	rgb_valid <= ((cnt_h >= H_SYNC + H_BACK + (H_VALID-h_real)/2   
				&& cnt_h < H_SYNC + H_BACK + H_VALID -(H_VALID-h_real)/2  )
				&&(cnt_v >= V_SYNC + V_BACK + (V_VALID-v_real)/2 
				&& cnt_v < V_SYNC + V_BACK + V_VALID - (V_VALID-v_real)/2))
                    ? 1'b1 : 1'b0;

	r_lcd_rgb <= ((cnt_h >= H_SYNC + H_BACK + (H_VALID-h_real)/2  
				&& cnt_h < H_SYNC + H_BACK + H_VALID -(H_VALID-h_real)/2  )
				&&(cnt_v >= V_SYNC + V_BACK + (V_VALID-v_real)/2 
				&& cnt_v < V_SYNC + V_BACK + V_VALID - (V_VALID-v_real)/2))
				?pix_data:24'b0;

end
assign  {red,green,blue} =  (rgb_valid == 1'b1) ? r_lcd_rgb : 24'b0;
assign 	rgb_out			 =	(rgb_valid == 1'b1) ? {r_lcd_rgb[23:19],r_lcd_rgb[15:10],r_lcd_rgb[7:3]} : 16'b0;
assign	y_out			 =	(rgb_valid == 1'b1) ? {r_lcd_rgb[7:0]} : 8'b0;

//pix_data_req:像素点色彩信息请求信号,超前rgb_valid信号一个时钟周期
 always@(posedge vga_clk) begin
  pix_data_req <= ( ((cnt_h >= H_SYNC + H_BACK + H_LEFT  + (H_VALID-h_real)/2 - 1'b1)
                    && (cnt_h < H_SYNC + H_BACK + H_LEFT + H_VALID  - (H_VALID-h_real)/2 -1'b1))
                    &&((cnt_v >= V_SYNC + V_BACK + V_TOP + (V_VALID-v_real)/2)
                    && (cnt_v < V_SYNC + V_BACK + V_TOP + V_VALID - (V_VALID-v_real)/2)) )
                    ? 1'b1 : 1'b0;
end

assign	vga_xpos	= 	pix_data_req ? (cnt_h - (H_SYNC + H_BACK + H_LEFT  + (H_VALID-h_real)/2 -1'b1) ) : 7'd0;
assign	vga_ypos	= 	pix_data_req ? (cnt_v - (V_SYNC + V_BACK + V_TOP   + (V_VALID-v_real)/2 -1'b1) ) : 7'd0;		

endmodule
