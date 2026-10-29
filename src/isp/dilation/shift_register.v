/* Shift Register based on Simple Dual-Port RAM */
module shift_register
#(
	parameter BITS = 16,     //数据位宽
	parameter WIDTH = 1920,  //最大数据深度
	parameter LINES = 2      //FIFO个数
)
(
	input                clock,     //时钟信号
	input                clken,     //时钟有效
	input  [BITS-1:0]    shiftin,   //移位寄存器串行输入
	output [BITS-1:0]    shiftout,  //移位寄存器串行输出
	output [BITS*LINES-1:0] tapsx   //移位寄存器并行输出
);

	localparam RAM_SZ = WIDTH - 1;          //深度最大索引
	localparam RAM_AW = clogb2(RAM_SZ);     //深度索引的最大位长

	reg [RAM_AW-1:0] pos_r;                 //索引指针，会从0计数到RAM_SZ，而非(RAM_ZS-1)
	wire [RAM_AW-1:0] pos = (pos_r < RAM_SZ) ? pos_r : (RAM_SZ[RAM_AW-1:0] - 1'b1);   //索引指针的防溢出修正
	always @ (posedge clock) begin
		if (clken) begin
			if (pos_r < RAM_SZ - 2)
				pos_r <= pos_r + 1'b1;
			else
				pos_r <= 0;
		end
	end

	reg [BITS-1:0] in_r;            //串行输入数据打一拍
	always @ (posedge clock) begin
		if (clken) begin
			in_r <= shiftin;
		end
	end
	wire [BITS-1:0] line_out[LINES-1:0];    //并行输出的前一形式
	generate
		genvar i;
		for (i = 0; i < LINES; i = i + 1) begin : gen_ram_inst
            /*********************************************************************
                simple_dp_ram#(
                    .DW(BITS),         `//位宽
                    .AW(RAM_AW),        //最大深度位长
                    .SZ(RAM_SZ)         //最大深度
                )         
                u_ram(
                    .clk   (clock                         ),      //时钟信号
                    .wren  (clken                         ),      //写使能
                    .wraddr(pos                           ),      //写地址
                    .data  ((i > 0 ? line_out[i-1] : in_r)),      //写数据
                    .rden  (clken                         ),      //读使能
                    .rdaddr(pos                           ),      //读地址
                    .q     (line_out[i]                   )       //读数据
                    );
            **********************************************************************/
			simple_dp_ram #(BITS, RAM_AW, RAM_SZ) u_ram(clock, clken, pos, (i > 0 ? line_out[i-1] : in_r), clken, pos, line_out[i]);
		end
	endgenerate

	assign shiftout = line_out[LINES-1];
	generate
		genvar j;
		for (j = 0; j < LINES; j = j + 1) begin : gen_taps_assign
			assign tapsx[(BITS*j)+:BITS] = line_out[j];
		end
	endgenerate
    
    //函数：计算以2为底的对数
	function integer clogb2;
	input integer depth;
	begin
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	end
	endfunction
endmodule
