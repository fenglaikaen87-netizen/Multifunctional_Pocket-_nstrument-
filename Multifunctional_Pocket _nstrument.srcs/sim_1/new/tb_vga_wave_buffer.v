`timescale 1ns / 1ps

module tb_vga_wave_buffer;

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
    // 25MHz VGA 像素时钟
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
    // 模拟写入波形 buffer
    //====================================================
    reg        wr_en;
    reg [9:0]  wr_addr;
    reg [7:0]  wr_data;

    wire [7:0] wave_data;

    waveform_buffer u_waveform_buffer (
        .clk     (pclk),

        .wr_en   (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_data),

        .rd_addr (pixel_x),
        .rd_data (wave_data)
    );

    //====================================================
    // 生成一屏测试波形写入 buffer
    // 这里写入一个三角波：
    // x = 0~319   上升
    // x = 320~639 下降
    //====================================================
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            wr_en   <= 1'b0;
            wr_addr <= 10'd0;
            wr_data <= 8'd0;
        end else begin
            wr_en <= 1'b1;

            if (wr_addr < 10'd639)
                wr_addr <= wr_addr + 1'b1;
            else
                wr_addr <= 10'd0;

            if (wr_addr < 10'd320)
                wr_data <= wr_addr[8:1];          // 上升
            else
                wr_data <= 8'd255 - wr_addr[8:1]; // 下降
        end
    end

    //====================================================
    // VGA 波形绘制
    //====================================================
    vga_wave_display_buf u_vga_wave_display_buf (
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y),
        .wave_data(wave_data),

        .vga_r    (vga_r),
        .vga_g    (vga_g),
        .vga_b    (vga_b)
    );

    //====================================================
    // 仿真 20ms，约一整帧
    //====================================================
    initial begin
        #20_000_000;
        $stop;
    end

endmodule