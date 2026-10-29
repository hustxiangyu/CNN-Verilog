
`timescale 1 ns / 1 ps
/*
 * ISP - Color Space Conversion (RGB2YUV)
 */
module isp_rgb2yuv
#(
	parameter BITS = 8,
	parameter WIDTH = 1280,
	parameter HEIGHT = 720
)
(
	input 	wire			pclk,
	input 	wire			rst_n,
        
	input 	wire			switch,

	input 	wire			in_href,
	input 	wire			in_vsync,
	input 	wire 			in_en,
	input 	wire			[BITS-1:0] in_r,
	input 	wire			[BITS-1:0] in_g,
	input 	wire			[BITS-1:0] in_b,


	output 	reg				out_href,
	output 	reg				out_vsync,
	output 	reg				out_en,
	output 	reg	[BITS-1:0] 	out_y,
	output 	reg	[BITS-1:0] 	out_u,
	output 	reg	[BITS-1:0] 	out_v
);

	//Y = (77  * R + 150 * G + 29  * B) >> 8
	//U = (-43 * R - 85  * G + 128 * B + 32768) >> 8
	//V = (128 * R - 107 * G - 21  * B + 32768) >> 8

	reg [BITS-1:0] data_r;
	reg [BITS-1:0] data_g;
	reg [BITS-1:0] data_b;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			data_r <= 0;
			data_g <= 0;
			data_b <= 0;
		end
		else begin
			data_r <= in_r;
			data_g <= in_g;
			data_b <= in_b;
		end
	end

	reg [BITS-1+8:0] y_r, y_g, y_b;
	reg [BITS-1+8:0] u_r, u_g, u_b;
	reg [BITS-1+8:0] v_r, v_g, v_b;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			y_r <= 0;
			y_g <= 0;
			y_b <= 0;
			u_r <= 0;
			u_g <= 0;
			u_b <= 0;
			v_r <= 0;
			v_g <= 0;
			v_b <= 0;
		end
		else begin
			y_r <= data_r * 8'd77;
			y_g <= data_g * 8'd150;
			y_b <= data_b * 8'd29;
			u_r <= data_r * 8'd43;
			u_g <= data_g * 8'd85;
			u_b <= data_b * 8'd128;
			v_r <= data_r * 8'd128;
			v_g <= data_g * 8'd107;
			v_b <= data_b * 8'd21;
		end
	end

	reg [BITS-1+8:0] data_y;
	reg [BITS-1+8:0] data_u;
	reg [BITS-1+8:0] data_v;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			data_y <= 0;
			data_u <= 0;
			data_v <= 0;
		end
		else begin
			data_y <= y_r + y_g + y_b;
			data_u <= u_b - u_r - u_g + (1'b1 << (BITS-1+8)); //compatible 10bit RGB
			data_v <= v_r - v_g - v_b + (1'b1 << (BITS-1+8));
		end
	end


	reg [BITS-1:0] in_rr [2:0];
    reg [BITS-1:0] in_gg [2:0];
    reg [BITS-1:0] in_bb [2:0];

	localparam DLY_CLK = 3;
	reg [DLY_CLK-1:0] href_dly;
	reg [DLY_CLK-1:0] vsync_dly;
	reg [DLY_CLK-1:0] en_dly;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			href_dly <= 0;
			vsync_dly <= 0;
			en_dly<=0;
			
			in_rr[0] <= 0;
         in_gg[0] <= 0;
         in_bb[0] <= 0;

         in_rr[1] <= 0;
         in_gg[1] <= 0;
         in_bb[1] <= 0;

         in_rr[2] <= 0;
         in_gg[2] <= 0;
         in_bb[2] <= 0;
		end
		else begin
			href_dly <= {href_dly[DLY_CLK-2:0], in_href};
			vsync_dly <= {vsync_dly[DLY_CLK-2:0], in_vsync};
			en_dly	<=	{en_dly[DLY_CLK-2:0], in_en};
			
			in_rr[0] <= in_r;
            in_gg[0] <= in_g;
            in_bb[0] <= in_b;

            in_rr[1] <= in_rr[0];
            in_gg[1] <= in_gg[0];
            in_bb[1] <= in_bb[0];

            in_rr[2] <= in_rr[1];
            in_gg[2] <= in_gg[1];
            in_bb[2] <= in_bb[1];
		end
	end

	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			out_href 	<= 0;
    		out_vsync 	<= 0;
			out_y 		<= 0;
			out_u 		<= 0;
			out_v 		<= 0;
     	end
        else if(switch)begin
        	out_href 	<= href_dly[DLY_CLK-1];                                                
			out_vsync 	<= vsync_dly[DLY_CLK-1];     
			out_en 		<= en_dly[DLY_CLK-1];  			
			out_y 		<= out_href ? (1'b0 ? in_rr[2] : data_y[BITS-1+8:8]) : {BITS{1'b0}}; 
			out_u 		<= out_href ? (1'b0 ? in_gg[2] : data_u[BITS-1+8:8]) : {BITS{1'b0}}; 
			out_v 		<= out_href ? (1'b0 ? in_bb[2] : data_v[BITS-1+8:8]) : {BITS{1'b0}}; 
		end else begin
        	out_href 	<= in_href;                                                
			out_vsync 	<= in_vsync;   
			out_en 		<= in_en;
			out_y 		<= in_r; 
			out_u 		<= in_g; 
			out_v 		<= in_b;
		end
	end
        
endmodule

