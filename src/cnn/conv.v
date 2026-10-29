`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02-24-2025 18:18:20
// Design Name:
// Module Name: conv
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


module conv #( 
    parameter BITWIDTH = 9,              //输入数据位宽
    parameter BITWIDTH_OUT   = 11				,  
	parameter PAD = 1,
    parameter stride = 1,                //步长
    parameter width = 28,                //图片的宽度
    parameter height = 28,               //图片的高度
    parameter cnt_data = width * height,   //图像像素点的个数
    parameter CORE = 1							    //第几个卷积核，根绝不同的卷积核切换不同的weight
)(
    input wire clk,
    input wire rst_n,
    input wire signed [BITWIDTH-1:0] data_in,
    input wire w_en,                     // 数据输入使能
    
    output reg signed  [BITWIDTH_OUT-1:0] data_out_conv,
    output reg o_en_conv ,                //传输给relu层，为1表示正在进行卷积运算有数据输出，且为有效数据，可以作为relu模块的使能端口
    output reg finish                    //为1表明完成一帧图片的计算
);

wire signed [BITWIDTH-1:0] data1 [0:2];//实际使用
wire signed [BITWIDTH-1:0] data2 [0:2];//实际使用
wire signed [BITWIDTH-1:0] data3 [0:2];//实际使用
reg [1:0] state;                     // 状态机
reg signed [BITWIDTH+12:0] conv_result;       // 卷积运算结果
reg signed [BITWIDTH-1:0] s_data_in;
reg o_en;
reg flag;
localparam FREE  = 2'b00; // 空闲状态
localparam START = 2'b10; // 卷积运算状态

reg [8:0] r_cnt;//列计数器 //实际使用
reg [7:0] h_cnt;//行计数器 //实际使用

reg i_de; //实际使用
reg i_en;
wire o_de;
wire frame_start;
wire ready;

reg [8:0] r_cnt_r; //实际使用
reg [7:0] h_cnt_r; //实际使用

reg signed [8:0] weight_conv [0:8];
//reg signed [8:0] weight_conv1 [0:8];  

wire signed [BITWIDTH + 8:0] mult_result [0:8];

reg pad_valid;

assign ready = h_cnt_r >= 2;
assign frame_start = (h_cnt >= height) || (h_cnt == height-1 && r_cnt == width-1);
     
/*always@(posedge clk)begin
		weight_conv1[0]<=1; weight_conv1[1]<=1; weight_conv1[2]<=1;
        weight_conv1[3]<=1; weight_conv1[4]<=0; weight_conv1[5]<=1;
        weight_conv1[6]<=1; weight_conv1[7]<=1; weight_conv1[8]<=1;
end   */
/*
initial begin
		weight_conv1[0]<=1; weight_conv1[1]<=1; weight_conv1[2]<=1;
        weight_conv1[3]<=1; weight_conv1[4]<=0; weight_conv1[5]<=1;
        weight_conv1[6]<=1; weight_conv1[7]<=1; weight_conv1[8]<=1;
end  */
 
initial begin
	case(CORE)                                              
   		6'd1: $readmemb("parameter/weight1.txt", weight_conv); 
   		6'd2: $readmemb("parameter/weight2.txt", weight_conv); 
   		6'd3: $readmemb("parameter/weight3.txt", weight_conv); /*
   		6'd4: $readmemb("parameter/weight4.txt", weight_conv); 
   		6'd5: $readmemb("parameter/weight5.txt", weight_conv); 
   		6'd6: $readmemb("parameter/weight6.txt", weight_conv); 
   		6'd7: $readmemb("parameter/weight7.txt", weight_conv); 
   		6'd8: $readmemb("parameter/weight8.txt", weight_conv); 
   		6'd9: $readmemb("parameter/weight9.txt", weight_conv); 
   		6'd10:$readmemb("parameter/weight10.txt", weight_conv); */
   		6'd11:$readmemb("parameter/weight11.txt", weight_conv); 
   		6'd12:$readmemb("parameter/weight12.txt", weight_conv); 
   		6'd13:$readmemb("parameter/weight13.txt", weight_conv); 
   		6'd14:$readmemb("parameter/weight14.txt", weight_conv); 
   		6'd15:$readmemb("parameter/weight15.txt", weight_conv); 
   		6'd16:$readmemb("parameter/weight16.txt", weight_conv); 
   		6'd17:$readmemb("parameter/weight17.txt", weight_conv); 
   		6'd18:$readmemb("parameter/weight18.txt", weight_conv); 
   		6'd19:$readmemb("parameter/weight19.txt", weight_conv); /*
   		6'd20:$readmemb("parameter/weight20.txt", weight_conv); 
   		6'd21:$readmemb("parameter/weight21.txt", weight_conv); 
   		6'd22:$readmemb("parameter/weight22.txt", weight_conv); 
   		6'd23:$readmemb("parameter/weight23.txt", weight_conv); 
   		6'd24:$readmemb("parameter/weight24.txt", weight_conv); 
   		6'd25:$readmemb("parameter/weight25.txt", weight_conv); 
   		6'd26:$readmemb("parameter/weight26.txt", weight_conv); 
   		6'd27:$readmemb("parameter/weight27.txt", weight_conv); 
   		6'd28:$readmemb("parameter/weight28.txt", weight_conv); 
   		6'd29:$readmemb("parameter/weight29.txt", weight_conv); 
   		6'd30:$readmemb("parameter/weight30.txt", weight_conv); 
   		6'd31:$readmemb("parameter/weight31.txt", weight_conv); 
   		6'd32:$readmemb("parameter/weight32.txt", weight_conv); 
   		6'd33:$readmemb("parameter/weight33.txt", weight_conv); 
   		6'd32:$readmemb("parameter/weight32.txt", weight_conv); 
   		6'd35:$readmemb("parameter/weight35.txt", weight_conv); 
   		6'd36:$readmemb("parameter/weight36.txt", weight_conv);   */  
	endcase  
end

//singal pause
always @(posedge clk) begin
	if(w_en) begin
    	i_de <= 1'b1;
        s_data_in <= data_in;
    end else if (frame_start) begin
    	i_de <= 1'b1;
        s_data_in <= 1'b0;
    end else begin 
    	i_de <= 1'b0;
        s_data_in <= 1'b0;
    end
end

//singal pause
always @(posedge clk) begin
    finish <= flag;
end

//cnt_r controller
always @(posedge clk) begin
	if(!rst_n || finish) begin
    	r_cnt_r <= 1'b0;
    	h_cnt_r <= 1'b0;
    end else if (o_de) begin
    	if (r_cnt_r < width) begin
			if (r_cnt_r + 1 == width) begin
				r_cnt_r <= 0;
				h_cnt_r <= h_cnt_r + 1;
			end else begin
				r_cnt_r <= r_cnt_r + 1'b1;
			end
        end else if (h_cnt_r < height - 1) begin
        	r_cnt_r <= 1'b0;
            h_cnt_r <= h_cnt_r + 1'b1;
        end else begin 
        	r_cnt_r <= 1'b0;
            h_cnt_r <= 1'b0;
        end
	end else begin
		r_cnt_r <= r_cnt_r;
		h_cnt_r <= h_cnt_r;
	end
end

//stride controller
always @(posedge clk) begin
	if(!o_en) begin
    	o_en_conv <= o_en;
    	data_out_conv <= conv_result[BITWIDTH+12:BITWIDTH+12-BITWIDTH_OUT+1];
    end else begin
    	if (stride == 1) begin
			if (pad_valid) begin
				o_en_conv <= o_en;
				data_out_conv <= conv_result[BITWIDTH+12:BITWIDTH+12-BITWIDTH_OUT+1];
			end else begin
				o_en_conv <= 1'b0;
    		    data_out_conv <= 11'b0;
			end
        end else begin
        	if (!r_cnt_r[0] && !h_cnt_r[0]) begin
            	o_en_conv <= o_en;
    			data_out_conv <= conv_result[BITWIDTH+12:BITWIDTH+12-BITWIDTH_OUT+1];
            end else begin
            	o_en_conv <= 1'b0;
    		    data_out_conv <= 11'b0;
            end
        end
    end
end
        
//cnt controller
always @(posedge clk) begin
    if (!rst_n || finish) begin
        r_cnt <= 1'b0;
        h_cnt <= 1'b0;
    end else if (i_de) begin
		if (r_cnt < width) begin
			if (r_cnt + 1 == width) begin
				r_cnt <= 0;
				if (h_cnt < height + 2) begin
					if (h_cnt == height + 1) begin
						h_cnt <= 0;
					end else begin
						h_cnt <= h_cnt + 1;
					end
				end
			end else begin
				r_cnt <= r_cnt + 1'b1;
			end
		end
    end else begin
    	h_cnt <= h_cnt;
        r_cnt <= r_cnt;
   	end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= FREE;
        o_en<=1'b0;
		conv_result <= 1'b0;
    end else begin
        case (state)
            FREE: begin
                if (w_en == 1'b1) begin
                    state <= START; 
                end
            end
            START: begin
                if (o_de && !flag && ready) begin
                	conv_result <= ((data1[0] * weight_conv[0])) + 
                     	           ((data1[1] * weight_conv[1])) + 
                                   ((data1[2] * weight_conv[2])) +
                                   ((data2[0] * weight_conv[3])) + 
                                   ((data2[1] * weight_conv[4])) + 
                                   ((data2[2] * weight_conv[5])) +
                                   ((data3[0] * weight_conv[6])) + 
                                   ((data3[1] * weight_conv[7])) + 
                                   ((data3[2] * weight_conv[8]));
					/*conv_result <= mult_result[0] + mult_result[1] + mult_result[2] +
								   mult_result[3] + mult_result[4] + mult_result[5] + 
								   mult_result[6] + mult_result[7] + mult_result[8];*/
              		o_en<=1'b1; 
                end else begin
                    conv_result<=1'b0;
                    o_en<=1'b0;
                end
            end
        endcase
    end
end

//use ip instand of luts
/*
cnn_mult #(
	.DATAA_WIDTH (BITWIDTH),  // 输入位宽
    .DATAB_WIDTH (9),
    .RESULT_WIDTH(BITWIDTH + 9)
) mult (
	.dataa1 (data1[0]),
	.datab1 (weight_conv[0]),
	.result1(mult_result[0]),
	.dataa2 (data1[1]),
	.datab2 (weight_conv[1]),
	.result2(mult_result[1]),
	.dataa3 (data1[2]),
	.datab3 (weight_conv[2]),
	.result3(mult_result[2]),
	.dataa4 (data2[0]),
	.datab4 (weight_conv[3]),
	.result4(mult_result[3]),
	.dataa5 (data2[1]),
	.datab5 (weight_conv[4]),
	.result5(mult_result[4]),
	.dataa6 (data2[2]),
	.datab6 (weight_conv[5]),
	.result6(mult_result[5]),
	.dataa7 (data3[0]),
	.datab7 (weight_conv[6]),
	.result7(mult_result[6]),
	.dataa8 (data3[1]),
	.datab8 (weight_conv[7]),
	.result8(mult_result[7]),
	.dataa9 (data3[2]),
	.datab9 (weight_conv[8]),
	.result9(mult_result[8])
);*/

reg [15:0] cnt_total;      // 用于计数总数据
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_total <= 16'd0;
        flag<=1'b0;
    end else if (i_de) begin
        if (cnt_total == cnt_data + 2 * width) begin
            cnt_total <= 16'd0;
            flag<=1'b1;
        end else  begin
            cnt_total <= cnt_total + 16'd1;
            flag<=1'b0;
        end
    end else begin
        cnt_total <= cnt_total;
        flag <= 1'b0;
    end
end

Line_Reg #(
    .BITWIDTH(BITWIDTH),
    .WIDTH(width)
) u_reg (
    .clk(clk),
    .rst_n(rst_n),
    .din(s_data_in),
    .i_de(i_de),
    .p00(data1[0]),
    .p01(data1[1]),
    .p02(data1[2]),
    .p10(data2[0]),
    .p11(data2[1]),
    .p12(data2[2]),
    .p20(data3[0]),
    .p21(data3[1]),
    .p22(data3[2]),
    .o_de(o_de)
);

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		pad_valid <= PAD;
	end else begin
		if (PAD) begin
			pad_valid <= PAD;
		end else begin
			pad_valid <= !(h_cnt_r == 2 || r_cnt_r == width-1 || r_cnt_r == 0 || h_cnt_r == height+1);
		end
	end
end


endmodule

