`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire 
// Create Date   : 2019/11/15
// Module Name   : ov5640_hdmi_1280x720
// Project Name  : ov5640_hdmi_1280x720
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 顶层文件
// 
// Revision      : V1.0
// Additional Comments:
//
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
///////////////////////////////////////////////////////////////////////

module  ov5640_hdmi_1280x720
(
    input   wire            sys_clk     ,   //输入系统时钟,50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效	
//CMOS
    input   wire    [7:0]   ov5640_data   ,   //摄像头采集图像数据
    input   wire            ov5640_vsync  ,   //摄像头采集图像场同步信号
    input   wire            ov5640_href   ,   //摄像头采集图像行同步信号
    input   wire            ov5640_pclk   ,   //摄像头像素时钟
    output  wire            ov5640_rst_n  ,   //
    output  wire            ov5640_pwdn   ,   //
	output	wire			ov5640_xclk	  ,
    output  wire            sccb_scl    ,   //SCCB串行时钟
    inout   wire            sccb_sda    ,   //SCCB串行数据

//SDRAM
    output  wire            sdram_clk   ,   //SDRAM 芯片时钟
    output  wire            sdram_cke   ,   //SDRAM 时钟有效
    output  wire            sdram_cs_n  ,   //SDRAM 片选
    output  wire            sdram_ras_n ,   //SDRAM 行有效
    output  wire            sdram_cas_n ,   //SDRAM 列有效
    output  wire            sdram_we_n  ,   //SDRAM 写有效
//    output  wire    [1:0]   sdram_dqm   ,   //SDRAM 数据掩码
    output  wire    [1:0]   sdram_ba    ,   //SDRAM Bank地址
    output  wire    [12:0]  sdram_addr  ,   //SDRAM 行/列地址
    inout   wire    [15:0]  sdram_dq  ,     //SDRAM 数据

//scale_vga
	output	wire			vga_hs,
	output	wire			vga_vs,
	output	wire   [15:0]	vga_out,
////cnn_out
//	output	wire	[3:0]	cnn_result,

//Eth
	output	wire			GMII_GTXC,
	output 	wire	[7:0]	GMII_TXD,
	output 	wire			GMII_TXEN,
	output 	wire			ETH_Rst_n,
	
//HDMI
    output                   hdmi_clk,
    output[23:0]             hdmi_d,
    output                   hdmi_de,
    output                   hdmi_hs,
	output                   hdmi_vs,
	output					 hdmi_nreset,
    inout                    hdmi_scl,
    inout                    hdmi_sda,
//UART
	input	wire			 rx,
	output	wire			 tx,
	
//FSMC
	input	wire          	FSMC_CS,
	input   wire       		FSMC_RD,
	input   wire	       	FSMC_WR,
	input   wire       		FSMC_NL,
	input	wire  	[1:0]   FSMC_NBL,//字节使能，没用到
	inout  	wire	[15:0]  FSMC_ADDR_DATA,
	input  	wire	[7:0]   FSMC_ADDR_H,
	
//Key
	input  wire		[2:0]  	 key_data
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter     define
parameter   H_PIXEL = 1280;
parameter   V_PIXEL = 720 ;

//wire  define
wire            clk_100m        ;
//wire            clk_100m_shift  ;
wire            clk_125m        ;
wire            clk_125m_shift  ;
wire            clk_25m         ;
wire			cnn_clk			;
wire            locked1         ;

wire            clk_74m         ;

wire            locked2         ;
wire            rst_n           ;

wire            sdram_init_done ;
wire    [1:0]   sdram_dqm		;
  
wire            cfg_done        ;
wire            sys_init_done   ;

wire    [15:0]  image_data      ;
wire            image_data_en   ;
wire			ov5640_frame_vsync;
wire			ov5640_frame_href;

wire    [15:0]  vga_rgb         ;
wire            rdreq           ;

wire			hdmi_cfg_done/* synthesis preserve */;
wire			hdmi_cfg_error/* synthesis preserve */;

wire	[3:0]	cnn_result;

assign  ov5640_pwdn = 1'b0;
assign  ov5640_rst_n = 1'b1;
assign 	ETH_Rst_n = 1;
assign  rst_n = (sys_rst_n & locked1 & locked2);
assign  sys_init_done = sdram_init_done & cfg_done&hdmi_cfg_done;

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//------------- clk_gen_inst -------------
clk_gen clk_gen_inst
(
    .areset (~sys_rst_n     ),
    .inclk0 (sys_clk        ),
    .c0     (clk_100m       ),
//    .c1     (clk_100m_shift ),
    .c2     (clk_25m        ),
	.c3		(ov5640_xclk	),
    .locked (locked1        )
);
//------------- clk_hdmi_inst -------------
clk_hdmi    clk_hdmi_inst
(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk    ),
    .c0     (clk_74m    ),
	.c1     (clk_125m    ),
	.c2     (clk_125m_shift),
	.c3		(cnn_clk),
	.c4		(GMII_GTXC),
    .locked (locked2    )
);

//------------- ov5640_top_inst -------------
ov5640_top  ov5640_top_inst
(
    .sys_clk         (clk_25m       ),   //系统时钟
    .sys_rst_n       (rst_n         ),   //复位信号
    .sys_init_done   (sys_init_done ),   //系统初始化完成(SDRAM + 摄像头)

    .ov5640_pclk     (ov5640_pclk     ),   //摄像头像素时钟
    .ov5640_href     (ov5640_href     ),   //摄像头行同步信号
    .ov5640_vsync    (ov5640_vsync    ),   //摄像头场同步信号
    .ov5640_data     (ov5640_data     ),   //摄像头图像数据

    .cfg_done        (cfg_done      ),   //寄存器配置完成
    .sccb_scl        (sccb_scl      ),   //SCL
    .sccb_sda        (sccb_sda      ),   //SDA
    .ov5640_wr_en    (image_data_en ),   //图像数据有效使能信号
    .ov5640_data_out (image_data    ),    //图像数据

	.ov5640_frame_vsync(ov5640_frame_vsync),//高有效
	.ov5640_frame_href (ov5640_frame_href)
);

wire contrast_de,contrast_hs,contrast_vs;
wire [7:0] contrast_r,contrast_g,contrast_b;
isp_contrast	isp_contrast_inst
(
	  .clk				(ov5640_pclk),
      .i_data_r			({image_data[15:11],3'b0}),
      .i_data_g			({image_data[10:5],2'b0}),
      .i_data_b			({image_data[4:0],3'b0}),
      .switch1			(1'b1),
      .choice			(reg001_o[11:10]),
//      .choice			(2'd0),
      .i_data_valid		(image_data_en),
      .i_href			(ov5640_frame_href),
      .i_vsync			(ov5640_frame_vsync),
      .o_vsync			(contrast_vs),
      .o_data_r			(contrast_r),
      .o_data_g			(contrast_g),
      .o_data_b			(contrast_b),
      .o_data_valid		(contrast_de),
	  .o_href			(contrast_hs)
 );

wire yuv_de,yuv_hs,yuv_vs;
wire [7:0] yuv_y;
wire [7:0] yuv_u;
wire [7:0] yuv_v;
isp_rgb2yuv
#(
	.BITS	 (8) ,
	.WIDTH	 (1280) ,
	.HEIGHT	 (720) 
) yuv_inst
(
	.pclk		(ov5640_pclk),
	.rst_n		(rst_n),
	.switch		(1'b1),
	.in_href	(contrast_de),
	.in_vsync	(contrast_vs),
	.in_en		(contrast_hs),
	.in_r		(contrast_r),
	.in_g		(contrast_g),
	.in_b		(contrast_b),
//	.in_href	(image_data_en),
//	.in_vsync	(ov5640_frame_vsync),
//	.in_en		(ov5640_frame_href),
//	.in_r		({image_data[15:11],image_data[13:11]}),
//	.in_g		({image_data[10:5],image_data[6:5]}),
//	.in_b		({image_data[4:0],image_data[2:0]}),
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
	.pclk			(ov5640_pclk),
	.rst_n			(rst_n)	,
	.switch1		(1'b1),
	.day_night		(reg001_o[9:8]),
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

wire 			bound_cut_en;
wire	[7:0]	bound_cut_data;
bound_cut
#(
	.BITS(8)
)bound_cut_inst
(
	.clk		(ov5640_pclk),
	.rst_n		(rst_n),

	.valid		(gamma_de),
	.data		(gamma_y),
	.vs_n		(!gamma_vs),

	.vin_xres	(16'd1280),	
	.vin_yres	(16'd720),	
	.vout_xres	(16'd1200),	
	.vout_yres	(16'd660),	
	.valid_out	(bound_cut_en),
	.data_out	(bound_cut_data)		
);


wire 			o_scale_en;
wire	[7:0]	o_scale_data;
sc_test#
(
	.iPIXEL_DEPTH(8),	//像素颜色深度
	.iPIXEL_COLOR(1) 	//颜色数
)
sc_test_inst
(
	.rst_n			(rst_n),
	.vin_clk		(ov5640_pclk),

	.frame_sync_n	(!gamma_vs),	//输入视频帧同步复位，低有效
	.vin_dat		(bound_cut_data),			//输入视频数据
	.vin_valid		(bound_cut_en),			//输入视频数据有效
	.vin_ready		(),				//输入准备好
	.vout_dat		(o_scale_data),			//输出视频数据
	.vout_valid		(o_scale_en),			//输出视频数据有效
	.vout_ready		(1'b1),			//输出准备好
	.vin_xres		(16'd1200),			//输入视频水平分辨率
	.vin_yres		(16'd660),			//输入视频垂直分辨率
	.vout_xres		(16'd40),			//输出视频水平分辨率
	.vout_yres		(16'd40)			//输出视频垂直分辨率
);


ram_top	
#(
	.BITS(8),
    .WIDTH(40),
    .HEIGHT(40)
)ram_top_cnn_inst
(
	.rst_n		(rst_n),
	
    .wrclock	(ov5640_pclk),
    .wr_data	(o_scale_data),
	.wren		(o_scale_en),
	.write_valid(gamma_vs),//上升沿切换帧。
	
    .rdclock	(cnn_clk),
    .rd_data	(vga_rd_data1),
	.read_valid	(read_valid1),
	.rdreq		(vga_req1)
);

wire	read_valid1;
wire	vga_req1,vga_de1;
wire	[7:0]	vga_rd_data1;
vga_test    cnn_test_inst
(
	.h_real			(12'd40	 	),//目标水平分辨率
	.v_real			(12'd40	 	),//目标垂直分辨率
    .vga_clk     	(cnn_clk   	),   //输入工作时钟
    .sys_rst_n   	(rst_n 		),//&& sys_init_done     ),   //输入复位信号,低电平有效
	.pix_data_req	(vga_req1    ),  
	.pix_data    	({vga_rd_data1,vga_rd_data1,vga_rd_data1}),   
	//输出
//	.vga_xpos		(vga_xpos	),		
//	.vga_ypos		(vga_ypos	),
	
//    .hsync       	(vga_hs    	),  //输出行同步信号
//    .vsync       	(vga_vs    	),  //输出场同步信号
	.rgb_valid		(vga_de1		),	//输出使能信号（缩小图像）
	.lcd_framesync	(read_valid1	),
//	.rgb_out		(vga_out	),
	.y_out			(cnn_data_in)
);

wire cnn_valid_out;
reg cnn_valid_out_reg;
reg cnn_valid_out_reg1;
reg [3:0]cnn_re_reg;
wire signed [35:0] cnn_data_out;
wire	[7:0]	cnn_data_in;
wire	[3:0] cnn_re;
cnn_test#(
	.PAD 	(1)  ,
    .width 	(40) ,                //图片的宽度
    .height (40)                //图片的高度
) u_cnn
(
	.clk		(cnn_clk),
	.rst_n		(rst_n && !cnn_valid_out_reg1),
	.valid_in	(vga_de1),
	.data_in	({1'b0,cnn_data_in}),
	.valid_out	(cnn_valid_out),
	.result		(cnn_re),
	.data_out	(cnn_data_out)
);
assign cnn_result = cnn_re_reg;

/*-----------------------------------FSMC——————————————————————————————————*/
wire			bus_wr_en;
wire			bus_rd_en;
wire [23:0]	bus_addr;
wire [15:0]	bus_wr_data;
wire [15:0]	bus_rd_data;
wire [15:0] bus_rd_data_reg;
wire wr_reg;

wire [15:0] reg000_o,reg001_o,reg002_o,reg003_o,reg004_o,reg005_o;
//wire [15:0] reg1024_i,reg1028_i,reg1029_i,reg1030_i,reg1031_i;

fsmc_ctrl fsmc_ctrl_0	//fsmc_ctrl模块，主要用于将FSMC总线解析成本地总线
(
    .clock(clk_100m), 
    .reset(!rst_n), 
    .FSMC_CS(FSMC_CS), 
    .FSMC_CLK(), 
    .FSMC_RD(FSMC_RD), 
    .FSMC_WR(FSMC_WR), 
    .FSMC_NWAIT(), 
    .FSMC_NL(FSMC_NL), 
    .FSMC_INT(), 
    .FSMC_NBL(FSMC_NBL), 
    .FSMC_ADDR_DATA(FSMC_ADDR_DATA), 
    .FSMC_ADDR_H(FSMC_ADDR_H), 

    .bus_wr_en(bus_wr_en), 
    .bus_rd_en(bus_rd_en), 
    .bus_addr(bus_addr), 
    .bus_wr_data(bus_wr_data), 
    .bus_rd_data(bus_rd_data) //注意输出寻址范围
);

assign bus_rd_data = (bus_addr[23:16]==8'b0) ? bus_rd_data_reg : 16'd0; //注意输出寻址范围
assign wr_reg = bus_wr_en & (bus_addr[23:16]==8'b0); //注意寻址范围

reg_ctrl reg_ctrl_0	//主要用于STM32与FPGA的少量数据交互，比如通过STM32控制FPGA的外设寄存器等，可根据需要更改寄存器数量
(
    .clock(clk_100m), 
    .reset(!rst_n), 
    .wr(wr_reg), //注意寻址范围
    .rd(bus_rd_en), //注意寻址范围
    .addr(bus_addr), 
    .wr_data(bus_wr_data), 
    .rd_data(bus_rd_data_reg), //注意输出寻址范围
    .reg000_o(reg000_o), 
    .reg001_o(reg001_o), 
    .reg002_o(reg002_o), 
    .reg003_o(reg003_o), 
    .reg004_o(reg004_o), 
    .reg005_o(reg005_o), 
	.reg1024_i(data), //测试fpga写单片机读用数据，可更改
//    .reg1028_i(reg1028_i), 
//    .reg1029_i(reg1029_i), 
//    .reg1030_i(reg1030_i), 
    .reg1031_i(valid)
);
reg [15:0] reg000_o_r,data,valid;
always@(posedge clk_100m) begin
	reg000_o_r <= reg000_o;
end
always@(posedge clk_100m) begin
	if (reg000_o[0] & !reg000_o_r[0]) begin
		data <= cnn_re_reg;
		valid <= 1;
	end else if (!reg000_o[0] & !reg000_o_r[0]) begin
		valid <= 0;
	end
end


//------------- sdram_top_inst -------------
sdram_top   sdram_top_inst
(
    .sys_clk            (clk_125m       ),  //sdram 控制器参考时钟
    .clk_out            (clk_125m_shift ),  //用于输出的相位偏移时钟
    .sys_rst_n          (rst_n          ),  //系统复位
//用户写端口
    .wr_fifo_wr_clk     (ov5640_pclk      ),  //写端口FIFO: 写时钟
    .wr_fifo_wr_req     (image_data_en  ),  //写端口FIFO: 写使能
    .wr_fifo_wr_data    (image_data     ),  //写端口FIFO: 写数据
    .sdram_wr_b_addr    (24'd0          ),  //写SDRAM的起始地址
    .sdram_wr_e_addr    (H_PIXEL*V_PIXEL),  //写SDRAM的结束地址
    .wr_burst_len       (10'd256        ),  //写SDRAM时的数据突发长度
    .wr_rst             (~rst_n         ),  //写端口复位: 复位写地址,清空写FIFO
//用户读端口
    .rd_fifo_rd_clk     (clk_74m        ),  //读端口FIFO: 读时钟
    .rd_fifo_rd_req     (rdreq          ),  //读端口FIFO: 读使能
    .rd_fifo_rd_data    (vga_rgb        ),  //读端口FIFO: 读数据
    .sdram_rd_b_addr    (24'd0          ),  //读SDRAM的起始地址
    .sdram_rd_e_addr    (H_PIXEL*V_PIXEL),  //读SDRAM的结束地址
    .rd_burst_len       (10'd256        ),  //从SDRAM中读数据时的突发长度
    .rd_fifo_num        (               ),  //读fifo中的数据量
    .rd_rst             (~rst_n         ),  //读端口复位: 复位读地址,清空读FIFO
//用户控制端口
    .read_valid         (1'b1           ),  //SDRAM 读使能
    .pingpang_en        (1'b1           ),  //SDRAM 乒乓操作使能
    .init_end           (sdram_init_done),  //SDRAM 初始化完成标志
//SDRAM 芯片接口
    .sdram_clk          (sdram_clk      ),  //SDRAM 芯片时钟
    .sdram_cke          (sdram_cke      ),  //SDRAM 时钟有效
    .sdram_cs_n         (sdram_cs_n     ),  //SDRAM 片选
    .sdram_ras_n        (sdram_ras_n    ),  //SDRAM 行有效
    .sdram_cas_n        (sdram_cas_n    ),  //SDRAM 列有效
    .sdram_we_n         (sdram_we_n     ),  //SDRAM 写有效
    .sdram_ba           (sdram_ba       ),  //SDRAM Bank地址
    .sdram_addr         (sdram_addr     ),  //SDRAM 行/列地址
    .sdram_dq           (sdram_dq       ),  //SDRAM 数据
    .sdram_dqm          (sdram_dqm      )   //SDRAM 数据掩码
);


hdmi_top hdmi_inst
(
	.clk_74m		(clk_74m),
	.clk_100m		(clk_100m),
	.rst_n			(rst_n),
	
	.hdmi_cfg_error	(hdmi_cfg_error),
	.hdmi_cfg_done	(hdmi_cfg_done),
    .hdmi_scl		(hdmi_scl),
    .hdmi_sda 		(hdmi_sda),
	
	.h_real		 	(H_PIXEL),//输出目标水平分辨率
	.v_real		 	(V_PIXEL),//输出目标垂直分辨率	 
	
	.cnn_result		(reg005_o[3:0]),	
//	.cnn_result		(cnn_re_reg),	
//	.cnn_fps_data	(cnn_fps_data),
//	.uart_control	(uart_control[11:0]),
	
	.uart_control	(reg001_o[11:0]),
	.vga_rgb		(vga_rgb),
	.rdreq			(rdreq),
	.lcd_framesync	(lcd_framesync),
	
	.hdmi_clk		(hdmi_clk),
    .hdmi_d			(hdmi_d),
    .hdmi_de		(hdmi_de),
    .hdmi_hs		(hdmi_hs),
	.hdmi_vs		(hdmi_vs),
	.hdmi_nreset	(hdmi_nreset)
);

//千兆以太网传输模块，UDP + IP + MAC协议
eth_top	eth_top_inst(
	.GMII_GTXC(GMII_GTXC),
	.GMII_TXD(GMII_TXD),
	.GMII_TXEN(GMII_TXEN),
	.rst_n(rst_n),

	.cnn_en(reg002_o[0]),
	.cnn_result(reg004_o[3:0]),
	.cnn_count(reg003_o[7:0]),
	
	.ov5640_pclk(ov5640_pclk),		
	.ov5640_frame_vsync(ov5640_frame_vsync),
	.ov5640_frame_href(ov5640_frame_href),
	.image_data(image_data)
);


wire	[15:0]	uart_control;
uart_top#(
    .UART_BPS(20'd115200),         //串口波特率
    .CLK_FREQ(28'd50_000_000)    //时钟频率
) u_uart (
    .sys_clk     (sys_clk),   //系统时钟50MHz
    .sys_rst_n   (rst_n),   //全局复位
    .pi_data     ({cnn_re,cnn_data_out[35:8]}),   //模块输入的8bit数据
    .pi_flag     (cnn_valid_out),//tx_de),   //并行数据有效标志信号
    .po_data     (uart_control),   //串转并后的8bit数据
    .po_flag     (),   //串转并后的数据有效标志信号
    .rx          (rx),   //串口接收数据
    .tx          (tx)    //串转并后的1bit数据
);

reg cnn_de_1,cnn_de_2,cnn_de_3;
wire	cnn_valid_flag = (cnn_valid_out)&&(~cnn_valid_out_reg);
always @(posedge cnn_clk) begin
	cnn_valid_out_reg <= cnn_valid_out;
	cnn_valid_out_reg1 <= cnn_valid_out_reg;
	if (cnn_valid_out)
		cnn_re_reg <= cnn_re;
	else 
		cnn_re_reg <= cnn_re_reg;
end

/************************************************************
	Caculate Frame Rate per second
*************************************************************/
//-----------------------------------------------------
//	1s 延时函数
/*
reg	[25:0]	delay_cnt;	
always@(posedge cnn_clk or negedge rst_n)begin
	if(!rst_n)
		delay_cnt <= 0;
	else begin
		begin
		if(delay_cnt < 26'd15_000000)
			delay_cnt <= delay_cnt + 1'b1;
		else
			delay_cnt <= 0;
		end
	end
end
wire	delay_1s = (delay_cnt == 26'd15_000000) ? 1'b1 : 1'b0;
//-------------------------------------------
//帧率采样计算
reg			fps_state;
reg	[6:0]	fps_data;
reg	[6:0]	cnn_fps_data;
always@(posedge cnn_clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		fps_data <= 0;
		fps_state <= 0;
		cnn_fps_data <= 0;
		end
	else begin
		case(fps_state)
		1'b0:begin
			cnn_fps_data <= cnn_fps_data;
			if(delay_1s == 0)
				begin
				fps_state <= 0;
				if(cnn_valid_flag == 1'b1)		
					fps_data <= fps_data + 1'b1;
				end
			else
				fps_state <= 1;
			end
		1'b1:begin
			fps_state <= 0;
			fps_data <= 0;
			cnn_fps_data <= fps_data;
			end
		endcase
	end
end
*/
endmodule
