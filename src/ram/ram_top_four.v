/*-------------------------------------------------------------------------
Filename			:		sdram_ov7670_vga.v
Description			:		sdram vga controller with ov7670 display.
Modification History	:
Data			By			Version			Change Description
===========================================================================
13/02/1
--------------------------------------------------------------------------*/
module	ram_top
(
	input	wire 			rst_n,
	
    input	wire			wrclock,
    input	wire	[15:0]	wr_data,
	input	wire			wren,
	input	wire			write_valid,//对写vs进行检测，识别图像是否有效。

	input	wire	[7:0]	h_pos,
	input	wire	[7:0]	v_pos,
    input	wire			rdclock,
	input	wire			rdreq,
	input	wire			read_valid,//对vga的vs进行检测，当vs为0，说明可以读数据，地址正常增加
    output	wire	[15:0]	rd_data

);


//sdram_wr_addr:sdram写地址
reg	[11:0]	wraddress;//写地址
reg			frame_write_done;
always@(posedge wrclock or negedge rst_n)
begin
    if(rst_n == 1'b0)
		begin
			wraddress   	<=	12'd0;	
			frame_write_done<= 	1'b0; 
		end
    else    if(wr_load_flag)
		begin
			wraddress   	<=	{wr_bank,10'd0};	
			frame_write_done<= 	1'b0; 
		end
    else    if(wren) 
        begin
            if(wraddress[9:0] < 10'd783)
				begin//写地址未达到末地址,写地址累加
					wraddress <= wraddress + 1'b1;
					frame_write_done <= 1'b0;
				end
			else
				begin
					wraddress <= wraddress;//防止溢出，锁存地址
					frame_write_done <= 1'b1;
				end
        end
    else    
		begin
			wraddress <= wraddress;			
			frame_write_done <= frame_write_done;
      end
end

//sdram_rd_addr:sdram读地址
reg Disp_Valid;//显示区间有效标志信号
always@(posedge rdclock or negedge rst_n)
if(!rst_n)
	Disp_Valid <= 1'b0;
else if(rdreq && (h_pos <= 28) && (v_pos < 28))
	Disp_Valid <= 1'b1;
else
	Disp_Valid <= 1'b0;	
//------------------------------------------------
//同步 读写ram有效信号
reg	read_valid_r;
always@(posedge rdclock or negedge rst_n)
begin//有数据时候，lcd_vs为0。
	if(!rst_n) 
		read_valid_r <= 1'b1;
	else 
		read_valid_r <= read_valid;
end
	
reg [11:0]	rdaddress;	//读地址
reg			frame_read_done;
always@(posedge rdclock or negedge rst_n)
begin
    if(rst_n == 1'b0)
		begin
			rdaddress   <=  12'd0;
			frame_read_done <= 1'b0;
		end
    else    if(rd_load_flag)
		begin
			rdaddress   <=  {rd_bank,10'd0};
		  	frame_read_done <= 1'b0;
		end
//		else if(read_valid_r)//没有数据时候vs为1，进入该判断，复位读地址
//		begin
//			rdaddress   <=  {rd_bank,10'd0};
//		  	frame_read_done <= 1'b0;
//		end
    else    if(Disp_Valid) //读请求，则增加读地址
        begin
			if(rdaddress[9:0] < 10'd783)
         		begin
					rdaddress <= h_pos + v_pos*28;
         			frame_read_done <= 1'b0;
         		end
         	else  
         		begin
         			rdaddress <= rdaddress;
         			frame_read_done <= 1'b1;
         		end       
        end
	else 
		begin
			rdaddress <= rdaddress;		
			frame_read_done <= frame_read_done;
		end
end
	
ram_2port ram_2port_inst
(
    .wrclock	(wrclock),
    .data		(wr_data),
	.wren		(wren),
//	.wr_aclr	(!rst_n),
    .wraddress	(wraddress),
	    
    .rdclock	(rdclock),
    .q			(rd_data),
    .rden		(Disp_Valid),
//	.rd_aclr	(!rst_n),
	.rdaddress	(rdaddress)
);

//----------------------------------------
//同步sdram读写地址初始值复位信号
reg	wr_load_r1, wr_load_r2;	
reg	rd_load_r1, rd_load_r2;	
always@(posedge wrclock or negedge rst_n)
begin
	if(!rst_n)
		begin
		wr_load_r1 <= 1'b0;
		wr_load_r2 <= 1'b0;
		end
	else
		begin
		wr_load_r1 <= wr_load;
		wr_load_r2 <= wr_load_r1;
		end
end
always@(posedge rdclock or negedge rst_n)
begin
	if(!rst_n)
		begin
		rd_load_r1 <= 1'b0;
		rd_load_r2 <= 1'b0;
		end
	else
		begin
		rd_load_r1 <= rd_load;
		rd_load_r2 <= rd_load_r1;
		end
end
wire	wr_load_flag = ~wr_load_r2 & wr_load_r1;	//地址重新加载上升沿标志位
wire	rd_load_flag = ~rd_load_r2 & rd_load_r1;	//地址重新加载上升沿标志位

//----------------------------------
//negedge of bank_valid signal
reg	wrtie_valid_r0, write_valid_r1;
always@(posedge wrclock or negedge rst_n)
begin
	if(!rst_n)
		begin
		wrtie_valid_r0 <= 0;
		write_valid_r1 <= 0;
		end
	else
		begin
		wrtie_valid_r0 <= write_valid;
		write_valid_r1 <= wrtie_valid_r0;
		end
end
wire	bank_switch_flag = (write_valid_r1 & ~wrtie_valid_r0) ? 1'b1 : 1'b0;	//negedge


reg		[1:0]	wr_bank;
reg		[1:0]	rd_bank;
wire 	[1:0] 	wr_bank_p1 = (wr_bank + 1)%3;
wire 	[1:0] 	wr_bank_next = ((wr_bank_p1 == rd_bank)? (wr_bank+2)%3:(wr_bank+1)%3);
reg   	[1:0]	wr_bank_last; 
//switch banks--ping pang write
reg	[2:0]	state_write;
reg			wr_load;
always@(negedge wrclock or negedge rst_n)
begin
	if(!rst_n)
		begin
		wr_bank <= 2'b00;	//2'b11;
		wr_load <= 0;
		wr_bank_last <= 2'b0;
		state_write <=3'd0;
		end
	else
		begin
		case(state_write)
		3'd0:	begin	wr_load <= 1'b0;	state_write <= 3'd1;	end
		3'd1:	begin	wr_load <= 1'b1; 	state_write <= 3'd2;	end
		3'd2:	begin	wr_load <= 1'b0; 	state_write <= 3'd3;	end
		3'd3:	begin
//					state_write <= 3'd4;
					if(bank_switch_flag)
						state_write <= 3'd4;
					else
						state_write <= 3'd3;
				end					
		3'd4:	begin	
				if(frame_write_done)		//to be sure data with the same image has been wrote
					begin			
						wr_bank <= wr_bank_next;
						wr_bank_last <= wr_bank;
						state_write <= 3'd0;
					end
				else
					begin
					wr_bank <= wr_bank;
					state_write <= 3'd4;
					end
				end
		default:;
		endcase
		end
end
//----------------------------------------
//switch banks--ping pang read
reg	[2:0]	state_read;
reg			rd_load;
always@(negedge rdclock or negedge rst_n)
begin
	if(!rst_n)
		begin
		rd_bank <= 2'b11;	//2'b00;
		rd_load <= 1'b0;
		state_read <=3'd0;
		end
	else
		begin
		case(state_read)
		3'd0:	begin	rd_load <= 1'b0; 	state_read <= 3'd1;	end
		3'd1:	begin	rd_load <= 1'b1;	state_read <= 3'd2;	end
		3'd2:	begin	rd_load <= 1'b0;	state_read <= 3'd3;	end
		3'd3:	begin
				state_read <= 3'd4;
				end
		3'd4:	begin	
				if(frame_read_done)		//to be sure data with the same image has been read
					begin
					rd_bank <= wr_bank_last;
					state_read <= 3'd0;
					end
				else
					begin
					rd_bank <= rd_bank;
					state_read <= 3'd4;
					end
				end
		default:;
		endcase
		end
end


endmodule
