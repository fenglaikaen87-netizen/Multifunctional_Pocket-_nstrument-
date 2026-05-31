`timescale 1ns / 1ps

module tb_scope_core_stub_dualclk;

    reg sys_clk;
    reg vga_clk;
    reg rst_n;

    wire       vga_hsync;
    wire       vga_vsync;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

    wire [7:0] adc_ch1_data;
    wire [7:0] adc_ch2_data;
    wire       adc_valid;

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

    wire [31:0] period_cnt;
    wire        period_valid;
    wire [31:0] freq_value;

    wire [7:0]  max_val;
    wire [7:0]  min_val;
    wire [7:0]  vpp;
    wire [7:0]  mid_val;
    wire        measure_valid;

    //====================================================
    // 100MHz 系统时钟
    //====================================================
    initial begin
        sys_clk = 1'b0;
        forever #5 sys_clk = ~sys_clk;
    end

    //====================================================
    // 25MHz VGA 像素时钟
    // 仿真中手动生成；
    // 真实上板时由 Clocking Wizard IP 生成。
    //====================================================
    initial begin
        vga_clk = 1'b0;
        forever #20 vga_clk = ~vga_clk;
    end

    //====================================================
    // 复位
    //====================================================
    initial begin
        rst_n = 1'b0;
        #500;
        rst_n = 1'b1;
    end

    //====================================================
    // DUT
    //====================================================
    scope_core_stub_dualclk #(
        .SAMPLE_FREQ (1_000_000)
    ) u_scope_core_stub_dualclk (
        .sys_clk        (sys_clk),
        .vga_clk        (vga_clk),
        .rst_n          (rst_n),

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

    //====================================================
    // 仿真 50ms，覆盖多帧 VGA
    //====================================================
    initial begin
        #50_000_000;
        $stop;
    end

endmodule