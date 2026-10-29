module isp_ee
#(
	parameter BITS = 8,
	parameter WIDTH = 1920,
	parameter HEIGHT = 1080
)
(
	input 	wire				pclk,
	input 	wire				rst_n,
	input	wire			    switch,
	input 	wire				in_href,
    input 	wire				in_hsync,
	input 	wire				in_vsync,
	input 	wire	[BITS-1:0] 	in_y,
	input 	wire	[BITS-1:0] 	in_u,
	input 	wire	[BITS-1:0] 	in_v,

	output	reg					out_href,
    output 	reg					out_hsync,
	output 	reg					out_vsync,
	output 	reg		[BITS-1:0] 	out_y,
	output 	reg		[BITS-1:0] 	out_u,
	output 	reg		[BITS-1:0] 	out_v
);

	wire [BITS-1:0] shiftout;
	wire [BITS-1:0] tap1x, tap0x;
	shift_register #(BITS, WIDTH, 2) linebuffer(pclk, in_href, in_y, shiftout, {tap1x, tap0x});
	
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
			in_y_1 <= in_y;
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

	// filter kernel
	// -1, -1, -1
	// -1, 12, -1
	// -1, -1, -1
	reg signed [BITS-1+5:0] y_core, y_edge;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			y_core <= 0;
			y_edge <= 0;
		end
		else begin
			y_core <= {5'd0, p22} + {2'd0, p22, 3'd0}; // x9
			y_edge <= (({5'd0, p11} + {5'd0, p12}) + ({5'd0, p13} + {5'd0, p21})) + (({5'd0, p23} + {5'd0, p31}) + ({5'd0, p32} + {5'd0, p33}));
		end
	end

	reg signed [BITS-1+6:0] y_data;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			y_data <= 0;
		end
		else begin
			y_data <= y_core - y_edge;
		end
	end

	reg [BITS-1:0] y_data_1;
always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			y_data_1 <= 0;
		end
		else begin
			y_data_1 <= y_data < 6'sd0 ? {BITS{1'b0}} : ( y_data > {BITS+2{1'b1}}+8'd140 ? {BITS{1'b1}} : y_data[BITS-1:0]);// 1/4
		end
	end
/* 
reg y_data_neg;  // 判断 y_data 是否小于 0
reg y_data_over; // 判断 y_data 是否大于上限

always @(posedge pclk or negedge rst_n) begin
	if (!rst_n) begin
		y_data_neg <= 1'b0;
		y_data_over <= 1'b0;
	end
	else begin
		y_data_neg <= (y_data < 6'sd0);
		y_data_over <= (y_data > {BITS+2{1'b1}} + 8'd132);
	end
end

always @(posedge pclk or negedge rst_n) begin
	if (!rst_n) begin
		y_data_1 <= 0;
	end
	else if (y_data_neg) begin
		y_data_1 <= {BITS{1'b0}};
	end
	else if (y_data_over) begin
		y_data_1 <= {BITS{1'b1}};
	end
	else begin
		y_data_1 <= y_data[BITS-1:0];
	end
end
*/

	localparam DLY_CLK = 6;
	reg [DLY_CLK-1:0] href_dly;
    reg [DLY_CLK-1:0] hsync_dly;
	reg [DLY_CLK-1:0] vsync_dly;
	reg [BITS-1:0] u_dly [DLY_CLK-1:0];
	reg [BITS-1:0] v_dly [DLY_CLK-1:0];
	integer i;
	always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			href_dly <= 0;
            hsync_dly <= 0;
			vsync_dly <= 0;
			for (i = 0; i < DLY_CLK; i = i + 1) begin
				u_dly[i] <= 0;
				v_dly[i] <= 0;
			end
		end
		else begin
			href_dly <= {href_dly[DLY_CLK-2:0], in_href};
            hsync_dly <= {hsync_dly[DLY_CLK-2:0], in_hsync};
			vsync_dly <= {vsync_dly[DLY_CLK-2:0], in_vsync};
			u_dly[0] <= in_u;
			v_dly[0] <= in_v;
			for (i = 1; i < DLY_CLK; i = i + 1) begin
				u_dly[i] <= u_dly[i-1];
				v_dly[i] <= v_dly[i-1];
			end
		end
	end
	
    
    always @ (posedge pclk or negedge rst_n) begin
		if (!rst_n) begin
			out_href 	<= 0;
    		out_hsync 	<= 0;
			out_vsync 	<= 0;
			out_y 		<= 0;
			out_u 		<= 0;
			out_v 		<= 0;
     	end
        else if(switch)begin
        	out_href 	<= href_dly[DLY_CLK-1];
    		out_hsync 	<= hsync_dly[DLY_CLK-1];
			out_vsync 	<= vsync_dly[DLY_CLK-1];
			out_y 		<= out_href ? y_data_1 : {BITS{1'b0}};
			out_u 		<= out_href ? u_dly[DLY_CLK-1] : {BITS{1'b0}};
			out_v 		<= out_href ? v_dly[DLY_CLK-1] : {BITS{1'b0}};
		end else begin
			out_href 	<=in_href;
            out_hsync 	<=in_hsync;
            out_vsync 	<=in_vsync;
            out_y 		<=in_y;
            out_u 		<=in_u;
            out_v 		<=in_v;
		end
	end
        
endmodule
