`timescale 1 ns/ 1 ns
module eth_top(
	input	wire			GMII_GTXC,
	output	wire	[7:0]	GMII_TXD,
	output	wire			GMII_TXEN,
	
	input	wire			rst_n,
	
	input 	wire 			cnn_en,
	input	wire	[3:0]	cnn_result,
	input	wire	[7:0]	cnn_count,
	input	wire			ov5640_pclk,
	input	wire			ov5640_frame_vsync,
	input	wire			ov5640_frame_href,
	input	wire	[15:0]	image_data
);

UDP_Send UDP_Send(
	.Clk(),
	.GMII_GTXC(GMII_GTXC),
	.GMII_TXD(GMII_TXD),
	.GMII_TXEN(GMII_TXEN),
	.Rst_n(rst_n),
	.Tx_Done(),
	.data_length(1280*2+2+2),
	.des_ip(32'hc0_a8_00_03),
	.des_mac(48'hFF_FF_FF_FF_FF_FF),
//	.des_mac(48'hC8_4D_44_27_33_53),
	.des_port(16'd6102),
	.src_ip(32'hc0_a8_00_02),
	.src_mac(48'h00_0a_35_01_fe_c0),
	.src_port(16'd5000),
	.wrclk(ov5640_pclk),
	.wrdata(eth_fifo_wrdata),
	.wrreq(eth_fifo_wrreq),
	.aclr(ov5640_frame_vsync),
	.wrusedw()
);

wire [15:0]eth_fifo_wrdata;
wire eth_fifo_wrreq;
//ÒÔÌ«ÍøÍ¼ÏñÐÐºÅ±àºÅÂß¼­
Camera_ETH_Formator Camera_ETH_Formator(
	.Rst_n(rst_n),
	.PCLK(ov5640_pclk),
	.HREF(ov5640_frame_href),
	.VSYNC(ov5640_frame_vsync),
	.DATA({image_data[7:0],image_data[15:8]}),

	
	.cnn_en(cnn_en_reg),
	.cnn_re(cnn_result_reg),
	.cnn_count(cnn_count_reg),
	
	.wrdata(eth_fifo_wrdata),
	.wrreq(eth_fifo_wrreq)
);

reg [3:0] cnn_result_reg;
reg [7:0] cnn_count_reg;
reg cnn_en_reg;
reg cnn_next_send;
reg cnn_next_rst;

always @(posedge ov5640_pclk or negedge rst_n)begin
	if (!rst_n) begin
		cnn_en_reg <= 0;
		cnn_result_reg <= 0;
		cnn_count_reg<=0;
		cnn_next_send <= 0;
		cnn_next_rst <= 0;
	end else if (cnn_en) begin
		cnn_result_reg <= cnn_result;
		cnn_count_reg<= cnn_count;
		cnn_next_send <= 1;
	end else if (ov5640_frame_vsync) begin
		if (cnn_next_send) begin
			cnn_en_reg <= 1;
			cnn_next_rst <= 1;
		end else begin
			cnn_en_reg <= 0;
			cnn_result_reg <= 0;
			cnn_count_reg<=0;
			cnn_next_rst <= 0;
		end
	end else if (!ov5640_frame_vsync && cnn_next_rst) begin
		cnn_next_send <= 0;
	end else begin
		cnn_en_reg <= cnn_en_reg;
		cnn_result_reg <= cnn_result_reg;
		cnn_count_reg<=cnn_count_reg;
		cnn_next_send <= cnn_next_send;
		cnn_next_rst <= cnn_next_rst;
	end
end
	
endmodule
