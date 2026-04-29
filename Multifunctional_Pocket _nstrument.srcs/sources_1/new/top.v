module top(
    input  wire       clk,
    input  wire       rst_n,

    input  wire [1:0] mode,
    input  wire [2:0] freq_sel,

    output reg  [7:0] wave_out,
    output wire       pwm_out
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
    // 2. DDS频率控制：给DDS正弦波使用
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
    // mode = 00：方波
    // mode = 01：三角波
    // mode = 10：正弦波
    //====================================================
    always @(*) begin
        case (mode)
            2'b00: begin
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
    // wave_out[7:0] → 占空比 → pwm_out
    //====================================================
    pwm_out #(
        .DATA_WIDTH(8)
    ) u_pwm_out (
        .clk(clk),
        .rst_n(rst_n),
        .duty_in(wave_out),
        .pwm_out(pwm_out)
    );

endmodule