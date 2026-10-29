`timescale 1ns / 1ns
module search_block_min1(
        input           clk                 ,
        input           rst_n               ,  
     //处理前数据
        input           per_frame_vsync     , 
        input           per_frame_href      ,  
        input   [23:0]  per_img             ,       
     //处理前数据
        output  reg        post_frame_vsync    , 
        output  reg        post_frame_href     ,  
        output  reg[7 :0]  post_img            
);

reg                     post_frame_vsync_d1 ;
reg                     post_frame_href_d1  ;
reg                     post_frame_vsync_d2 ;
reg                     post_frame_href_d2  ;
wire                    matrix_frame_vsync  ;
wire                    matrix_frame_href   ;
wire        [7 : 0]     matrix_p11          ;
wire        [7 : 0]     matrix_p12          ;
wire        [7 : 0]     matrix_p13          ;
wire        [7 : 0]     matrix_p21          ;
wire        [7 : 0]     matrix_p22          ;
wire        [7 : 0]     matrix_p23          ;
wire        [7 : 0]     matrix_p31          ;
wire        [7 : 0]     matrix_p32          ;
wire        [7 : 0]     matrix_p33          ;
wire        [7 : 0]     max_data            ;
wire        [7 : 0]     mid_data            ;
wire        [7 : 0]     min_data            ;
wire        [7 : 0]     max_data_0          ;
wire        [7 : 0]     mid_data_0          ;
wire        [7 : 0]     min_data_0          ;
wire        [7 : 0]     max_data_1          ;
wire        [7 : 0]     mid_data_1          ;
wire        [7 : 0]     min_data_1          ;
wire        [7 : 0]     max_data_2          ;
wire        [7 : 0]     mid_data_2          ;
wire        [7 : 0]     min_data_2          ;

Matrix_Generate_3X3_8Bit
#(
     .IMG_HDISP (800),            //  640*480
     .IMG_VDISP (480),
     .DELAY_NUM (20)             //  Interval period from the penultimate row to the last row
)
u_vip_matrix_generate_3x3_8bit
(
    //  global clock & reset
    .   clk                     (clk),
    .   rst_n                   (rst_n),
    
    //  Image data prepared to be processed
    .   per_img_vsync           (per_frame_vsync),   //  Prepared Image data vsync valid signal
    .   per_img_href            (per_frame_href),   //  Prepared Image data href vaild  signal
    .   per_img_gray            (per_img),   //  Prepared Image brightness input
    .   matrix_img_vsync        (matrix_frame_vsync),   //  processed Image data vsync valid signal
    .   matrix_img_href         (matrix_frame_href),   //  processed Image data href vaild  signal
    .   matrix_top_edge_flag    (),   //  processed Image top edge
    .   matrix_bottom_edge_flag (),   //  processed Image bottom edge
    .   matrix_left_edge_flag   (),   //  processed Image left edge
    .   matrix_right_edge_flag  (),   //  processed Image right edge
    .   matrix_p11              (matrix_p11),   //  3X3 Matrix output
    .   matrix_p12              (matrix_p12),
    .   matrix_p13              (matrix_p13),
    .   matrix_p21              (matrix_p21),
    .   matrix_p22              (matrix_p22),
    .   matrix_p23              (matrix_p23),
    .   matrix_p31              (matrix_p31),  
    .   matrix_p32              (matrix_p32),
    .   matrix_p33              (matrix_p33)
);

sort3 u_sort3_0(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (matrix_p11     ), 
    .data2      (matrix_p12     ), 
    .data3      (matrix_p13     ),
    .max_data   (max_data_0     ), 
    .mid_data   (mid_data_0     ), 
    .min_data   (min_data_0     )
);

sort3 u_sort3_1(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (matrix_p21     ), 
    .data2      (matrix_p22     ), 
    .data3      (matrix_p23     ),
    .max_data   (max_data_1     ), 
    .mid_data   (mid_data_1     ), 
    .min_data   (min_data_1     )
);

sort3 u_sort3_2(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (matrix_p31     ), 
    .data2      (matrix_p32     ), 
    .data3      (matrix_p33     ),  
    .max_data   (max_data_2     ), 
    .mid_data   (mid_data_2     ), 
    .min_data   (min_data_2     )
);


sort3 u_sort3_3(
    .clk        (clk            ),
    .rst_n      (rst_n          ),
    .data1      (min_data_0     ), 
    .data2      (min_data_1     ), 
    .data3      (min_data_2     ),
    .max_data   (max_data       ), 
    .mid_data   (mid_data       ), 
    .min_data   (min_data       )
);

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        post_frame_vsync_d1     <=      0                   ;
        post_frame_href_d1      <=      0                   ;
        post_frame_vsync_d2     <=      0                   ;
        post_frame_href_d2      <=      0                   ;
 
    end
    else begin
        post_frame_vsync_d1     <=      matrix_frame_vsync  ;
        post_frame_href_d1      <=      matrix_frame_href   ;
        post_frame_vsync_d2     <=      post_frame_vsync_d1 ;
        post_frame_href_d2      <=      post_frame_href_d1  ;
 
    end
end
always@(*)begin
	post_frame_vsync    <=       post_frame_vsync_d2 ;
	post_frame_href     <=       post_frame_href_d2  ;
	post_img            <=       min_data            ;
end 
endmodule



















