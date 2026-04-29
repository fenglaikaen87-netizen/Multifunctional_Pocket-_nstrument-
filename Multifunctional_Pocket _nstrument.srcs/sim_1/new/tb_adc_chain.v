`timescale 1ns / 1ps

module tb_adc_chain;

    //====================================================
    // 1. Testbench 信号
    //====================================================
    reg clk;
    reg rst_n;

    wire [7:0] adc_ch1_data;
    wire [7:0] adc_ch2_data;
    wire       adc_valid;

    wire [31:0] period_cnt;
    wire        period_valid;
    wire [31:0] freq_value;

    wire [7:0] max_val;
    wire [7:0] min_val;
    wire [7:0] vpp;
    wire [7:0] mid_val;
    wire       measure_valid;

    //====================================================
    // 2. 假 ADC 数据源
    //====================================================
    adc_interface_stub #(
        .DATA_WIDTH(8)
    ) u_adc_interface_stub (
        .clk(clk),
        .rst_n(rst_n),

        .adc_ch1_data(adc_ch1_data),
        .adc_ch2_data(adc_ch2_data),
        .adc_valid(adc_valid)
    );

    //====================================================
    // 3. ADC 测频模块
    //====================================================
    freq_meter_adc #(
        .DATA_WIDTH(8),
        .THRESHOLD(8'd128)
    ) u_freq_meter_adc (
        .clk(clk),
        .rst_n(rst_n),

        .adc_data(adc_ch1_data),
        .adc_valid(adc_valid),

        .period_cnt(period_cnt),
        .period_valid(period_valid)
    );

    //====================================================
    // 4. 周期 → 频率
    // 注意：
    // period_cnt 统计的是 adc_valid 有效采样点数，
    // 不是 100MHz 系统时钟周期数。
    //
    // adc_interface_stub 中：
    // 100MHz / 100 = 1MHz 假 ADC 采样率
    //====================================================
    freq_calc #(
        .SAMPLE_FREQ(1_000_000)
    ) u_freq_calc (
        .clk(clk),
        .rst_n(rst_n),

        .period_cnt(period_cnt),
        .period_valid(period_valid),

        .freq_value(freq_value)
    );

    //====================================================
    // 5. 幅值测量模块
    //====================================================
    scope_measure #(
        .DATA_WIDTH(8),
        .WINDOW_LEN(1024)
    ) u_scope_measure (
        .clk(clk),
        .rst_n(rst_n),

        .adc_data(adc_ch1_data),
        .sample_valid(adc_valid),

        .max_val(max_val),
        .min_val(min_val),
        .vpp(vpp),
        .mid_val(mid_val),
        .measure_valid(measure_valid)
    );

    //====================================================
    // 6. 100MHz 时钟
    //====================================================
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //====================================================
    // 7. 仿真激励
    //====================================================
    initial begin
        rst_n = 1'b0;

        #100;
        rst_n = 1'b1;

        // 多跑一段时间，让 freq_value 和 measure_valid 都有结果
        #5_000_000;

        $stop;
    end

endmodule