module uart_rx
#(
    parameter   UART_BPS    =   'd115200,         //串口波特率
    parameter   CLK_FREQ    =   'd25_000_000    //时钟频率
)
(
    input   wire            sys_clk     ,   //系统时钟50MHz
    input   wire            sys_rst_n   ,   //全局复位
    input   wire            rx          ,   //串口接收数据

    output  reg     [15:0]   po_data     ,   //串转并后的48bit数据
    output  reg             po_flag         //串转并后的数据有效标志信号
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//localparam    define
localparam  BAUD_CNT_MAX    =   CLK_FREQ/UART_BPS   ;

//reg   define
reg         rx_reg1     ;
reg         rx_reg2     ;
reg         rx_reg3     ;
reg         start_nedge ;
reg         work_en     ;
reg [12:0]  baud_cnt    ;
reg         bit_flag    ;
reg [3:0]   bit_cnt     ;
reg [7:0]   rx_data     ;
reg         rx_flag     ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//插入两级寄存器进行数据同步，用来消除亚稳态
//rx_reg1:第一级寄存器，寄存器空闲状态复位为1
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_reg1 <= 1'b1;
    else
        rx_reg1 <= rx;

//rx_reg2:第二级寄存器，寄存器空闲状态复位为1
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_reg2 <= 1'b1;
    else
        rx_reg2 <= rx_reg1;

//rx_reg3:第三级寄存器和第二级寄存器共同构成下降沿检测
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_reg3 <= 1'b1;
    else
        rx_reg3 <= rx_reg2;

//start_nedge:检测到下降沿时start_nedge产生一个时钟的高电平
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        start_nedge <= 1'b0;
    else    if((~rx_reg2) && (rx_reg3))
        start_nedge <= 1'b1;
    else
        start_nedge <= 1'b0;

//work_en:接收数据工作使能信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        work_en <= 1'b0;
    else    if(start_nedge == 1'b1)
        work_en <= 1'b1;
    else    if((bit_cnt == 4'd8) && (bit_flag == 1'b1))
        work_en <= 1'b0;

//baud_cnt:波特率计数器计数，从0计数到BAUD_CNT_MAX - 1
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        baud_cnt <= 13'b0;
    else    if((baud_cnt == BAUD_CNT_MAX - 1) || (work_en == 1'b0))
        baud_cnt <= 13'b0;
    else    if(work_en == 1'b1)
        baud_cnt <= baud_cnt + 1'b1;

//bit_flag:当baud_cnt计数器计数到中间数时采样的数据最稳定，
//此时拉高一个标志信号表示数据可以被取走
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_flag <= 1'b0;
    else    if(baud_cnt == BAUD_CNT_MAX/2 - 1)
        bit_flag <= 1'b1;
    else
        bit_flag <= 1'b0;

//bit_cnt:有效数据个数计数器，当8个有效数据（不含起始位和停止位）
//都接收完成后计数器清零
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_cnt <= 4'b0;
    else    if((bit_cnt == 4'd8) && (bit_flag == 1'b1))
        bit_cnt <= 4'b0;
     else    if(bit_flag ==1'b1)
         bit_cnt <= bit_cnt + 1'b1;

//rx_data:输入数据进行移位
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_data <= 8'b0;
    else    if((bit_cnt >= 4'd1)&&(bit_cnt <= 4'd8)&&(bit_flag == 1'b1))
        rx_data <= {rx_reg3, rx_data[7:1]};

//rx_flag:输入数据移位完成时rx_flag拉高一个时钟的高电平
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_flag <= 1'b0;
    else    if((bit_cnt == 4'd8) && (bit_flag == 1'b1))
        rx_flag <= 1'b1;
    else
        rx_flag <= 1'b0;

//reg [47:0] rx_data_six;  // Modified to 48 bits
reg [15:0] rx_data_six;  // Modified to 48 bits
reg [3:0] cnt_data;
reg flag;
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
        cnt_data <= 3'b0;
		flag<=1'b0;
	end else  if(rx_flag == 1'b1)begin
//		if(cnt_data==3'd5)begin
		if(cnt_data==3'd1)begin
		   cnt_data<=1'b0;
		   flag<=1'b1;		
		end else begin
       	   cnt_data<=cnt_data+1'b1;
		   flag<=1'b0;
		end
	end

//po_data:输出完整的8位有效数据
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rx_data_six <= 48'b0;  // Modified to 48 bits
    else    if(rx_flag == 1'b1)begin
		case(cnt_data)
        	3'd0 :rx_data_six[15:8] <= rx_data;
        	3'd1 :rx_data_six[7:0] <= rx_data;
//        	3'd0 :rx_data_six[47:40] <= rx_data;
//        	3'd1 :rx_data_six[39:32] <= rx_data;
//        	3'd2 :rx_data_six[31:24] <= rx_data;
//        	3'd3 :rx_data_six[23:16] <= rx_data;
//        	3'd4 :rx_data_six[15:8] <= rx_data;
//        	3'd5 :rx_data_six[7:0] <= rx_data;
			default:rx_data_six<=rx_data_six;
		endcase
	end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
//        po_data <= 48'b0;  // Modified to 48 bits
        po_data <= 16'b0;  // Modified to 48 bits
    else if(flag)begin
        po_data <= rx_data_six;
	end 

//po_flag:输出数据有效标志（比rx_flag延后一个时钟周期，为了和po_data同步）
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <= 1'b0;
    else
        po_flag <= flag;

endmodule
