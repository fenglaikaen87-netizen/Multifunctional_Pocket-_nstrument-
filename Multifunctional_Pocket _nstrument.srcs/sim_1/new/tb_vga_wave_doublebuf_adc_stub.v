`timescale 1ns / 1ps

module tb_vga_wave_doublebuf_adc_stub;

    reg clk;
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
    // 仿真先用 25MHz
    //====================================================
    initial begin
        clk = 1'b0;
        forever #20 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #500;
        rst_n = 1'b1;
    end

    //====================================================
    // 1. 假 ADC，后续替换为 XADC adapter
    //====================================================
    wire [7:0] adc_ch1_data;
    wire [7:0] adc_ch2_data;
    wire       adc_valid;

    adc_interface_stub u_adc_interface_stub (
        .clk          (clk),
        .rst_n        (rst_n),
        .adc_ch1_data (adc_ch1_data),
        .adc_ch2_data (adc_ch2_data),
        .adc_valid    (adc_valid)
    );

    //====================================================
    // 2. 触发检测
    //====================================================
    wire trig_pulse;

    trigger_detect #(
        .DATA_WIDTH (8),
        .THRESHOLD  (8'd128)
    ) u_trigger_detect (
        .clk        (clk),
        .rst_n      (rst_n),
        .adc_data   (adc_ch1_data),
        .adc_valid  (adc_valid),
        .trig_pulse (trig_pulse)
    );

    //====================================================
    // 3. VGA 时序
    //====================================================
    vga_timing u_vga_timing (
        .pclk     (clk),
        .rst_n    (rst_n),
        .hsync    (hsync),
        .vsync    (vsync),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y)
    );

    // VGA 新一帧开始
    wire vga_frame_start;
    assign vga_frame_start = (pixel_x == 10'd0) && (pixel_y == 10'd0);

    //====================================================
    // 4. 触发后采集一帧
    //====================================================
    wire       wr_en;
    wire [9:0] wr_addr;
    wire [7:0] wr_data;
    wire       capturing;
    wire       frame_done;

    wire       capture_enable;

    wave_capture_triggered #(
        .DATA_WIDTH (8),
        .ADDR_WIDTH (10),
        .FRAME_LEN  (640)
    ) u_wave_capture_triggered (
        .clk            (clk),
        .rst_n          (rst_n),

        .capture_enable (capture_enable),

        .adc_data       (adc_ch1_data),
        .adc_valid      (adc_valid),
        .trig_pulse     (trig_pulse),

        .wr_en          (wr_en),
        .wr_addr        (wr_addr),
        .wr_data        (wr_data),

        .capturing      (capturing),
        .frame_done     (frame_done)
    );

    //====================================================
    // 5. 双 buffer
    //====================================================
    wire [7:0] wave_data;

    wire display_bank;
    wire write_bank;
    wire swap_pending;

    waveform_double_buffer #(
        .DATA_WIDTH (8),
        .ADDR_WIDTH (10),
        .FRAME_LEN  (640)
    ) u_waveform_double_buffer (
        .clk             (clk),
        .rst_n           (rst_n),

        .wr_en           (wr_en),
        .wr_addr         (wr_addr),
        .wr_data         (wr_data),

        .frame_done      (frame_done),
        .vga_frame_start (vga_frame_start),

        .rd_addr         (pixel_x),
        .rd_data         (wave_data),

        .display_bank    (display_bank),
        .write_bank      (write_bank),
        .swap_pending    (swap_pending),
        .capture_enable  (capture_enable)
    );

    //====================================================
    // 6. VGA 波形显示
    //====================================================
    vga_wave_display_buf u_vga_wave_display_buf (
        .video_on  (video_on),
        .pixel_x   (pixel_x),
        .pixel_y   (pixel_y),
        .wave_data (wave_data),

        .vga_r     (vga_r),
        .vga_g     (vga_g),
        .vga_b     (vga_b)
    );

    //====================================================
    // 仿真 40ms，看至少两帧 VGA
    //====================================================
    initial begin
        #40_000_000;
        $stop;
    end

endmodule