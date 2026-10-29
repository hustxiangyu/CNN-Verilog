module isp_dilation
#(
	parameter BITS = 8,
	parameter WIDTH = 1920,
	parameter HEIGHT = 1080
)
(
    
    input 	wire				pclk,
	input 	wire				rst_n,
	input	wire				switch ,
	input 	wire				per_img_href,
	input 	wire				per_img_vsync,
	input 	wire	[BITS-1:0]	per_img_bit,
    input 	wire	[BITS-1:0]	per_img_u,
    input 	wire	[BITS-1:0]	per_img_v,


    output reg                  post_img_vsync  ,       
    output reg                  post_img_href   , 
    output reg      [BITS-1:0]  post_img_bit   	,
   	output reg      [BITS-1:0]  post_img_u   	,
    output reg      [BITS-1:0]  post_img_v   	     
);

	wire [BITS-1:0] shiftout;
	wire [BITS-1:0] tap1x, tap0x;
	shift_register #(BITS, WIDTH, 2) linebuffer(pclk, per_img_href, per_img_bit, shiftout, {tap1x, tap0x});
	
	reg [BITS-1:0] in_y_1;
	reg [BITS-1:0] p11,p12,p13;
	reg [BITS-1:0] p21,p22,p23;
	reg [BITS-1:0] p31,p32,p33;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			in_y_1 <= 0;
			p11 <= 0;
			p21 <= 0;
			p31 <= 0;
			p12 <= 0;
			p22 <= 0;
			p32 <= 0;
			p13 <= 0;
			p23 <= 0;
			p33 <= 0;
		end
		else begin
			in_y_1 <= per_img_bit;
			p11 <= p12;
			p21 <= p22;
			p31 <= p32;
			p12 <= p13;
			p22 <= p23;
			p32 <= p33;
			p13 <= tap1x;
			p23 <= tap0x;
			p33 <= in_y_1;
		end
	end

	reg signed data_sum;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			data_sum <= 0;
		end
		else begin
			data_sum <= p11[0] || p12[0] || p13[0] || p21[0] || p22[0] || p23[0] || p31[0] || p32[0] || p33[0];
		end
	end

	reg signed y_data;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			y_data <= 0;
		end
		else begin
			y_data <= data_sum;
		end
	end

	reg [BITS-1:0]y_data_1;
    
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			y_data_1 <= 0;
		end
		else begin
			y_data_1 <= {BITS{y_data}};
		end
	end


	localparam DLY_CLK = 6;
	reg [DLY_CLK-1:0] href_dly;

	reg [DLY_CLK-1:0] vsync_dly;
	reg [BITS-1:0] u_dly [DLY_CLK-1:0];
	reg [BITS-1:0] v_dly [DLY_CLK-1:0];
	integer i;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			href_dly <= 0;

			vsync_dly <= 0;
			for (i = 0; i < DLY_CLK; i = i + 1) begin
				u_dly[i] <= 0;
				v_dly[i] <= 0;
			end
		end
		else begin
			href_dly <= {href_dly[DLY_CLK-2:0], per_img_href};
			vsync_dly <= {vsync_dly[DLY_CLK-2:0], per_img_vsync};
			u_dly[0] <= per_img_u;
			v_dly[0] <= per_img_v;
			for (i = 1; i < DLY_CLK; i = i + 1) begin
				u_dly[i] <= u_dly[i-1];
				v_dly[i] <= v_dly[i-1];
			end
		end
	end
	
    
    always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			post_img_href 	<= 0;
			post_img_vsync 	<= 0;
			post_img_bit 	<= 0;
			post_img_u 		<= 0;
			post_img_v 		<= 0;
     	end
        else if(switch)begin
        	post_img_href 	<= href_dly[DLY_CLK-1];
			post_img_vsync 	<= vsync_dly[DLY_CLK-1];
			post_img_bit 	<= post_img_href ? y_data_1 : 1'b0;
			post_img_u 		<= post_img_href ? u_dly[DLY_CLK-1] : {BITS{1'b0}};
			post_img_v 		<= post_img_href ? v_dly[DLY_CLK-1] : {BITS{1'b0}};
		end else begin
        	post_img_href 	<= per_img_href;
			post_img_vsync 	<= per_img_vsync;
			post_img_bit 	<= per_img_bit;
			post_img_u 		<= per_img_u;
			post_img_v 		<= per_img_v;			
		end
	end
        
endmodule
