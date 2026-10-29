`timescale 1ns / 1ns
module calculate_A(
        input           clk                 ,
        input           rst_n               ,  
        //处理前数据
        input           per_frame_vsync     , 
        input           per_frame_href      ,  
 
        input   [23:0]  per_img             ,       
        //处理后的数据
        output  reg        post_frame_vsync    , 
        output  reg        post_frame_href     ,  
               
        output  reg[7 :0]  post_result         , 
        output  reg        post_done
);

reg     [7 : 0]     A_value                 ;
reg     [7 : 0]     A_value_out             ;
reg                 A_value_valid           ;

reg                 per_frame_vsync_d1      ; 
reg                 per_frame_href_d1       ;  
 
reg    [7 : 0]     pixel_of_r;
reg    [7 : 0]     pixel_of_g;
reg    [7 : 0]     pixel_of_b;
reg    [7 : 0]     pixel_max_of_rgb_1st;
reg    [7 : 0]     pixel_max_of_rgb_2st;
always@(*)begin
	   pixel_of_r  <=   per_img[23 : 16];
	   pixel_of_g  <=   per_img[15 :  8];
	   pixel_of_b  <=   per_img[ 7 :  0];
end

always@(*)begin
	if(pixel_of_r > pixel_of_g)
	 	 pixel_max_of_rgb_1st    <= pixel_of_r; 
	else 
		pixel_max_of_rgb_1st<=pixel_of_g;
end
always@(*)begin
	if(pixel_of_b > pixel_max_of_rgb_1st)
	 	 pixel_max_of_rgb_2st    <= pixel_of_b; 
	else 
		pixel_max_of_rgb_2st<=pixel_max_of_rgb_1st;
end



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value <=  0;
    end
    else if(per_frame_href ) begin
        A_value <=  A_value > pixel_max_of_rgb_2st ? A_value : pixel_max_of_rgb_2st;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        per_frame_vsync_d1      <=  0               ;
        per_frame_href_d1       <=  0               ;
    end
    else begin
        per_frame_vsync_d1      <=  per_frame_vsync ;
        per_frame_href_d1       <=  per_frame_href  ;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value_out <=  8'd230;
    end
    else if(per_frame_vsync_d1 & !per_frame_vsync)begin
        A_value_out <=  A_value;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        A_value_valid   <=  0;
    end
    else if(per_frame_vsync_d1 & !per_frame_vsync)begin
        A_value_valid   <=  1;
    end
    else begin
        A_value_valid   <=  0;
    end
end


always@(*)begin
 	post_frame_vsync    <=   per_frame_vsync_d1  ;
 	post_frame_href     <=   per_frame_href_d1   ;
 	post_result         <=   A_value_out         ;
 	post_done           <=   A_value_valid       ;
end
endmodule