module freq_meter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sig_in,

    output reg [31:0]  period_cnt,
    output reg         period_valid
);

    //====================================================
    // 1. 输入信号打一拍，用于上升沿检测
    //====================================================
    reg sig_in_d;

    wire rise_edge;
    assign rise_edge = (~sig_in_d) & sig_in;

    //====================================================
    // 2. 周期计数器
    //====================================================
    reg [31:0] cnt_run;
    reg        counting;

    //====================================================
    // 3. 主逻辑
    //====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_in_d     <= 1'b0;
            cnt_run      <= 32'd0;
            period_cnt   <= 32'd0;
            counting     <= 1'b0;
            period_valid <= 1'b0;
        end else begin
            sig_in_d <= sig_in;

            // 默认拉低，只在测到新周期那一拍拉高
            period_valid <= 1'b0;

            if (counting) begin
                cnt_run <= cnt_run + 1'b1;
            end

            if (rise_edge) begin
                if (!counting) begin
                    // 第一次上升沿：开始计数
                    counting <= 1'b1;
                    cnt_run  <= 32'd0;
                end else begin
                    // 第二次及之后的上升沿：锁存周期
                    period_cnt   <= cnt_run;
                    period_valid <= 1'b1;
                    cnt_run      <= 32'd0;
                end
            end
        end
    end

endmodule