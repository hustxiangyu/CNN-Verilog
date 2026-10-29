module isp_contrast
(
	  input		  			clk				,
      input 		[7:0] 	i_data_r		,
      input 		[7:0] 	i_data_g		,
      input 		[7:0] 	i_data_b		,
      input  	 	 		switch1			,
      input  	 	[1:0]	choice			,
      input  	  			i_data_valid	,
      input  	 		 	i_href			,
      input  	  			i_vsync			,
      output	reg  		o_vsync			,
      output	reg	[7:0]	o_data_r		,
      output	reg [7:0]   o_data_g		,
      output	reg [7:0]   o_data_b		,
	  output	reg         o_href			,
      output	reg         o_data_valid
 );

//wire [7:0]   o_data_r_0p7;
//wire [7:0]   o_data_g_0p7;
//wire [7:0]   o_data_b_0p7; 
wire [7:0]   o_data_r_0p5;
wire [7:0]   o_data_g_0p5;
wire [7:0]   o_data_b_0p5; 

wire [7:0]   o_data_r_1p0;
wire [7:0]   o_data_g_1p0;
wire [7:0]   o_data_b_1p0;

wire [7:0]   o_data_r_1p6;
wire [7:0]   o_data_g_1p6;
wire [7:0]   o_data_b_1p6;
//wire [7:0]   o_data_r_1p2;
//wire [7:0]   o_data_g_1p2;
//wire [7:0]   o_data_b_1p2;

always@(*)begin
	if(switch1)begin
		case(choice)
			2'd0:begin
        		o_data_r<=o_data_r_1p0 ;
        		o_data_g<=o_data_g_1p0 ;
        		o_data_b<=o_data_b_1p0 ;
        		o_vsync <= i_vsync;         
    			o_data_valid <= i_data_valid; 	
				o_href <= i_href;
			 end
			2'd1:begin
        		o_data_r<=o_data_r_0p5 ;
        		o_data_g<=o_data_g_0p5 ;
        		o_data_b<=o_data_b_0p5 ;
        		o_vsync <= i_vsync;      
    			o_data_valid <= i_data_valid;
				o_href <= i_href;         		
			 end
			2'd2:begin
        		o_data_r<=o_data_r_1p6 ;
        		o_data_g<=o_data_g_1p6 ;
        		o_data_b<=o_data_b_1p6 ;
        		o_vsync <= i_vsync;         
    			o_data_valid <= i_data_valid;
				o_href <= i_href;
			end
		default:begin
			o_data_r<=i_data_r;
        	o_data_g<=i_data_r;
        	o_data_b<=i_data_r;
        	o_vsync <= i_vsync;         
    		o_data_valid <= i_data_valid;
			o_href <= i_href;
			end
		endcase
	end else begin
		o_data_r<=i_data_r;
        o_data_g<=i_data_r;
        o_data_b<=i_data_r;
        o_vsync <= i_vsync;         
    	o_data_valid <= i_data_valid;
		o_href <= i_href;
	end
end
//0p5
contrast_0p5 contrast_0point5_inst_r
(
   .Pre_Data	(i_data_r	)	,
   .Post_Data	(o_data_r_0p5	)
);
contrast_0p5 contrast_0point5_inst_g
(
   .Pre_Data	(i_data_g	)	,
   .Post_Data	(o_data_g_0p5	)
);
contrast_0p5 contrast_0point5_inst_b
(
   .Pre_Data	(i_data_b	)	,
   .Post_Data	(o_data_b_0p5	)
);
//1p0
contrast_1p0 contrast_1point0_inst_r
(
   .Pre_Data	(i_data_r	)	,
   .Post_Data	(o_data_r_1p0	)
);
contrast_1p0 contrast_1point0_inst_g
(
   .Pre_Data	(i_data_g	)	,
   .Post_Data	(o_data_g_1p0	)
);
contrast_1p0 contrast_1point0_inst_b
(
   .Pre_Data	(i_data_b	)	,
   .Post_Data	(o_data_b_1p0	)
);
//1p2
contrast_1p6 contrast_1point6_inst_r
(
   .Pre_Data	(i_data_r	)	,
   .Post_Data	(o_data_r_1p6	)
);
contrast_1p6 contrast_1point6_inst_g
(
   .Pre_Data	(i_data_g	)	,
   .Post_Data	(o_data_g_1p6	)
);
contrast_1p6 contrast_1point6_inst_b
(
   .Pre_Data	(i_data_b	)	,
   .Post_Data	(o_data_b_1p6	)
);

endmodule
