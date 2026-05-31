module scope_core_stub #(
    parameter SAMPLE_FREQ = 1_000_000
)(
    input  wire       clk,
    input  wire       rst_n,

    //====================================================
    // VGA 输出
    //====================================================
    output wire       vga_hsync,
    output wire       vga_vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,

    //====================================================
    // 调试输出：ADC
    //====================================================
    output wire [7:0] adc_ch1_data,
    output wire [7:0] adc_ch2_data,
    output wire       adc_valid,

    //====================================================
    // 调试输出：触发 / 采集 / buffer
    //====================================================
    output wire       trig_pulse,
    output wire       capture_enable,
    output wire       capturing,
    output wire       frame_done,
    output wire       wr_en,
    output wire [9:0] wr_addr,
    output wire [7:0] wr_data,

    output wire       display_bank,
    output wire       write_bank,
    output wire       swap_pending,
    output wire [7:0] wave_data,

    //====================================================
    // 调试输出：测量结果
    //====================================================
    output wire [31:0] period_cnt,
    output wire        period_valid,
    output wire [31:0] freq_value,

    output wire [7:0]  max_val,
    output wire [7:0]  min_val,
    output wire [7:0]  vpp,
    output wire [7:0]  mid_val,
    output wire        measure_valid
);

    //====================================================
    // 1. 假 ADC：后续替换为 xadc_adapter
    //====================================================
    adc_interface_stub #(
        .DATA_WIDTH(8)
    ) u_adc_interface_stub (
        .clk          (clk),
        .rst_n        (rst_n),

        .adc_ch1_data (adc_ch1_data),
        .adc_ch2_data (adc_ch2_data),
        .adc_valid    (adc_valid)
    );

    //====================================================
    // 2. VGA 时序
    //====================================================
    wire       video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    vga_timing u_vga_timing (
        .pclk     (clk),
        .rst_n    (rst_n),

        .hsync    (vga_hsync),
        .vsync    (vga_vsync),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y)
    );

    // VGA 新一帧开始脉冲
    reg vga_frame_start;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_frame_start <= 1'b0;
        end else begin
            vga_frame_start <= (pixel_x == 10'd0) && (pixel_y == 10'd0);
        end
    end

    //====================================================
    // 3. 触发检测
    //====================================================
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
    // 4. 触发后采集一帧
    //====================================================
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
    // 6. VGA 波形绘制
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
    // 7. 测频 / 测幅
    //====================================================
    scope_measure_core #(
        .SAMPLE_FREQ (SAMPLE_FREQ)
    ) u_scope_measure_core (
        .clk           (clk),
        .rst_n         (rst_n),

        .adc_data      (adc_ch1_data),
        .adc_valid     (adc_valid),

        .period_cnt    (period_cnt),
        .period_valid  (period_valid),
        .freq_value    (freq_value),

        .max_val       (max_val),
        .min_val       (min_val),
        .vpp           (vpp),
        .mid_val       (mid_val),
        .measure_valid (measure_valid)
    );

endmodule