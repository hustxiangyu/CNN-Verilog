`timescale 1ns / 1ps
module watermark_logo
(
	input   wire				i_clk,
	input   wire				i_rst_n,
	input	wire				switch ,
	input	wire				i_hsyn,
	input	wire				i_vsyn,
	input	wire				i_en_pos,
	input	wire [7:0]			i_r,
	input	wire [7:0] 			i_g,
	input	wire [7:0] 			i_b,		
	input   wire [3:0]			water_select0,	
	input	wire [11:0]			h_real,
	input	wire [11:0]			v_real,
	output	reg					o_hs,
	output	reg					o_vs,
	output	reg					o_en,	
	output reg [7:0]			o_r,
	output reg [7:0]			o_g,
	output reg [7:0]			o_b	
);

parameter  H_ACTIVE 		= 64; //水印区域宽度                              
parameter  V_ACTIVE 		= 64;  //水印区域高度
parameter  IMAGE_SIZE    = H_ACTIVE * V_ACTIVE; // 每个数字图片的大小

reg [3:0]	water_select;//水印选择
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n)begin
		water_select <= 0;
	end
	else
		water_select <= water_select0 - 1'b1;
end

reg [10:0] BEGIN_X,BEGIN_Y;//不同水印的开始坐标设置
always @(posedge i_clk or negedge i_rst_n) 
begin
    if (!i_rst_n) begin
        BEGIN_X <= 11'd0;
        BEGIN_Y <= 11'd0;
	end
	else
		begin
			BEGIN_X <= 11'd0;
			BEGIN_Y <= 11'd0;
		end 
end


reg  [10:0] 	    h_cnt;
reg  [10:0] 	    v_cnt;
reg  [10:0] 	    x_pos;
reg  [10:0] 	    y_pos;
reg  [18:0] 		rd_addr;
reg					o_de;
reg					o_de1;
reg 				hsyn_d0;
reg					vsyn_d0;
reg					en_pos_d0;
reg 				hsyn_d1;
reg					vsyn_d1;
reg					en_pos_d1;


reg  [7:0]  		r_d;
reg  [7:0]  		g_d;
reg  [7:0]  		b_d;

reg  [7:0]  		r_d1;
reg  [7:0]  		g_d1;
reg  [7:0]  		b_d1;

wire [7:0]  		r_d0;
wire [7:0]  		g_d0;
wire [7:0]  		b_d0;
wire   				de_d0;//显示区域使能信号

always@(posedge i_clk)begin//时序输出
	if(switch)begin
		o_hs  <= hsyn_d1;
		o_vs  <= vsyn_d1;
		o_en  <= en_pos_d1;
	end else begin
		o_hs  <= i_hsyn;
		o_vs  <= i_vsyn;
		o_en  <= i_en_pos;
	end
end
//水印输出使能
assign de_d0 = i_en_pos && (x_pos >= BEGIN_X)&&(x_pos < BEGIN_X + H_ACTIVE)&&
                           (y_pos >= BEGIN_Y)&&(y_pos < BEGIN_Y + V_ACTIVE) ? 1'b1:1'b0;
//同步输出使能信号
always@(posedge i_clk ) 
begin	
	hsyn_d0		<= i_hsyn;
	vsyn_d0		<= i_vsyn;
	en_pos_d0	<= i_en_pos;
	hsyn_d1		<= hsyn_d0;	
	vsyn_d1		<= vsyn_d0;	
	en_pos_d1	<= en_pos_d0;	
	r_d			<= i_r;
	g_d			<= i_g;
	b_d			<= i_b;
	r_d1		<= r_d;
	g_d1		<= g_d;
	b_d1		<= b_d;	
end

//x计数（显示图像）
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
        x_pos <= 11'd0;
    end
    else if(i_en_pos)
	begin
		if(x_pos == h_real - 1'b1)
			x_pos <= 11'd0;
		else 
			x_pos <= x_pos + 11'd1;
    end
end

//y计数（显示图像）
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
        y_pos <= 11'd0;
    end
    else if(!i_en_pos && en_pos_d0)	
	begin
		if(y_pos == v_real - 1'b1)
			y_pos <= 11'd0;
		else 
			y_pos <= y_pos + 11'd1;
    end
end
//水印显示区域行计数
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
        h_cnt <= 11'd0;
    end
    else if(de_d0)
	begin
		if(h_cnt == H_ACTIVE - 1'b1)
			h_cnt <= 11'd0;
		else 
			h_cnt <= h_cnt + 11'd1;
    end
end

//水印显示区域场计数
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
        v_cnt <= 11'd0;
    end
    else if(h_cnt == H_ACTIVE - 1'b1)
	begin
		if(v_cnt == V_ACTIVE - 1'b1)
			v_cnt <= 11'd0;
		else 
			v_cnt <= v_cnt + 11'd1;
    end
end

//读取地址更新
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n)
	begin
        rd_addr <= 'd0;
    end
    else if(de_d0)
	begin
		rd_addr <= v_cnt * H_ACTIVE + h_cnt + water_select*IMAGE_SIZE;
    end
end

//同步输出使能信号
always@(posedge i_clk ) 
begin
	o_de 	<= de_d0;
	o_de1 	<= o_de;	
end


// assign o_r   = o_de ? r_d0 : 8'hff;
// assign o_g   = o_de ? g_d0 : 8'hff;
// assign o_b   = o_de ? b_d0 : 8'hff;
//r_d1为视频数据，r_d0为水印数据（数据输出）
always@(*)begin
	if(switch)
	begin 
		if(water_select>=4'd0&&water_select<=4'd9)
		begin
			if(de_d0)
			begin
				if({r_digit,g_digit,b_digit}==24'hFFFF00)
				begin
					o_r<=r_d1;
					o_g<=g_d1;
					o_b<=b_d1;							
				end 
				else begin
					o_r<=r_digit;
    		        o_g<=g_digit;
    		        o_b<=b_digit;
				end	
			end 
			else begin
				o_r<=r_d1;	
    		    o_g<=g_d1;
    		    o_b<=b_d1;
			end	
		end
		else begin
			o_r<=i_r;	
    	    o_g<=i_g;
    	    o_b<=i_b;		
		end
	end
end
//水印存储区
wire [7:0] r_digit,g_digit,b_digit;
digit_rom digit_rom_inst
(
    .clock(i_clk),
    .clken(o_de),
    .address(rd_addr),
    .q({r_digit,g_digit,b_digit})	
);



endmodule