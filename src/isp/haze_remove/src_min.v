`timescale 1ns / 1ns
//求最小值
module src_min(
        input           clk                 ,
        input           rst_n               ,  
     //处理前数据
        input           per_frame_vsync     , 
        input           per_frame_href      ,  
        input   [23:0]  per_img             ,       
     //处理后数据
        output  reg        post_frame_vsync    , 
        output  reg        post_frame_href     ,  
        output  reg[7 :0]  post_img  
    );

reg                 per_frame_vsync_d1; 
reg                 per_frame_href_d1;
reg     [7 : 0]     pixel_min_of_rgb;
reg    [7 : 0]     pixel_of_r;
reg    [7 : 0]     pixel_of_g;
reg    [7 : 0]     pixel_of_b;
reg    [7 : 0]     pixel_min_of_rgb_1st;
reg    [7 : 0]     pixel_min_of_rgb_2st;

always@(*)begin
	pixel_of_r  <=   per_img[23 : 16];
	pixel_of_g  <=   per_img[15 :  8];
	pixel_of_b  <=   per_img[ 7 :  0];
end

always@(*)begin
	if(pixel_of_r > pixel_of_g)begin
		pixel_min_of_rgb_1st    <=   pixel_of_g;
	end else begin
		pixel_min_of_rgb_1st    <=   pixel_of_r;
	end
end
always@(*)begin
	if(pixel_of_r > pixel_of_g)begin
		pixel_min_of_rgb_2st    <=   pixel_min_of_rgb_1st;
	end else begin
		pixel_min_of_rgb_2st    <=   pixel_of_b;
	end
end



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        pixel_min_of_rgb    <=  0;
    end
    else if(per_frame_href )begin
        pixel_min_of_rgb    <=  pixel_min_of_rgb_2st;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        per_frame_vsync_d1      <=  0;
        per_frame_href_d1       <=  0;
    end
    else begin
        per_frame_vsync_d1      <=  per_frame_vsync;
        per_frame_href_d1       <=  per_frame_href;
    end
end
always@(*)begin
	post_frame_vsync    <=   per_frame_vsync_d1;
	post_frame_href     <=   per_frame_href_d1 ;
	post_img            <=   pixel_min_of_rgb;
end

endmodule
