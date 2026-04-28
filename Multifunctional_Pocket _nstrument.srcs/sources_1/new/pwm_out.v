module pwm_out #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,       // 系统时钟
    input  wire                  rst_n,     // 低电平有效复位
    input  wire [DATA_WIDTH-1:0] duty_in,   // 占空比输入，对应 wave_out
    output reg                   pwm_out    // PWM输出
);

    // PWM计数器：8bit时，PWM周期为256个clk
    reg [DATA_WIDTH-1:0] pwm_cnt;

    // 锁存后的占空比
    // 目的：保证一个PWM周期内只使用同一个duty值
    reg [DATA_WIDTH-1:0] duty_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_cnt  <= {DATA_WIDTH{1'b0}};
            duty_reg <= {DATA_WIDTH{1'b0}};
            pwm_out  <= 1'b0;
        end else begin
            // 计数器自由递增，溢出后自动回到0
            pwm_cnt <= pwm_cnt + 1'b1;

            // 在每个PWM周期起点锁存一次 duty_in
            // 这样 duty_in 中途变化不会影响当前周期
            if (pwm_cnt == {DATA_WIDTH{1'b0}}) begin
                duty_reg <= duty_in;
            end

            // 用锁存后的 duty_reg 比较，而不是直接用 duty_in
            if (pwm_cnt < duty_reg)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;
        end
    end

endmodule