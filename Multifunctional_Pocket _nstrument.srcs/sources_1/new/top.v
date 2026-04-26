module top(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  mode,
    input  wire [2:0]  freq_sel,
    output reg  [7:0]  wave_out,
    output wire        pwm_out,

    // 新增：调试输出，便于仿真观察周期计数值
    output wire [31:0] period_cnt
);

    //====================================================
    // 1. 基础频率控制（给方波/三角波）
    //====================================================
    wire [31:0] freq_ctrl;

    freq_ctrl_basic u_freq_ctrl_basic (
        .freq_sel(freq_sel),
        .freq_ctrl(freq_ctrl)
    );

    //====================================================
    // 2. DDS频率控制（给正弦波）
    //====================================================
    wire [23:0] phase_step;

    freq_ctrl_dds u_freq_ctrl_dds (
        .freq_sel(freq_sel),
        .phase_step(phase_step)
    );

    //====================================================
    // 3. 方波模块
    //====================================================
    wire square_out;

    square_gen u_square_gen (
        .clk(clk),
        .rst_n(rst_n),
        .freq_ctrl(freq_ctrl),
        .square_out(square_out)
    );

    //====================================================
    // 4. 三角波模块
    //====================================================
    wire [7:0] triangle_out;

    triangle_gen u_triangle_gen (
        .clk(clk),
        .rst_n(rst_n),
        .freq_ctrl(freq_ctrl),
        .triangle_out(triangle_out)
    );

    //====================================================
    // 5. DDS正弦波模块
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
            2'b00: wave_out = {8{square_out}}; // 方波扩展成8位
            2'b01: wave_out = triangle_out;
            2'b10: wave_out = sine_out;
            default: wave_out = 8'h00;
        endcase
    end

    //====================================================
    // 7. PWM输出模块
    //====================================================
    pwm_out #(.DATA_WIDTH(8)) u_pwm_out (
        .clk(clk),
        .rst_n(rst_n),
        .duty_in(wave_out),
        .pwm_out(pwm_out)
    );

    //====================================================
    // 8. 频率测量模块
    // 先测方波 square_out，最容易验证
    //====================================================
    freq_meter u_freq_meter (
        .clk(clk),
        .rst_n(rst_n),
        .sig_in(square_out),
        .period_cnt(period_cnt)
    );

endmodule