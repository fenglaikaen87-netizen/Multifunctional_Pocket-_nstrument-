module pwm_out #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,       // 系统时钟
    input  wire                  rst_n,     // 低电平有效复位
    input  wire [DATA_WIDTH-1:0] duty_in,   // 占空比输入（对应 wave_out）
    output reg                   pwm_out    // PWM输出
);

    reg [DATA_WIDTH-1:0] pwm_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_cnt <= {DATA_WIDTH{1'b0}};
            pwm_out <= 1'b0;
        end else begin
            pwm_cnt <= pwm_cnt + 1'b1;

            if (pwm_cnt < duty_in)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;
        end
    end

endmodule