`timescale 1ns / 1ps

module tb_adc_freq;

    //====================================================
    // 1. 时钟与复位
    //====================================================
    reg clk;
    reg rst_n;

    //====================================================
    // 2. ADC stub 输出
    //====================================================
    wire [7:0] adc_ch1_data;
    wire [7:0] adc_ch2_data;
    wire       adc_valid;

    //====================================================
    // 3. 测频链路信号
    //====================================================
    wire [31:0] period_cnt;
    wire        period_valid;
    wire [31:0] freq_value;

    //====================================================
    // 4. 100MHz 时钟
    //====================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //====================================================
    // 5. 复位与仿真时间
    //====================================================
    initial begin
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;

        #20000;
        $stop;
    end

    //====================================================
    // 6. ADC 仿真输入模块
    //====================================================
    adc_interface_stub u_adc_interface_stub (
        .clk          (clk),
        .rst_n        (rst_n),
        .adc_ch1_data (adc_ch1_data),
        .adc_ch2_data (adc_ch2_data),
        .adc_valid    (adc_valid)
    );

    //====================================================
    // 7. ADC数据测周期
    //====================================================
    freq_meter_adc u_freq_meter_adc (
        .clk          (clk),
        .rst_n        (rst_n),
        .adc_data     (adc_ch1_data),
        .adc_valid    (adc_valid),
        .period_cnt   (period_cnt),
        .period_valid (period_valid)
    );

    //====================================================
    // 8. 周期换算频率
    //====================================================
    freq_calc u_freq_calc (
        .clk          (clk),
        .rst_n        (rst_n),
        .period_cnt   (period_cnt),
        .period_valid (period_valid),
        .freq_value   (freq_value)
    );

endmodule