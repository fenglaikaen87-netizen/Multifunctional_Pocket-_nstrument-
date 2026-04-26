module top(
    input  wire clk,
    input  wire rst_n,

    input  wire [1:0] mode,
    input  wire [2:0] freq_sel,

    output reg  [7:0]  wave_out,
    output wire        pwm_out,

    output wire [31:0] period_cnt,
    output wire [31:0] freq_value,

    output wire [7:0]  max_val,
    output wire [7:0]  min_val,
    output wire [7:0]  vpp,
    output wire [7:0]  mid_val,
    output wire        measure_valid,

    output wire [7:0]  liss_x,
    output wire [7:0]  liss_y
);

    //====================================================
    // 1. 基础频率控制：给方波 / 三角波使用
    //====================================================
    wire [31:0] freq_ctrl;

    freq_ctrl_basic u_freq_ctrl_basic (
        .freq_sel(freq_sel),
        .freq_ctrl(freq_ctrl)
    );

    //====================================================
    // 2. DDS频率控制：给DDS正弦使用
    //====================================================
    wire [23:0] phase_step;

    freq_ctrl_dds u_freq_ctrl_dds (
        .freq_sel(freq_sel),
        .phase_step(phase_step)
    );

    //====================================================
    // 3. 方波发生器
    //====================================================
    wire square_out;

    square_gen u_square_gen (
        .clk(clk),
        .rst_n(rst_n),
        .freq_ctrl(freq_ctrl),
        .square_out(square_out)
    );

    //====================================================
    // 4. 三角波发生器
    //====================================================
    wire [7:0] triangle_out;

    triangle_gen u_triangle_gen (
        .clk(clk),
        .rst_n(rst_n),
        .freq_ctrl(freq_ctrl),
        .triangle_out(triangle_out)
    );

    //====================================================
    // 5. DDS正弦波发生器
    //====================================================
    wire [7:0] sine_out;

    dds_sine_gen u_dds_sine_gen (
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .sine_out(sine_out)
    );

    //====================================================
    // 6. 波形选择
    //====================================================
    always @(*) begin
        case (mode)
            2'b00: begin
                // 方波：1bit 扩展成 8bit
                wave_out = {8{square_out}};
            end

            2'b01: begin
                wave_out = triangle_out;
            end

            2'b10: begin
                wave_out = sine_out;
            end

            default: begin
                wave_out = 8'd0;
            end
        endcase
    end

    //====================================================
    // 7. PWM输出
    //====================================================
    pwm_out u_pwm_out (
        .clk(clk),
        .rst_n(rst_n),
        .duty_in(wave_out),
        .pwm_out(pwm_out)
    );

    //====================================================
    // 8. 频率测量
    // 当前先测内部 square_out
    //====================================================
    wire period_valid;

    freq_meter u_freq_meter (
        .clk(clk),
        .rst_n(rst_n),
        .sig_in(square_out),
        .period_cnt(period_cnt),
        .period_valid(period_valid)
    );

    //====================================================
    // 9. 周期 → 频率
    // freq_value = 100MHz / period_cnt
    //====================================================
    freq_calc #(
        .CLK_FREQ(100_000_000)
    ) u_freq_calc (
        .clk(clk),
        .rst_n(rst_n),
        .period_cnt(period_cnt),
        .period_valid(period_valid),
        .freq_value(freq_value)
    );

    //====================================================
    // 10. 幅值测量
    // 当前先测内部 wave_out
    // 后续真实示波器版：
    // adc_data 替换成 XADC / ADC 采样数据
    //====================================================
    scope_measure #(
        .DATA_WIDTH(8),
        .WINDOW_LEN(100000)
    ) u_scope_measure (
        .clk(clk),
        .rst_n(rst_n),
        .adc_data(wave_out),
        .sample_valid(1'b1),
        .max_val(max_val),
        .min_val(min_val),
        .vpp(vpp),
        .mid_val(mid_val),
        .measure_valid(measure_valid)
    );

    //====================================================
    // 11. 李萨如内部 DDS 验证模块
    //
    // 当前固定：
    // X = sin(wt)
    // Y = sin(wt + 90°)
    //
    // 后续可改成：
    // ADC_CH1 → liss_x
    // ADC_CH2 → liss_y
    //====================================================
    wire [23:0] liss_phase_step_x;
    wire [23:0] liss_phase_step_y;
    wire [23:0] liss_phase_offset_y;

    assign liss_phase_step_x   = phase_step;
    assign liss_phase_step_y   = phase_step;
    assign liss_phase_offset_y = 24'd4194304;   // 2^24 / 4 = 90°

    lissajous_dds u_lissajous_dds (
        .clk(clk),
        .rst_n(rst_n),
        .phase_step_x(liss_phase_step_x),
        .phase_step_y(liss_phase_step_y),
        .phase_offset_y(liss_phase_offset_y),
        .x_out(liss_x),
        .y_out(liss_y)
    );

endmodule