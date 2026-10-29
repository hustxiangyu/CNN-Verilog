module isp_yuv2rgb
#(
	parameter BITS   = 8,
	parameter WIDTH  = 1920,
	parameter HEIGHT = 1080
)
(
	input pclk,
	input rst_n,
	input switch,
	input in_href,
    input in_hsync,
	input in_vsync,
	input [BITS-1:0] in_y,
	input [BITS-1:0] in_u,
	input [BITS-1:0] in_v,

	output reg out_href,
    output reg out_hsync,
	output reg out_vsync,
	output reg [BITS-1:0] out_r,
	output reg [BITS-1:0] out_g,
	output reg [BITS-1:0] out_b
);

	reg	signed [BITS-1:0]	in_y_reg;
	reg	signed [BITS-1:0]	in_u_reg; 
	reg	signed [BITS-1:0]	in_v_reg;
	always @ (posedge pclk or negedge rst_n) begin
		if(!rst_n) begin
			in_y_reg <= 0;
			in_u_reg <= 0;
			in_v_reg <= 0;
		end
		else begin
			in_y_reg <= in_y;
			in_u_reg <= in_u;
			in_v_reg <=	in_v;
		end
	end

	//--------------------------------------------
	/*********************************************
		R = 1.000Y + 1.4020(Cr-2048)
		G = 1.000Y - 0.3441(Cb-2048) - 0.7139(Cr-2048)
		B = 1.000Y + 1.7718(Cb-2048) - 0.0013(Cr-2048)
		->
		R = 1.000Y + 1.4020Cr - 2871.296
		G = 1.000Y - 0.3441Cb - 0.7139Cr + 2166.784
		B = 1.000Y + 1.7718Cb - 0.0013Cr - 3625.984
		->
		R << 9 = 512Y				+ 	718Cr	-	1470104
		G << 9 = 512Y	-	176Cb	-	366Cr	+	1109393
		B << 9 = 512Y	+	907Cb	-	1Cr		-	1856504
	**********************************************/
	reg	signed [BITS-1+12:0]	img_Y_r1; 				//8 + 9 + 1 = 18Bit
	reg	signed [BITS-1+12:0]	img_Cb_r1, img_Cb_r2; 
	reg	signed [BITS-1+12:0]	img_Cr_r1, img_Cr_r2, img_Cr_r3;
	always @ (posedge pclk or negedge rst_n) begin
		if(!rst_n) begin
			img_Y_r1 <= 0;
			img_Cb_r1 <= 0;	img_Cb_r2 <= 0;	
			img_Cr_r1 <= 0; img_Cr_r2 <= 0;
		end
		else begin
			img_Y_r1	<= 	in_y_reg * 12'd512;
			img_Cb_r1 	<= 	in_u_reg * 12'd176;	
			img_Cb_r2	<=	in_u_reg * 12'd907;	
			img_Cr_r1 	<= 	in_v_reg * 12'd718;	
			img_Cr_r2	<=	in_v_reg * 12'd366;
            img_Cr_r3   <=  in_v_reg * 12'd1  ;
		end
	end

	//--------------------------------------------
	/**********************************************
		R << 9 = 512Y				+ 	718Cr	-	1470104
		G << 9 = 512Y	-	176Cb	-	366Cr	+	1109393
		B << 9 = 512Y	+	907Cb	-	1Cr		-	1856504
	**********************************************/
	reg	signed [BITS-1+12:0]	XOUT; 	
	reg	signed [BITS-1+12:0]	YOUT; 
	reg	signed [BITS-1+12:0]	ZOUT;
	always @ (posedge pclk or negedge rst_n) begin
		if(!rst_n) begin
			XOUT <= 0; 	
			YOUT <= 0; 
			ZOUT <= 0;
		end
		else begin
			XOUT <= (img_Y_r1 + img_Cr_r1 - (24'sd1470104))>>>9; 	
			YOUT <= (img_Y_r1 - img_Cb_r1 - img_Cr_r2 + (24'sd1109393))>>>9; 
			ZOUT <= (img_Y_r1 + img_Cb_r2 - img_Cr_r3 - (24'sd1856504))>>>9;
		end
	end

	//------------------------------------------
	//Divide 512 and get the result
	//{xx[19:11], xx[10:0]}
	reg	[BITS-1:0]	R, G, B;
	always @ (posedge pclk or negedge rst_n) begin
		if(!rst_n) begin
			R <= 0;
			G <= 0;
			B <= 0;
		end
		else begin
			R <= XOUT < 4'sd0 ? {BITS{1'b0}} : (XOUT > {BITS-4{1'b1}}) ? {BITS{1'b1}} : XOUT[BITS-1:0];
			G <= YOUT < 4'sd0 ? {BITS{1'b0}} : (YOUT > {BITS-4{1'b1}}) ? {BITS{1'b1}} : YOUT[BITS-1:0];
			B <= ZOUT < 4'sd0 ? {BITS{1'b0}} : (ZOUT > {BITS-4{1'b1}}) ? {BITS{1'b1}} : ZOUT[BITS-1:0];
		end
	end

	//------------------------------------------
	//lag n clocks signal sync  	 
	reg	[3:0]	vsync_r;
	reg	[3:0]	href_r;
	always @ (posedge pclk or negedge rst_n) begin
		if(!rst_n) begin
			vsync_r <= 0;
			href_r <= 0;
		end
		else begin
			vsync_r <= {vsync_r[2:0], in_vsync};
			href_r <= {href_r[2:0], in_href};
		end
	end
always@(*)begin
	if(switch)begin
		out_vsync <= vsync_r[3];
		out_href <= href_r[3];
		out_r <= out_href ? R : {BITS{1'b0}};
		out_g <= out_href ? G : {BITS{1'b0}};
		out_b <= out_href ? B : {BITS{1'b0}};
	end else begin
		out_vsync <= in_vsync;
		out_href <= in_href;
		out_r <= in_y;
		out_g <= in_u;
		out_b <= in_v;
	end
end
endmodule
