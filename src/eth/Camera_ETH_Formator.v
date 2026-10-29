module Camera_ETH_Formator(
	Rst_n,
	PCLK,
	HREF,
	VSYNC,
	DATA,
	
	cnn_en,
	cnn_re,
	cnn_count,
	wrdata,
	wrreq
);

	input PCLK;
	input Rst_n;
	input HREF;
	input VSYNC;
	input [15:0]DATA;
	
	input cnn_en;
	input [3:0]cnn_re;
	input	[7:0] cnn_count;

	output  [15:0]wrdata;
	output reg wrreq;
	
	reg [63:0]data_tmp;
	
	reg [15:0]Vcnt;
		
	reg href_r1;
	reg href_r2;
	reg href_r3;
	reg href_r4;

	assign wrdata = data_tmp[63:48];
	
	always@(posedge PCLK)begin
		href_r1 <= HREF;
		href_r2 <= href_r1;	
		href_r3 <= href_r2;	
		href_r4 <= href_r3;	
	end
	
	always@(posedge PCLK or negedge Rst_n)
	if(!Rst_n)
		data_tmp <= 0;
	else if({href_r1,HREF} == 2'b01)
		data_tmp <= {Vcnt[7:0],Vcnt[15:8],{cnn_en,3'b0,cnn_re,cnn_count},{cnn_en,3'b0,cnn_re,cnn_count},DATA};
	else 
		data_tmp <= {data_tmp[47:0],DATA};
	
	
	always@(posedge PCLK)
	if({href_r1,HREF} == 2'b01)
		wrreq <= 1;
	else if(href_r4 |href_r3 |href_r2 | href_r1)
		wrreq <= ~wrreq;
	else
		wrreq <= 0;

	always@(posedge PCLK or negedge Rst_n)
	if(!Rst_n)
		Vcnt <= 0;
	else if(VSYNC)
		Vcnt <= 0;
	else if({href_r1,HREF} == 2'b10)
		Vcnt <= Vcnt + 1'd1;

endmodule
