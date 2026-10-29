`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04-27-2025 19:49:54
// Design Name:
// Module Name: uart_top
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


module uart_top#(
    parameter   UART_BPS    =   'd9600,         //串口波特率
    parameter   CLK_FREQ    =   'd50_000_000    //时钟频率
)(
    input   wire            sys_clk     ,   //系统时钟50MHz
    input   wire            sys_rst_n   ,   //全局复位
    input   wire    [31:0]   pi_data     ,   //模块输入的8bit数据
    input   wire            pi_flag     ,   //并行数据有效标志信号
//    output  wire    [47:0]   po_data     ,   //串转并后的8bit数据
    output  wire    [15:0]   po_data     ,   //串转并后的8bit数据
    output  wire            po_flag     ,   //串转并后的数据有效标志信号
    input   wire            rx          ,   //串口接收数据
    output  wire            tx              //串转并后的1bit数据
);
	
//------------- uart_rx_inst -------------
uart_rx
#(
    .UART_BPS    (UART_BPS  ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ  )    //时钟频率
)
uart_rx_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n     ),   //全局复位
    .rx          (rx        ),   //串口接收数据

    .po_data     (po_data   ),   //串转并后的数据
    .po_flag     (po_flag   )    //串转并后的数据有效标志信号
);

//------------- uart_tx_inst -------------
uart_tx
#(
    .UART_BPS    (UART_BPS  ),   //串口波特率
    .CLK_FREQ    (CLK_FREQ  )    //时钟频率
)
uart_tx_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n     ),   //全局复位
    .pi_data     (pi_data   ),   //并行数据
    .pi_flag     (pi_flag   ),   //并行数据有效标志信号

    .tx          (tx        )    //串口发送数据
);
	
endmodule
