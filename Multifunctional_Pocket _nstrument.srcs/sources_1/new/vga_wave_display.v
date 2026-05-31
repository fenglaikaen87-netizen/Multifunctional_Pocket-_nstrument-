module vga_wave_display(
    input  wire       video_on,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,

    output reg  [3:0] vga_r,
    output reg  [3:0] vga_g,
    output reg  [3:0] vga_b
);

    //====================================================
    // 1. 生成一个临时测试波形
    //    这里先不用真实 wave_out
    //    先用 pixel_x 构造一条周期性三角波
    //====================================================

    reg [7:0] test_wave;

    always @(*) begin
        if (pixel_x[8] == 1'b0)
            test_wave = pixel_x[7:0];       // 上升
        else
            test_wave = ~pixel_x[7:0];      // 下降
    end

    //====================================================
    // 2. 把 8 位幅值映射到 VGA 的 y 坐标
    //
    // wave = 0   -> y 接近 400
    // wave = 255 -> y 接近 80
    //
    // 这样波形不会贴着屏幕边缘
    //====================================================

    wire [9:0] wave_y;
    assign wave_y = 10'd400 - {2'b00, test_wave, 0}; 
    // 等价于 400 - test_wave*2
    // 显示范围大约 y = 400 ~ -110，略大
    // 下面绘图区域会限制显示

    // 更安全的压缩版本：
    wire [9:0] wave_y_safe;
    assign wave_y_safe = 10'd400 - {3'b000, test_wave[7:1], 1'b0};
    // 约等于 400 - test_wave
    // 显示范围约 y = 400 ~ 145

    //====================================================
    // 3. 网格 / 坐标轴
    //====================================================

    wire border;
    wire axis_x;
    wire axis_y;
    wire grid_x;
    wire grid_y;
    wire wave_point;

    assign border = (pixel_x == 10'd0)   ||
                    (pixel_x == 10'd639) ||
                    (pixel_y == 10'd0)   ||
                    (pixel_y == 10'd479);

    assign axis_x = (pixel_x == 10'd320);
    assign axis_y = (pixel_y == 10'd240);

    assign grid_x = (pixel_x % 40 == 0);
    assign grid_y = (pixel_y % 40 == 0);

    // 波形线加粗：当前像素 y 坐标接近 wave_y_safe 时点亮
    assign wave_point = (pixel_y >= wave_y_safe - 1) &&
                        (pixel_y <= wave_y_safe + 1);

    //====================================================
    // 4. 颜色输出
    //====================================================

    always @(*) begin
        if (!video_on) begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end else if (wave_point) begin
            // 绿色波形
            vga_r = 4'h0;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (border) begin
            // 白色边框
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'hF;
        end else if (axis_x || axis_y) begin
            // 黄色坐标轴
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (grid_x || grid_y) begin
            // 灰色网格
            vga_r = 4'h3;
            vga_g = 4'h3;
            vga_b = 4'h3;
        end else begin
            // 黑色背景
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end
    end

endmodule