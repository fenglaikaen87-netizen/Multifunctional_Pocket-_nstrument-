module freq_meter (
    input  wire        clk,         // 系统时钟
    input  wire        rst_n,       // 低电平有效复位
    input  wire        sig_in,      // 被测信号输入（先接方波最合适）
    output reg [31:0]  period_cnt   // 测得的周期计数值
);

    //====================================================
    // 1. 对输入信号打一拍，用于边沿检测
    //====================================================
    reg sig_in_d;   // 上一拍的信号值

    //====================================================
    // 2. 周期计数器
    // cnt_run：当前周期内部正在计数
    // counting：是否已经检测到第一个上升沿并开始测量
    //====================================================
    reg [31:0] cnt_run;
    reg        counting;

    //====================================================
    // 3. 上升沿检测
    // 条件：上一拍为0，当前拍为1
    //====================================================
    wire rise_edge;
    assign rise_edge = (~sig_in_d) & sig_in;

    //====================================================
    // 4. 主时序逻辑
    //====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_in_d    <= 1'b0;
            cnt_run     <= 32'd0;
            period_cnt  <= 32'd0;
            counting    <= 1'b0;
        end else begin
            // 先保存上一拍信号，用于下一拍边沿检测
            sig_in_d <= sig_in;

            // 如果已经开始测量，则每拍都加1
            if (counting) begin
                cnt_run <= cnt_run + 1'b1;
            end

            // 检测到上升沿时的处理
            if (rise_edge) begin
                if (!counting) begin
                    // 第一次检测到上升沿：开始计数
                    counting <= 1'b1;
                    cnt_run  <= 32'd0;
                end else begin
                    // 第二次及以后检测到上升沿：
                    // 说明一个周期结束，把当前计数值保存
                    period_cnt <= cnt_run;

                    // 重新开始下一周期计数
                    cnt_run <= 32'd0;
                end
            end
        end
    end

endmodule