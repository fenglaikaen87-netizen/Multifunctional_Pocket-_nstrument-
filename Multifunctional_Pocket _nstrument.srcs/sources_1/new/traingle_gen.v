module triangle_gen #(
    // CNT_WIDTH: 计数器位宽
    // 用来决定 freq_ctrl 和内部计数器 cnt 的位数
    parameter CNT_WIDTH  = 32,

    // DATA_WIDTH: 三角波输出数据位宽
    // 这里设成8位，输出范围大致是 0~255
    parameter DATA_WIDTH = 8
)(
    input  wire clk,                              // 系统时钟
    input  wire rst_n,                            // 低电平有效复位信号
    input  wire [CNT_WIDTH-1:0] freq_ctrl,        // 控制三角波"更新速度"的参数
    output reg  [DATA_WIDTH-1:0] triangle_out     // 三角波输出数据
);

    // 内部计数器：
    // 作用是"分频"，不是每个时钟都改一次 triangle_out，
    // 而是等 cnt 数到 freq_ctrl 后，再更新一次 triangle_out
    reg [CNT_WIDTH-1:0] cnt;

    // dir 表示当前三角波的变化方向
    // dir = 1：向上增加
    // dir = 0：向下减少
    reg dir;

    // 主时序逻辑
    // 在每个时钟上升沿执行一次
    // 如果 rst_n = 0，则立即复位
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时，把所有内部状态恢复到初始值
            cnt          <= 0;       // 计数器清零
            triangle_out <= 0;       // 三角波输出从0开始
            dir          <= 1'b1;    // 初始方向设为"向上"
        end else begin
            // 如果计数器已经数到设定值，就更新一次三角波输出
            if (cnt >= freq_ctrl) begin
                cnt <= 0;    // 更新完之后，计数器重新开始计数

                // 如果当前方向是"向上"
                if (dir) begin
                    // 如果已经快到最大值了，就切换方向改为"向下"
                    if (triangle_out >= {DATA_WIDTH{1'b1}} - 1) begin
                        dir          <= 1'b0;                // 改成向下
                        triangle_out <= triangle_out - 1'b1; // 先往下减一步
                    end else begin
                        // 还没到顶，就继续向上加1
                        triangle_out <= triangle_out + 1'b1;
                    end

                end else begin
                    // 如果当前方向是"向下"

                    // 如果已经快到底了，就切换方向改为"向上"
                    if (triangle_out <= 1) begin
                        dir          <= 1'b1;                // 改成向上
                        triangle_out <= triangle_out + 1'b1; // 先往上加一步
                    end else begin
                        // 还没到底，就继续向下减1
                        triangle_out <= triangle_out - 1'b1;
                    end
                end

            end else begin
                // 如果 cnt 还没数到 freq_ctrl，
                // 说明还不到更新时间，只让 cnt 自增
                cnt <= cnt + 1'b1;
            end
        end
    end

endmodule