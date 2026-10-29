`timescale 1ns / 1ns
module tx_get(
        input               clk                 ,
        input               rst_n               ,  
        //处理前数据
        input               per_frame_vsync     , 
        input               per_frame_href      ,   
        input   [7  : 0]    per_img             ,
        input   [7  : 0]    A_value             ,
        //处理后的数据
        output reg             post_frame_vsync    , 
        output reg             post_frame_href     ,  
        output reg [7  : 0]    post_img  
);

parameter modification_value = 8'd243;    //modification_value=0.95*2^8,

reg         [15 : 0]    modify_A            ;

reg                     per_frame_vsync_d1  ;
reg                     per_frame_href_d1   ;
reg         [7  : 0]    A_value_d1          ;

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        modify_A    <=  0;
    end
    else begin
        modify_A    <=  (per_img << 8) - per_img - (per_img << 2) - (per_img << 3); //per_img * modification_value
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        per_frame_vsync_d1      <=  0                   ;
        per_frame_href_d1       <=  0                   ;
        A_value_d1              <=  0                   ;
    end
    else begin
        per_frame_vsync_d1      <=  per_frame_vsync     ;
        per_frame_href_d1       <=  per_frame_href      ;
        A_value_d1              <=  A_value             ;
    end
end

always@(*)begin
	post_frame_vsync    <=   per_frame_vsync_d1  ;
	post_frame_href     <=   per_frame_href_d1   ;
	post_img            <=   8'd255  -   modify_A / A_value_d1;
end
endmodule
