`timescale 1ns / 1ps

module tb_scope_measure_core_adc_stub;

    reg clk;
    reg rst_n;

    //====================================================
    // 100MHz 系统时钟
    //====================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        #200;
        rst_n = 1'b1;
    end

    //====================================================
    // 1. 假 ADC 输入
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
    // 2. 测频 / 测幅核心
    //====================================================
    wire [31:0] period_cnt;
    wire        period_valid;
    wire [31:0] freq_value;

    wire [7:0] max_val;
    wire [7:0] min_val;
    wire [7:0] vpp;
    wire [7:0] mid_val;
    wire       measure_valid;

    scope_measure_core u_scope_measure_core (
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

    initial begin
        #10_000_000;
        $stop;
    end

endmodule