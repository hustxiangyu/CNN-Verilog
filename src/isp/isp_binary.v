module isp_binary
#(
    parameter BITS = 8,
    parameter WIDTH = 1920,
    parameter HEIGHT = 1080
)
(
    input  wire                 pclk,
    input  wire                 rst_n,
    input  wire                 switch,
    input  wire                 in_href,
    input  wire                 in_hsync,
    input  wire                 in_vsync,
    input  wire     [BITS-1:0]  in_y,
    input  wire     [BITS-1:0]  in_u,
    input  wire     [BITS-1:0]  in_v,

    output reg                  out_href,
    output reg                  out_hsync,
    output reg                  out_vsync,
    output reg      [BITS-1:0]  out_y,
    output reg      [BITS-1:0]  out_u,
    output reg      [BITS-1:0]  out_v
);

    reg                 vsync_dly;
    reg                 lcd_vs_neg;
    reg     [29:0]      total_num;
    reg     [29:0]      total_num_reg;
    reg     [29:0]      average;
    reg     [BITS-1:0]  y_data;

    // vsync延迟一级，用于检测下降沿
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n)
            vsync_dly <= 1'b0;
        else
            vsync_dly <= in_vsync;
    end

    // 检测 vsync 的下降沿
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n)
            lcd_vs_neg <= 1'b0;
        else
            lcd_vs_neg <= vsync_dly & ~in_vsync;
    end

    // 累加in_y的值，同时加入一个寄存器级来减少总线压力
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            total_num <= 30'b0;
            total_num_reg <= 30'b0;
        end else if (lcd_vs_neg) begin
            total_num <= 30'b0;
            total_num_reg <= 30'b0;
//        end else if (in_hsync && in_href) begin
//            total_num <= total_num + in_y;
//            total_num_reg <= total_num; // 延迟一级以缓解路径压力
//        end
        end else if (in_href) begin
            total_num <= total_num + in_y;
            total_num_reg <= total_num; // 延迟一级以缓解路径压力
        end
    end

    // 计算平均值，并引入寄存器管线来优化延迟
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            average <= 30'b0;
//        end else if (lcd_vs_neg) begin
//            average <= (total_num_reg > WIDTH*HEIGHT*256) ? 30'd255 : ((total_num_reg +30'd1110000)>>>21);
        end else if (lcd_vs_neg) begin
            average <=  (total_num_reg/(WIDTH*HEIGHT));
        end
    end

    // 将计算出的平均值y_data用于二值化
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            y_data <= 0;
        end else begin
            y_data <= average[BITS-1:0]+4'd10;
        end
    end

    // 输出处理
    always @(posedge pclk ) begin
       if (switch) begin
            out_y <= (in_y > 8'd95) ? 8'd255 : 8'd0;
            out_u <= in_u;
            out_v <= in_v;
            out_href <= in_href;
            out_hsync <= in_hsync;
            out_vsync <= in_vsync;
        end else begin
            out_y <= in_y;
            out_u <= in_u;
            out_v <= in_v;
            out_href <= in_href;
            out_hsync <= in_hsync;
            out_vsync <= in_vsync;
        end
    end
endmodule
