`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04-28-2025 19:25:39
// Design Name:
// Module Name: photo
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


module photo(
	input	wire		clk,
	input	wire		rst_n,
	input	wire		req,
	output	reg  [7:0] 	dat,
	output	reg 		valid
    );
	
reg [7:0] data [0:1023];

initial begin
	$readmemb("parameter/photo.txt", data); 
end

reg [7:0] rcnt;
reg [7:0] hcnt;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rcnt <= 0;
		hcnt <= 0;
	end else begin
		if (req) begin 
			if (rcnt < 31) begin
				rcnt <= rcnt + 1'b1;
			end else begin
				rcnt <= 0;
				if (hcnt < 31) begin
					hcnt <= hcnt + 1'b1;
				end else begin
					hcnt <= 0;
				end
			end
		end else begin
			rcnt <= rcnt;
			hcnt <= hcnt;
		end
	end
end

always @(posedge clk) begin
	if (req) begin
		dat <= data[hcnt*32+rcnt];
		valid <= 1'b1;
	end else begin
		dat <= 0;
		valid <= 1'b0;
	end
end
	

endmodule
