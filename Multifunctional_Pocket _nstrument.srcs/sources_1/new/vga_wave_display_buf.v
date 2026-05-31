module vga_wave_display_buf(
    input  wire       video_on,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire [7:0] wave_data,

    output reg  [3:0] vga_r,
    output reg  [3:0] vga_g,
    output reg  [3:0] vga_b
);

    //====================================================
    // 1. 8位波形幅值映射到屏幕 y 坐标
    //
    // wave_data = 0   -> y = 400
    // wave_data = 255 -> y ≈ 145
    //====================================================

    wire [9:0] wave_y;
    assign wave_y = 10'd400 - {2'b00, wave_data};

    //====================================================
    // 2. 网格 / 坐标轴 / 波形点
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

    // 波形线加粗 3 像素
    assign wave_point = (pixel_y >= wave_y - 1) &&
                        (pixel_y <= wave_y + 1);

    //====================================================
    // 3. RGB 输出
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