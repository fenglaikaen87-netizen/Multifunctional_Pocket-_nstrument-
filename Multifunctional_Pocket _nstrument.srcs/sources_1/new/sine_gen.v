module sine_gen #(
    // 计数器位宽，用来控制更新速度
    parameter CNT_WIDTH  = 32,

    // 输出数据位宽，这里仍然先做成8位
    parameter DATA_WIDTH = 8
)(
    input  wire clk,                          // 系统时钟
    input  wire rst_n,                        // 低电平有效复位
    input  wire [CNT_WIDTH-1:0] freq_ctrl,    // 控制正弦波"更新速度"
    output reg  [DATA_WIDTH-1:0] sine_out     // 正弦波输出数据
);

    // =========================================================
    // 1. 内部计数器
    //    作用：分频，不是每个时钟都更新一次正弦波输出
    // =========================================================
    reg [CNT_WIDTH-1:0] cnt;

    // =========================================================
    // 2. 查表地址
    //    因为我们这里先做16点正弦表，所以地址范围是0~15
    // =========================================================
    reg [3:0] addr;

    // =========================================================
    // 3. 时序逻辑
    //    每当 cnt 数到 freq_ctrl，就把地址 addr 加1
    // =========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt  <= 0;
            addr <= 0;
        end else begin
            if (cnt >= freq_ctrl) begin
                cnt  <= 0;
                addr <= addr + 1'b1;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    // =========================================================
    // 4. 正弦查表
    //    这里直接把16个采样点写死在 case 里
    //
    //    这些值是一个"偏置后的正弦波"：
    //    最小值接近0，最大值接近255，中间值大约在128附近
    //
    //    这样后面接DAC时比较方便
    // =========================================================
    always @(*) begin
        case (addr)
            4'd0 : sine_out = 8'd128;
            4'd1 : sine_out = 8'd176;
            4'd2 : sine_out = 8'd218;
            4'd3 : sine_out = 8'd245;
            4'd4 : sine_out = 8'd255;
            4'd5 : sine_out = 8'd245;
            4'd6 : sine_out = 8'd218;
            4'd7 : sine_out = 8'd176;
            4'd8 : sine_out = 8'd128;
            4'd9 : sine_out = 8'd80;
            4'd10: sine_out = 8'd38;
            4'd11: sine_out = 8'd11;
            4'd12: sine_out = 8'd0;
            4'd13: sine_out = 8'd11;
            4'd14: sine_out = 8'd38;
            4'd15: sine_out = 8'd80;
            default: sine_out = 8'd128;
        endcase
    end

endmodule