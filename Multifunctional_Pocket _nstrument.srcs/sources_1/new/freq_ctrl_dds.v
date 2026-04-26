module freq_ctrl_dds(
    input  wire [2:0] freq_sel,       // 频率档位选择
    output reg  [23:0] phase_step     // 输出给 DDS 的相位步进值
);

    // =========================================================
    // 这里假设：
    // 系统时钟 f_clk = 100MHz
    // 相位累加器位宽 N = 24
    //
    // 公式：
    // phase_step = f_out * 2^24 / 100000000
    //
    // 预先算好的常用频率对应值
    // =========================================================
    always @(*) begin
        case (freq_sel)

            3'd0: phase_step = 24'd17;      // 约 100Hz
            3'd1: phase_step = 24'd84;      // 约 500Hz
            3'd2: phase_step = 24'd168;     // 约 1kHz
            3'd3: phase_step = 24'd336;     // 约 2kHz
            3'd4: phase_step = 24'd839;     // 约 5kHz
            3'd5: phase_step = 24'd1678;    // 约 10kHz

            default: phase_step = 24'd17;   // 默认100Hz
        endcase
    end

endmodule