module pwm_out #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,        // 系统时钟
    input  wire                  rst_n,      // 低电平有效复位
    input  wire [DATA_WIDTH-1:0] duty_in,    // 输入幅值 / 目标占空比
    output reg                   pwm_out     // PWM输出
);

    // PWM计数器
    reg [DATA_WIDTH-1:0] pwm_cnt;

    // 占空比锁存寄存器
    // 作用：保证一个PWM周期内，占空比不被中途改变
    reg [DATA_WIDTH-1:0] duty_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_cnt  <= {DATA_WIDTH{1'b0}};
            duty_reg <= {DATA_WIDTH{1'b0}};
            pwm_out  <= 1'b0;
        end else begin

            // 计数器自然溢出，形成 0~255 的PWM周期
            pwm_cnt <= pwm_cnt + 1'b1;

            // 只在一个PWM周期开始时锁存新的 duty_in
            // 这样可以避免一个PWM周期中途占空比变化
            if (pwm_cnt == {DATA_WIDTH{1'b0}}) begin
                duty_reg <= duty_in;
            end

            // 使用锁存后的 duty_reg 进行比较
            if (pwm_cnt < duty_reg) begin
                pwm_out <= 1'b1;
            end else begin
                pwm_out <= 1'b0;
            end
        end
    end

endmodule