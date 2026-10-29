/*-------------------------------------------------------------------------
Filename			:		sdram_ov7670_vga.v
Description			:		sdram vga controller with ov7670 display.
Modification History	:
Data			By			Version			Change Description
===========================================================================
13/02/1
--------------------------------------------------------------------------*/
module	sdbank_switch
(
	input				clk					,
	input				rst_n					,
	input				bank_valid			,
	input				frame_write_done	,
	input				frame_read_done	,
	
	input 	wire  [11:0]	img_width	,
	input		wire  [11:0]	img_height	,
	
	input		wire  [9:0]	   wr_fifo_num	,	//写fifo中的数据量
	input		wire  [9:0]	   rd_fifo_num	,	//写fifo中的数据量
	
	output	reg	[11:0]	h_real_rd	,
	output	reg 	[11:0]	v_real_rd	,
	output	reg	[11:0]	h_real_wr	,
	output	reg 	[11:0]	v_real_wr	,
	
	output  	reg 	[2:0]    state_write,
	
	output	reg	[1:0]	wr_bank,
	output	reg	[1:0]	rd_bank,
	output	reg			wr_load,
	output	reg			rd_load,
	
	output	reg 	[12:0]wr_burst_num		,//写总突发次数
	output	reg	[9:0]	wr_burst_last_len	,//写突发最后突发长度
	output	reg 	[12:0]rd_burst_num		,//读总突发次数
	output	reg	[9:0]	rd_burst_last_len	 //读突发最后突发长度
);


reg	[11:0]	h_real_wr_last;
reg 	[11:0]	v_real_wr_last;

reg 	[12:0]	wr_burst_num_reg			;//记录上一次写总突发次数
reg	[9:0]		wr_burst_last_len_reg	;//记录上一次写突发最后突发长度

wire 	[1:0] 	wr_bank_p1 = (wr_bank + 1)%3;
wire 	[1:0] 	wr_bank_next = ((wr_bank_p1 == rd_bank)? (wr_bank+2)%3:(wr_bank+1)%3);
reg   [1:0]		wr_bank_last; 


//----------------------------------
//negedge of bank_valid signal
reg	bank_valid_r0, bank_valid_r1;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		bank_valid_r0 <= 0;
		bank_valid_r1 <= 0;
		end
	else
		begin
		bank_valid_r0 <= bank_valid;
		bank_valid_r1 <= bank_valid_r0;
		end
end
wire	bank_switch_flag = (bank_valid_r1 & ~bank_valid_r0) ? 1'b1 : 1'b0;	//negedge

//----------------------------------------
//switch banks--ping pang write
//reg	[2:0]	state_write;
always@(negedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		wr_bank <= 2'b00;	//2'b11;
		wr_load <= 0;
		wr_bank_last <= 2'b0;
		state_write <=3'd0;
		
		h_real_wr <=  img_width;
		v_real_wr <=  img_height;
		h_real_wr_last <= img_width;
		v_real_wr_last <= img_height;

		wr_burst_num 		<= (img_height*img_width/512);
		wr_burst_last_len <= (img_height*img_width%512)+512;
		wr_burst_num_reg 	<= (img_height*img_width/512);
		wr_burst_last_len_reg <=	(img_height*img_width%512)+512;
		end
	else
		begin
		case(state_write)
		3'd0:	begin	wr_load <= 1'b0;	state_write <= 3'd1;	end
		3'd1:	begin	wr_load <= 1'b1; 	state_write <= 3'd2;	end
		3'd2:	begin	wr_load <= 1'b0; 	state_write <= 3'd3;	end
		3'd3:	begin	
				if(frame_write_done)		//to be sure data with the same image has been wrote
					begin
						if(bank_switch_flag)
							begin
								wr_bank <= wr_bank_next;//切换帧索引
								wr_bank_last <= wr_bank;
								
								h_real_wr <= img_width	;//修改缩放模块输出图像分辨率
								v_real_wr <= img_height	;
								
								h_real_wr_last <= h_real_wr;//保存写过图像分辨率大小
								v_real_wr_last <= v_real_wr;
								
								wr_burst_num <= (img_height*img_width/512);//更新和缩放模块输出匹配的地址容量
								wr_burst_last_len <= (img_height*img_width%512)+512;
								
								wr_burst_num_reg 		 <= wr_burst_num;//保存图像匹配的地址容量
								wr_burst_last_len_reg <= wr_burst_last_len;
								
								state_write <= 3'd4;
							end
						else
							begin
								state_write <= 3'd3;
								wr_bank <= wr_bank;
							end
					end
				else
					begin
					wr_bank <= wr_bank;
					state_write <= 3'd3;
					end
				end
		3'd4:	begin
				state_write <= 3'd0;
				end
		default:;
		endcase
		end
end

//----------------------------------------
//switch banks--ping pang read
reg	[2:0]	state_read;
always@(negedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		rd_bank <= 2'b11;	//2'b00;
		rd_load <= 1'b0;
		state_read <=3'd0;
		h_real_rd <= img_width;
		v_real_rd <= img_height;
		rd_burst_num <= (img_height*img_width/512);
		end
	else
		begin
		case(state_read)
		3'd0:	begin	rd_load <= 1'b0; 	state_read <= 3'd1;	end
		3'd1:	begin	rd_load <= 1'b1;	state_read <= 3'd2;	end
		3'd2:	begin	rd_load <= 1'b0;	state_read <= 3'd3;	end
		3'd3:	begin	
				if(frame_read_done)		//to be sure data with the same image has been read
					begin
					//rd_bank <= ~rd_bank;
					h_real_rd <= h_real_wr_last;//加载上次写完的帧的图像分辨率
					v_real_rd <= v_real_wr_last;
					
					rd_burst_num <= wr_burst_num_reg;//记载上次写完帧的地址大小
					rd_burst_last_len <= wr_burst_last_len_reg;
					
					rd_bank <= wr_bank_last;
					state_read <= 3'd0;
					end
				else
					begin
					rd_bank <= rd_bank;
					state_read <= 3'd3;
					end
				end
//		3'd4:	begin
//				state_read <= 3'd0;
//				end	
		default:;
		endcase
		end
end

endmodule
