`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03-05-2025 19:34:20
// Design Name:
// Module Name: fc
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



module fc#(
	parameter BITWIDTH	 = 11	,
    parameter WEIGHT_NUM = 9 	,			//һ��pool�������������
    parameter CLASEE_NUM = 3    ,
    parameter BIAS_NUM 	 = 10 	
)
( 
	input clk									,
	input rst_n									,
	input en1									,
	input en2									,
	input en3									,                   
	input signed [BITWIDTH-1:0] data_in_1		,
	input signed [BITWIDTH-1:0] data_in_2		,
	input signed [BITWIDTH-1:0] data_in_3		,
	output reg signed [35:0] calc_out1,
	output reg signed [35:0] calc_out2,
	output reg signed [35:0] calc_out3,
	output reg signed [35:0] calc_out4,
	output reg signed [35:0] calc_out5,
	output reg signed [35:0] calc_out6,
	output reg signed [35:0] calc_out7,
	output reg signed [35:0] calc_out8,
	output reg signed [35:0] calc_out9,
	output reg signed [35:0] calc_out10,			 
	output reg output_en_fc					,
	output reg signed [35:0] max,
	output wire compare_flag_fc	,
	output reg [3:0] result

);
//=====================
reg [9:0]weight_cnt;    //0-199

//===============
reg signed [8:0] weight1  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight2  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight3  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight4  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight5  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight6  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight7  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight8  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight9  [0:WEIGHT_NUM*CLASEE_NUM-1];
reg signed [8:0] weight10 [0:WEIGHT_NUM*CLASEE_NUM-1];

reg signed [8:0] bias [0:BIAS_NUM-1];
//reg signed [21:0] calc_out1;
//reg signed [21:0] calc_out2;
//reg signed [21:0] calc_out3;
//reg signed [21:0] calc_out4;
reg compare_flag;
assign compare_flag_fc = compare_flag;
 initial begin                                               
   $readmemb("parameter/weight41.txt", weight1); 
   $readmemb("parameter/weight42.txt", weight2); 
   $readmemb("parameter/weight43.txt", weight3); 
   $readmemb("parameter/weight44.txt", weight4);   
   $readmemb("parameter/weight45.txt", weight5);   
   $readmemb("parameter/weight46.txt", weight6);   
   $readmemb("parameter/weight47.txt", weight7);   
   $readmemb("parameter/weight48.txt", weight8);   
   $readmemb("parameter/weight49.txt", weight9);   
   $readmemb("parameter/weight40.txt", weight10);   
   $readmemb("parameter/bias.txt", bias);
 end
 reg compare_flag_1;
 reg compare_flag_2;


 always @(posedge clk) begin
     compare_flag_1 <= compare_flag;
 end
 always @(posedge clk) begin
     compare_flag_2 <= compare_flag_1;
 end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        weight_cnt <= 1'b0;
        calc_out1  <= 1'b0;
        calc_out2  <= 1'b0;
        calc_out3  <= 1'b0;
        calc_out4  <= 1'b0;
        calc_out5  <= 1'b0;
        calc_out6  <= 1'b0;
        calc_out7  <= 1'b0;
        calc_out8  <= 1'b0;
        calc_out9  <= 1'b0;
        calc_out10 <= 1'b0;
        compare_flag <= 1'b0;
        output_en_fc <= 1'b0;
		result <= 4'b0;
		max <= 1'b0;
    end else if(en1 == 1'b1 && en2 == 1'b1 && en3 == 1'b1 && compare_flag == 1'b0) begin  // ȷ�� compare_flag ��ʱ���м���
        if(weight_cnt == WEIGHT_NUM -1) begin
            weight_cnt <= 1'b0;
            compare_flag <= 1'b1;
        end else begin
            weight_cnt <= weight_cnt + 1'b1;
        end
			output_en_fc <= 1'b0;
			calc_out1 <= calc_out1  + data_in_1 * weight1[weight_cnt]
                                  	+ data_in_2 * weight1[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight1[WEIGHT_NUM * 2 + weight_cnt];
            calc_out2 <= calc_out2  + data_in_1 * weight2[weight_cnt]
                                  	+ data_in_2 * weight2[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight2[WEIGHT_NUM * 2 + weight_cnt];
            calc_out3 <= calc_out3  + data_in_1 * weight3[weight_cnt]
                                  	+ data_in_2 * weight3[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight3[WEIGHT_NUM * 2 + weight_cnt];
            calc_out4 <= calc_out4  + data_in_1 * weight4[weight_cnt]
                                  	+ data_in_2 * weight4[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight4[WEIGHT_NUM * 2 + weight_cnt];
            calc_out5 <= calc_out5  + data_in_1 * weight5[weight_cnt]
                                  	+ data_in_2 * weight5[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight5[WEIGHT_NUM * 2 + weight_cnt];
            calc_out6 <= calc_out6  + data_in_1 * weight6[weight_cnt]
                                  	+ data_in_2 * weight6[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight6[WEIGHT_NUM * 2 + weight_cnt];
            calc_out7 <= calc_out7  + data_in_1 * weight7[weight_cnt]
                                  	+ data_in_2 * weight7[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight7[WEIGHT_NUM * 2 + weight_cnt];
            calc_out8 <= calc_out8  + data_in_1 * weight8[weight_cnt]
                                  	+ data_in_2 * weight8[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight8[WEIGHT_NUM * 2 + weight_cnt];
            calc_out9 <= calc_out9  + data_in_1 * weight9[weight_cnt]
                                  	+ data_in_2 * weight9[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight9[WEIGHT_NUM * 2 + weight_cnt];
            calc_out10 <= calc_out10 + data_in_1 * weight10[weight_cnt]
                                  	+ data_in_2 * weight10[WEIGHT_NUM + weight_cnt]
                                  	+ data_in_3 * weight10[WEIGHT_NUM * 2 + weight_cnt];
    end else if(compare_flag)begin
			output_en_fc <= 1'b0;
		    calc_out1 <= calc_out1 + bias[0];
            calc_out2 <= calc_out2 + bias[1];
            calc_out3 <= calc_out3 + bias[2];
			calc_out4 <= calc_out4 + bias[3];
			calc_out5 <= calc_out5 + bias[4];
			calc_out6 <= calc_out6 + bias[5];
			calc_out7 <= calc_out7 + bias[6];
			calc_out8 <= calc_out8 + bias[7];
			calc_out9 <= calc_out9 + bias[8];
			calc_out10 <= calc_out10 + bias[9];
			compare_flag <= 1'b0;
	end else if (compare_flag_1) begin
		output_en_fc <= 1'b0;
		max = calc_out1;
		result = 4'd1;
		if (max < calc_out2) begin
			max = calc_out2;
			result = 4'd10;
		end
		if (max < calc_out3) begin
			max = calc_out3;
			result = 4'd2;
		end
		if (max < calc_out4) begin
			max = calc_out4;
			result = 4'd3;
		end
		if (max < calc_out5) begin
			max = calc_out5;
			result = 4'd4;
		end
		if (max < calc_out6) begin
			max = calc_out6;
			result = 4'd5;
		end
		if (max < calc_out7) begin
			max = calc_out7;
			result = 4'd6;
		end
		if (max < calc_out8) begin
			max = calc_out8;
			result = 4'd7;
		end
		if (max < calc_out9) begin
			max = calc_out9;
			result = 4'd8;
		end
		if (max < calc_out10) begin
			max = calc_out10;
			result = 4'd9;
		end
//      calc_out1 = calc_out1 > calc_out2 ? calc_out1 : calc_out2;
//		calc_out3 = calc_out3 > calc_out4 ? calc_out3 : calc_out4;
//		calc_out5 = calc_out5 > calc_out6 ? calc_out5 : calc_out6;
//		calc_out7 = calc_out7 > calc_out8 ? calc_out7 : calc_out8;
//		calc_out9 = calc_out9 > calc_out10? calc_out9 : calc_out10;
//		
//		calc_out1 = calc_out1 > calc_out3 ? calc_out1 : calc_out3;
//		calc_out5 = calc_out5 > calc_out7 ? calc_out5 : calc_out7;
//		
//		calc_out1 = calc_out1 > calc_out5 ? calc_out1 : calc_out5;
//		calc_out1 = calc_out1 > calc_out9 ? calc_out1 : calc_out9;
    end else if (compare_flag_2) begin
        output_en_fc <= 1'b1;
		max <= max;
		result <= result;
        calc_out1 <= 1'b0;
        calc_out2 <= 1'b0;
        calc_out3 <= 1'b0;
        calc_out4  <= 1'b0;
        calc_out5  <= 1'b0;
        calc_out6  <= 1'b0;
        calc_out7  <= 1'b0;
        calc_out8  <= 1'b0;
        calc_out9  <= 1'b0;
        calc_out10 <= 1'b0;
    end else begin
		output_en_fc <= 1'b0;
		max <= max;
		result <= result;
	end
end




endmodule

