module Line_Reg#(
    parameter BITWIDTH = 8,
    parameter WIDTH = 320
)(
	input wire clk,
    input wire rst_n,
    input wire signed [BITWIDTH-1'b1:0] din,
    input wire i_de,
    output reg signed [BITWIDTH-1:0] p00,
    output reg signed [BITWIDTH-1:0] p01,
    output reg signed [BITWIDTH-1:0] p02,
    output reg signed [BITWIDTH-1:0] p10,
    output reg signed [BITWIDTH-1:0] p11,
    output reg signed [BITWIDTH-1:0] p12,
    output reg signed [BITWIDTH-1:0] p20,
    output reg signed [BITWIDTH-1:0] p21,
    output reg signed [BITWIDTH-1:0] p22,
    output reg o_de
 );
 
reg signed [BITWIDTH-1:0] line0 [0:WIDTH+ 1];
reg signed [BITWIDTH-1:0] line1 [0:WIDTH+ 1];
reg signed [BITWIDTH-1:0] line2 [0:WIDTH+ 1];
reg signed [BITWIDTH-1:0] line3 [0:WIDTH+ 1];
reg [10:0] r_cnt;
reg [1:0] h_cnt;
reg i_de_dly;

integer k;
initial begin
	for (k = 0;k < WIDTH + 2;k = k + 1 ) begin
    	line0[k] <= 1'b0;
		line1[k] <= 1'b0;
		line2[k] <= 1'b0;
		line3[k] <= 1'b0;
    end
end

always @(posedge clk) begin
	if (!rst_n) begin
    	r_cnt <= 1'b0;
        h_cnt <= 1'b1;
    end else if (r_cnt < WIDTH) begin
    	if (i_de) begin
			if (r_cnt + 1 == WIDTH) begin
				h_cnt <= h_cnt + 1'b1;
				r_cnt <= 1'b0;
			end else begin
				r_cnt <= r_cnt + 1'b1;
			end
        end else begin
        	r_cnt <= r_cnt;
        end
    end else begin
    	r_cnt <= r_cnt;
		h_cnt <= h_cnt;
    end
end

always @(posedge clk) begin
	if (i_de) begin
    	case(h_cnt)
        	2'd0: line0[r_cnt+1] <= din;
            2'd1: line1[r_cnt+1] <= din;
            2'd2: line2[r_cnt+1] <= din;
            2'd3: line3[r_cnt+1] <= din;
            default : line0[0] <= line0[0];
        endcase
    end
end

always @(posedge clk) begin
	if (!i_de) begin
        o_de<= 1'b0;
    end else begin
        o_de<= 1'b1;
    end
end

always @(posedge clk) begin
	case(h_cnt)
    2'd3: begin
		p00 <= line0[r_cnt];
        p01 <= line0[r_cnt + 1];
        p02 <= line0[r_cnt + 2];
        p10 <= line1[r_cnt];
        p11 <= line1[r_cnt + 1];
        p12 <= line1[r_cnt + 2];
        p20 <= line2[r_cnt];
        p21 <= line2[r_cnt + 1];
        p22 <= line2[r_cnt + 2];
    end
    2'd0: begin
		p00 <= line1[r_cnt];
        p01 <= line1[r_cnt + 1];
        p02 <= line1[r_cnt + 2];
        p10 <= line2[r_cnt];
        p11 <= line2[r_cnt + 1];
        p12 <= line2[r_cnt + 2];
        p20 <= line3[r_cnt];
        p21 <= line3[r_cnt + 1];
        p22 <= line3[r_cnt + 2];
    end
    2'd1: begin
		p00 <= line2[r_cnt];
        p01 <= line2[r_cnt + 1];
        p02 <= line2[r_cnt + 2];
        p10 <= line3[r_cnt];
        p11 <= line3[r_cnt + 1];
        p12 <= line3[r_cnt + 2];
        p20 <= line0[r_cnt];
        p21 <= line0[r_cnt + 1];
        p22 <= line0[r_cnt + 2];
    end
    2'd2: begin
		p00 <= line3[r_cnt];
        p01 <= line3[r_cnt + 1];
        p02 <= line3[r_cnt + 2];
        p10 <= line0[r_cnt];
        p11 <= line0[r_cnt + 1];
        p12 <= line0[r_cnt + 2];
        p20 <= line1[r_cnt];
        p21 <= line1[r_cnt + 1];
        p22 <= line1[r_cnt + 2];
    end
    endcase
end
endmodule
