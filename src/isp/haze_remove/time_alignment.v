`timescale 1ns / 1ns
module time_alignment(
        input               clk                     ,
        input               rst_n                   ,  
        //处理前数据
        input               per_src_frame_vsync     , 
        input               per_src_frame_href      ,  
        input   [23 : 0]    per_img                 ,

        input               per_tx_frame_vsync      ,
        input               per_tx_frame_href       ,
        input   [7  : 0]    per_tx_img              ,

        input   [7  : 0]    per_A                   ,
        //处理后的数据
        output reg             post_src_frame_vsync    , 
        output reg             post_src_frame_href     ,  
        output reg [23 : 0]    post_img                ,
              
        output reg             post_tx_frame_vsync     ,
        output reg             post_tx_frame_href      ,
        output reg [7  : 0]    post_tx_img             ,
               
        output reg [7  : 0]    post_A                   
);
integer i;

parameter src_delay = 6;

reg                         per_src_frame_vsync_d[src_delay - 1 : 0]    ;
reg                         per_src_frame_href_d[src_delay - 1 : 0]     ;
reg     [23 : 0]            per_img_d[src_delay - 1 : 0]                ;

//src_delay
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        for(i = 0; i< src_delay; i = i + 1)begin
            per_src_frame_vsync_d   [ i ]   <=    0;
            per_src_frame_href_d    [ i ]   <=    0;
            per_img_d               [ i ]   <=    0;
        end
    end
    else begin
        per_src_frame_vsync_d   [ 0 ]          <=    per_src_frame_vsync               ;
        per_src_frame_href_d    [ 0 ]          <=    per_src_frame_href                ;
        per_img_d               [ 0 ]          <=    per_img                           ;
        for(i = 1; i< src_delay; i = i + 1)begin
            per_src_frame_vsync_d   [ i ]      <=    per_src_frame_vsync_d  [ i - 1 ]  ;
            per_src_frame_href_d    [ i ]      <=    per_src_frame_href_d   [ i - 1 ]  ;
            per_img_d               [ i ]      <=    per_img_d              [ i - 1 ]  ;
        end
    end
end

always@(*)begin
	post_src_frame_vsync    <=   per_src_frame_vsync_d   [ src_delay - 1 ]   ;
	post_src_frame_href     <=   per_src_frame_href_d    [ src_delay - 1 ]   ; 
	post_img                <=   per_img_d               [ src_delay - 1 ]   ;            
	post_tx_frame_vsync     <=   per_tx_frame_vsync      ;
	post_tx_frame_href      <=   per_tx_frame_href       ;
	post_tx_img             <=   per_tx_img              ;
	post_A                  <=   per_A;
end

endmodule
