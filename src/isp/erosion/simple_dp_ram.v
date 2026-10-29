/* Simple Dual-Port RAM */
module simple_dp_ram
#(
	parameter DW = 8,
	parameter AW = 4,
	parameter SZ = 2**AW
)
(
	input          clk,
	input          wren,
	input [AW-1:0] wraddr,
	input [DW-1:0] data,
	input          rden,
	input [AW-1:0] rdaddr,
	output reg [DW-1:0] q
);

	reg [DW-1:0] mem [SZ-1:0];
	always @ (posedge clk) begin
		if (wren) begin
			mem[wraddr] <= data;
		end
	end
	always @ (posedge clk) begin
		if (rden) begin
			q <= mem[rdaddr];
		end
	end
endmodule