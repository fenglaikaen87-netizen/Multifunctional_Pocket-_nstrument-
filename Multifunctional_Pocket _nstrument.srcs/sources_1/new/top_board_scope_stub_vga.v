module top_board_scope_stub_vga(
    input  wire       sys_clk,     // EGO1 100MHz 系统时钟
    input  wire       rst_n,       // 低电平复位

    output wire       vga_hsync,
    output wire       vga_vsync,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b
);

    //====================================================
    // 1. Clocking Wizard IP
    // 100MHz sys_clk → 25MHz vga_clk
    //====================================================
    wire vga_clk;
    wire clk_locked;

    clk_wiz_25m u_clk_wiz_25m (
        .clk_in1  (sys_clk),
        .clk_out1 (vga_clk),
        .reset    (~rst_n),
        .locked   (clk_locked)
    );

    //====================================================
    // 2. 复位处理
    // 只有外部复位释放，并且 clk_wiz 锁定后，系统才运行
    //====================================================
    wire core_rst_n;
    assign core_rst_n = rst_n & clk_locked;

    //====================================================
    // 3. 示波器核心
    //====================================================

    // ADC 调试信号
    wire [7:0] adc_ch1_data;
    wire [7:0] adc_ch2_data;
    wire       adc_valid;

    // 触发 / 采集 / buffer 调试信号
    wire       trig_pulse;
    wire       capture_enable;
    wire       capturing;
    wire       frame_done;
    wire       wr_en;
    wire [9:0] wr_addr;
    wire [7:0] wr_data;

    wire       display_bank;
    wire       write_bank;
    wire       swap_pending;
    wire [7:0] wave_data;

    // 测量结果调试信号
    wire [31:0] period_cnt;
    wire        period_valid;
    wire [31:0] freq_value;

    wire [7:0]  max_val;
    wire [7:0]  min_val;
    wire [7:0]  vpp;
    wire [7:0]  mid_val;
    wire        measure_valid;

    scope_core_stub_dualclk #(
        .SAMPLE_FREQ (1_000_000)
    ) u_scope_core_stub_dualclk (
        .sys_clk        (sys_clk),
        .vga_clk        (vga_clk),
        .rst_n          (core_rst_n),

        .vga_hsync      (vga_hsync),
        .vga_vsync      (vga_vsync),
        .vga_r          (vga_r),
        .vga_g          (vga_g),
        .vga_b          (vga_b),

        .adc_ch1_data   (adc_ch1_data),
        .adc_ch2_data   (adc_ch2_data),
        .adc_valid      (adc_valid),

        .trig_pulse     (trig_pulse),
        .capture_enable (capture_enable),
        .capturing      (capturing),
        .frame_done     (frame_done),
        .wr_en          (wr_en),
        .wr_addr        (wr_addr),
        .wr_data        (wr_data),

        .display_bank   (display_bank),
        .write_bank     (write_bank),
        .swap_pending   (swap_pending),
        .wave_data      (wave_data),

        .period_cnt     (period_cnt),
        .period_valid   (period_valid),
        .freq_value     (freq_value),

        .max_val        (max_val),
        .min_val        (min_val),
        .vpp            (vpp),
        .mid_val        (mid_val),
        .measure_valid  (measure_valid)
    );

endmodule