module key_filter(
    key,
    clk,
    reset_n,
    key_state,
    key_flag
);
    input key;
    input clk;
    input reset_n;
    reg key_p_flag;
    reg key_r_flag;
    output reg key_state;//消抖后的按键波形
    output key_flag;//按键按下或松开置1
    
    //避免亚稳态
    reg [1:0]sync_key;
    always@(posedge clk)
    sync_key={sync_key[0],key};
    
    //检测边沿信号
    reg [1:0]r_key;
    always@(posedge clk)
        r_key<={r_key[0],sync_key};//位拼接
        
    wire nedge_key;//下降沿
    wire pedge_key;//上升沿
    
    assign nedge_key=(r_key==2'b10);
    assign pedge_key=(r_key==2'b01);
    assign key_flag=key_p_flag/*|key_r_flag*/;
    
    reg [21:0]count;
    parameter MCNT=2500000-1;//20ms
    reg [1:0]state;//状态机
    always@(posedge clk or negedge reset_n)
    if(!reset_n)begin
        state<=0;
        key_r_flag<=0;
        key_p_flag<=0;
        key_state<=1;
        count<=0;
    end
    else begin
    case(state)
        0:begin
          key_r_flag<=0;
          if(nedge_key)
            state<=1;
          else 
            state<=0;
          end
        1:if((count<MCNT)&&(pedge_key==1))begin
            state<=0;
            count<=0;
          end
          else if(count>=MCNT)begin
            key_p_flag<=1;
            key_state<=0;
            count<=0;
            state<=2;
          end
          else if((count<MCNT)&&(pedge_key==0))begin
            state<=1;
            count<=count+1'd1;
          end
        2:begin
          key_p_flag<=0;
          if(pedge_key)
            state<=3;
          else
            state<=2;
          end
        3:if((count<MCNT)&&(nedge_key==0))begin
            state<=3;
            count<=count+1'd1;
          end
          else if((count<MCNT)&&(nedge_key==1))begin
            state<=2;
            count<=0;
          end
          else if(count>=MCNT)begin
            state<=0;
            count<=0;
            key_r_flag<=1;
            key_state<=1;
          end
    endcase
    end
            

endmodule