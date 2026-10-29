`timescale 1 ps/ 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02-27-2025 22:04:43
// Design Name:
// Module Name: pool
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


module pool#(
    parameter BITWIDTH 		= 10				,   
	parameter BITWIDTH_OUT  = 10				,                            
    parameter height 		= 8					,                                 
    parameter width 		= 10				,                                 
    parameter cnt_data 		= height * width  

)(
    input wire clk										,
    input wire rst_n									,
    input wire w_en										,                                         
    input wire  signed [BITWIDTH_OUT-1:0] 	  data_in		,               
    output reg  signed [BITWIDTH_OUT-1:0] data_out_pool	,         
    output reg           				  o_en_pool                               
);

reg signed [BITWIDTH_OUT-1'b1:0] data1[0:width-1'b1];            
reg signed [BITWIDTH_OUT-1'b1:0] data2[0:1];                     
reg [1:0] state;                                             
localparam FREE  = 2'b00;                                    
localparam READY = 2'b01;                                    
localparam START = 2'b10;                                    

//状态机控制
reg [8:0] r_cnt;//列计数器
reg [7:0] h_cnt;//行计数器

reg en_r;//此处打拍是为了让数据和计数对齐
//cnt controller
always @(posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        r_cnt <= 1'b0;
        h_cnt <= 1'b0;
    end else begin
    	if (en_r) begin
        	if (r_cnt < width - 1) begin
        		r_cnt <= r_cnt + 1'b1;
        	end else begin
        		if (h_cnt < height - 1) begin
    				r_cnt <= 1'b0;
        			h_cnt <= h_cnt + 1'b1;
    			end else begin
    				h_cnt <= 1'b0;
        			r_cnt <= 1'b0;
   				end
            end
        end
    end
end



always @(posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
    	en_r <= 1'b0;
    end else begin
    	en_r <= w_en;
    end
end

//state machine
always @(posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
        state <= FREE;
        o_en_pool  <= 1'b0;
        data_out_pool <= 1'b0;
    end else begin
        case (state)
            FREE: begin
                if (w_en == 1'b1) begin
                    state <= START;  
                end
            end
            START: begin
                if (r_cnt == 1'b0 && h_cnt == 1'b0 && !w_en) begin
                    state <= FREE;  
                    o_en_pool<=1'b0;
                end else begin                 
                    if (h_cnt[0] == 1'b1) begin
                        if (r_cnt[0] == 1'b1 && en_r) begin
                            data_out_pool <= data1[0]>data1[1]?(data2[0]>data2[1]?(data1[0]>data2[0]?data1[0]:data2[0]):(data1[0]>data2[1]?data1[0]:data2[1])):(data2[0]>data2[1]?(data1[1]>data2[0]?data1[1]:data2[0]):(data1[1]>data2[1]?data1[1]:data2[1]));
                            o_en_pool <= 1'b1; 
                        end else begin 
							o_en_pool <= 1'b0;
						end
                    end else begin
							o_en_pool <= 1'b0;
                    end
                end
            end
        endcase
    end
end



//data movement
integer j;
always @(posedge clk or negedge rst_n ) begin
	if(!rst_n)begin
		data2[1] <= 1'b0;
	end else if (w_en == 1'b1) begin
        for (j = 0; j < width - 1; j = j + 1) begin
            data1[j] <= data1[j + 1];
        end
        data1[width-1] <= data2[0];
        data2[0]       <= data2[1];
        data2[1]       <= data_in;
    end
end



endmodule
