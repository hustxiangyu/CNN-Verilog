`timescale 1ns / 1ns
module dark_channel(
        input           clk,             //cmos 像素时钟
        input           rst_n,  
        //处理前数据
        input           per_frame_vsync, 
        input           per_frame_href,  
        input   [23:0]  per_img,       
        //处理后的数据
        output  reg         post_frame_vsync    , 
        output  reg         post_frame_href     ,  
        output  reg [7 :0]  post_img  
    );


wire            src_min_frame_vsync         ;
wire            src_min_frame_href          ; 
wire    [7 :0]  src_min_img                 ; 

wire            src_block_min_frame_vsync   ;
wire            src_block_min_frame_href    ; 
wire    [7 :0]  src_block_min_img           ; 

src_min    src_min(                                                             
        . clk                 (clk),                                            
        . rst_n               (rst_n),                                          
                                                                                
        . per_frame_vsync     (per_frame_vsync),                                
        . per_frame_href      (per_frame_href),                                 
        . per_img             (per_img),       
                                                                                
        . post_frame_vsync    (src_min_frame_vsync),                               
        . post_frame_href     (src_min_frame_href),                                
        . post_img            (src_min_img)                                      
    );                                  
search_block_min1  search_block_min1(                                         
        . clk                 (clk),                                                
        . rst_n               (rst_n),                                        
                                                                              
        . per_frame_vsync     (src_min_frame_vsync),                              
        . per_frame_href      (src_min_frame_href),                               
        . per_img             (src_min_img),                                  
                                                                              
        . post_frame_vsync    (src_block_min_frame_vsync),                             
        . post_frame_href     (src_block_min_frame_href),                              
        . post_img            (src_block_min_img   )                                    
);                                                                            
                                        
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
always@(*)begin                                                                               
	post_frame_vsync    <=   src_block_min_frame_vsync ;
	post_frame_href     <=   src_block_min_frame_href  ;
	post_img            <=   src_block_min_img         ;
end


endmodule