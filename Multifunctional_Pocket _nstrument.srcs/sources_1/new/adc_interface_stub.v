module freq_meter_adc #(
    parameter DATA_WIDTH = 8,
    parameter THRESHOLD  = 128
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [DATA_WIDTH-1:0] adc_data,
    input  wire                  adc_valid,

    output reg  [31:0]           period_cnt,
    output reg                   period_valid
);

    //====================================================
    // 1. 当前采样点是否超过阈值
    //====================================================
    wire sig_now;
    assign sig_now = (adc_data >= THRESHOLD);

    //====================================================
    // 2. 上一个有效采样点的过阈值状态
    //====================================================
    reg sig_last;

    //====================================================
    // 3. 周期计数器
    //====================================================
    reg [31:0] cnt_run;
    reg        counting;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_last     <= 1'b0;
            cnt_run      <= 32'd0;
            period_cnt   <= 32'd0;
            period_valid <= 1'b0;
            counting     <= 1'b0;
        end else begin
            // 默认 period_valid 只打一拍
            period_valid <= 1'b0;

            // 只在 adc_valid 有效时处理一次采样
            if (adc_valid) begin

                // 如果已经开始计数，则每来一个有效采样点加 1
                if (counting) begin
                    cnt_run <= cnt_run + 1'b1;
                end

                // 检测"有效采样点之间"的上升沿
                // sig_last 是上一个 adc_valid 时的状态
                // sig_now  是当前 adc_valid 时的状态
                if (sig_now && !sig_last) begin

                    // 第一次上升沿：只启动计数
                    if (!counting) begin
                        counting <= 1'b1;
                        cnt_run  <= 32'd0;
                    end

                    // 第二次及以后上升沿：输出周期
                    else begin
                        period_cnt   <= cnt_run;
                        period_valid <= 1'b1;
                        cnt_run      <= 32'd0;
                    end
                end

                // 更新"上一有效采样点状态"
                sig_last <= sig_now;
            end
        end
    end

endmodule