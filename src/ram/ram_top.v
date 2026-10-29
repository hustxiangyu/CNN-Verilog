/*-------------------------------------------------------------------------
Filename			:		sdram_ov7670_vga.v
Description			:		sdram vga controller with ov7670 display.
Modification History	:
Data			By			Version			Change Description
===========================================================================
13/02/1
--------------------------------------------------------------------------*/
module	ram_top
#(
	parameter BITS = 8,
	parameter WIDTH = 28,
	parameter HEIGHT = 28
)
(
	input	wire 			rst_n,
	
    input	wire			wrclock,
    input	wire	[BITS-1:0]	wr_data,
	input	wire			wren,
	input	wire			write_valid,

	input	wire	[7:0]	h_pos,
	input	wire	[7:0]	v_pos,
    input	wire			rdclock,
	input	wire			rdreq,
	input	wire			read_valid,
    output	wire	[BITS-1:0]	rd_data

);

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
		wr_load_r1 <= write_valid;
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
		rd_load_r1 <= read_valid;
		rd_load_r2 <= rd_load_r1;
		end
end
wire	wr_load_flag = ~wr_load_r2 & wr_load_r1;	//地址加载上升沿标志位
wire	rd_load_flag = ~rd_load_r2 & rd_load_r1;	//地址加载上升沿标志位

reg		[1:0]	wr_bank;
reg		[1:0]	rd_bank;
wire 	[1:0] 	wr_bank_p1 = (wr_bank + 1)%3;
wire 	[1:0] 	wr_bank_next = ((wr_bank_p1 == rd_bank)? (wr_bank+2)%3:(wr_bank+1)%3);
reg   	[1:0]	wr_bank_last; 

//sdram_wr_addr:sdram写地址
reg	[12:0]	wraddress;//写地址
reg			frame_write_done;
always@(posedge wrclock or negedge rst_n)
begin
    if(rst_n == 1'b0)
		begin
			wraddress   	<=	12'd0;	
			wr_bank <= 2'd0;
			wr_bank_last <= 2'd0;
		end
    else    if(wr_load_flag)
		begin
			wraddress   	<=	{wr_bank_next,11'd0};	
			wr_bank <= wr_bank_next;
			wr_bank_last <= wr_bank;
			frame_write_done <= 1'b0;
		end
    else    if(wren) 
        begin
            if(wraddress[10:0] < WIDTH*HEIGHT-1)
				begin//写地址未达到末地址,写地址累加
					wraddress <= wraddress + 1'b1;
					frame_write_done <= 1'b0;
				end
			else
				begin
					wraddress <= {wr_bank,11'd0};//防止溢出，锁存地址
					frame_write_done <= 1'b1;
				end
        end
    else    
		begin
			wraddress <= wraddress;			
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

	
reg [12:0]	rdaddress;	//读地址
reg			frame_read_done;
always@(posedge rdclock or negedge rst_n)
begin
    if(rst_n == 1'b0)
		begin
			rdaddress   <=  12'd0;
			rd_bank <= 2'd0;
		end
    else    if(rd_load_flag)
		begin
			rdaddress   <=  {wr_bank_last,11'd0};
			rd_bank <= wr_bank_last;
			frame_read_done <= 1'b0;
		end
    else    if(rdreq) //读请求，则增加读地址
        begin
			if(rdaddress[10:0] < HEIGHT*WIDTH)
         		begin
//					rdaddress[9:0] <= h_pos + v_pos*28;
					rdaddress <= rdaddress + 1'b1;
					frame_read_done <= 1'b0;
         		end
         	else  
         		begin
         			rdaddress <= {rd_bank,11'd0};
					frame_read_done <= 1'b1;
         		end       
        end
	else 
		begin
			rdaddress <= rdaddress;		
		end
end
	
ram_2port ram_2port_inst
(
    .wrclock	(wrclock),
    .data		(wr_data),
	.wren		(wren),
	.wr_aclr	(!rst_n),
    .wraddress	(wraddress),
	    
    .rdclock	(rdclock),
    .q			(rd_data),
    .rden		(rdreq),
	.rd_aclr	(!rst_n),
	.rdaddress	(rdaddress)
);


endmodule
