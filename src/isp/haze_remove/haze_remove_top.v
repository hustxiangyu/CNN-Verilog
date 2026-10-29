 `timescale 1ns/1ns
 module haze_remove_top(
    input           clk                 ,
    input           rst_n               ,  
    
	input			switch				,
    input           per_frame_vsync     , 
    input           per_frame_href      ,  
    input   [23:0]  per_img,       
   
    output reg         post_frame_vsync    , 
    output reg         post_frame_href     ,  
    output reg [23:0]  post_img             
);

wire                 dark_channel_frame_vsync    ;
wire                 dark_channel_frame_href     ; 
wire    [7  : 0]     dark_channel_img            ; 
     
wire                 src_cal_A_frame_vsync       ;
wire                 src_cal_A_frame_href        ; 
wire    [7  : 0]     src_cal_A_result            ; 
wire                 src_cal_A_valid             ; 
     
wire                 src_tx_frame_vsync          ;
wire                 src_tx_frame_href           ; 
wire    [7  : 0]     src_tx_img                  ; 
     
wire                 cal_src_frame_vsync         ;
wire                 cal_src_frame_href          ;
wire    [23 : 0]     cal_img                     ;
wire                 cal_tx_frame_vsync          ;
wire                 cal_tx_frame_href           ;
wire    [7  : 0]     cal_tx_img                  ;
wire    [7  : 0]     cal_A                       ;

wire 			 post_frame_vsync1;
wire   			 post_frame_href1;
wire [23:0]      post_img1        ;

dark_channel u_dark_channel(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),  
        //处理前数据        
        .per_frame_vsync        (per_frame_vsync            ), 
        .per_frame_href         (per_frame_href             ),  
        .per_img                (per_img                    ),
        //处理后的数据      
        .post_frame_vsync       (dark_channel_frame_vsync   ), 
        .post_frame_href        (dark_channel_frame_href    ),  
        .post_img               (dark_channel_img           )
    );    

calculate_A u_calculate_A(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ),  
        //处理前数据    
        .per_frame_vsync        (per_frame_vsync            ), 
        .per_frame_href         (per_frame_href             ),  
        .per_img                (per_img                    ),       
        //处理后的数据  
        .post_frame_vsync       (src_cal_A_frame_vsync      ), 
        .post_frame_href        (src_cal_A_frame_href       ),  
        .post_result            (src_cal_A_result           ), 
        .post_done              (src_cal_A_valid            )
);

tx_get u_tx_get(
        .clk                    (clk                        ),
        .rst_n                  (rst_n                      ), 
        //处理前数据    
        .per_frame_vsync        (dark_channel_frame_vsync   ),
        .per_frame_href         (dark_channel_frame_href    ), 
        .per_img                (dark_channel_img           ),
        .A_value                (src_cal_A_result           ),
        //处理后的数据  
        .post_frame_vsync       (src_tx_frame_vsync         ),
        .post_frame_href        (src_tx_frame_href          ),
        .post_img               (src_tx_img                 )
);

time_alignment u_time_alignment(
        .clk                     (clk                       ),
        .rst_n                   (rst_n                     ),  
        //处理前数据
        .per_src_frame_vsync     (per_frame_vsync           ), 
        .per_src_frame_href      (per_frame_href            ),  
        .per_img                 (per_img                   ),

        .per_tx_frame_vsync      (src_tx_frame_vsync        ),
        .per_tx_frame_href       (src_tx_frame_href         ),
        .per_tx_img              (src_tx_img                ),

        .per_A                   (src_cal_A_result          ),
        //处理后的数据()
        .post_src_frame_vsync    (cal_src_frame_vsync       ), 
        .post_src_frame_href     (cal_src_frame_href        ),  
        .post_img                (cal_img                   ),

        .post_tx_frame_vsync     (cal_tx_frame_vsync        ),
        .post_tx_frame_href      (cal_tx_frame_href         ),
        .post_tx_img             (cal_tx_img                ),

        .post_A                  (cal_A                     ) 
);
            
haze_remove_cal u_haze_remove_cal(
        .clk                     (clk                       ),
        .rst_n                   (rst_n                     ),  

        .per_src_frame_vsync     (cal_src_frame_vsync       ), 
        .per_src_frame_href      (cal_src_frame_href        ),  
        .per_img                 (cal_img                   ),

        .per_tx_frame_vsync      (cal_tx_frame_vsync        ),
        .per_tx_frame_href       (cal_tx_frame_href         ),
        .per_tx_img              (cal_tx_img                ),

        .per_A                   (cal_A                     ),

        .post_frame_vsync        (post_frame_vsync1          ), 
        .post_frame_href         (post_frame_href1           ),  
        .post_img                (post_img1                  )
);

always@(*)begin
	if(switch)begin
		post_frame_vsync  <= post_frame_vsync1 ;
        post_frame_href   <= post_frame_href1  ; 
        post_img          <= post_img1         ; 
	end else begin
		post_frame_vsync  <= per_frame_vsync ;
        post_frame_href   <= per_frame_href  ; 
        post_img          <= per_img         ; 
	end
end

endmodule