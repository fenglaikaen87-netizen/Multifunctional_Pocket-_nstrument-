`timescale 1ns / 1ps

module tb_vga_wave;

    reg pclk;
    reg rst_n;

    wire hsync;
    wire vsync;
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

    //====================================================
    // 25MHz 像素时钟
    //====================================================
    initial begin
        pclk = 1'b0;
        forever #20 pclk = ~pclk;
    end

    //====================================================
    // 复位
    //====================================================
    initial begin
        rst_n = 1'b0;
        #200;
        rst_n = 1'b1;
    end

    //====================================================
    // VGA 时序
    //====================================================
    vga_timing u_vga_timing (
        .pclk     (pclk),
        .rst_n    (rst_n),
        .hsync    (hsync),
        .vsync    (vsync),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y)
    );

    //====================================================
    // VGA 波形显示
    //====================================================
    vga_wave_display u_vga_wave_display (
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y),
        .vga_r    (vga_r),
        .vga_g    (vga_g),
        .vga_b    (vga_b)
    );

    //====================================================
    // 仿真 20ms，覆盖一整帧
    //====================================================
    initial begin
        #20_000_000;
        $stop;
    end

endmodule