module freq_ctrl_basic(
    input  wire [2:0]  freq_sel,

    output reg  [31:0] square_freq_ctrl,
    output reg  [31:0] triangle_freq_ctrl
);

    always @(*) begin
        case (freq_sel)

            // 目标约 100Hz
            3'd0: begin
                square_freq_ctrl   = 32'd499_999;
                triangle_freq_ctrl = 32'd1_960;
            end

            // 目标约 500Hz
            3'd1: begin
                square_freq_ctrl   = 32'd99_999;
                triangle_freq_ctrl = 32'd391;
            end

            // 目标约 1kHz
            3'd2: begin
                square_freq_ctrl   = 32'd49_999;
                triangle_freq_ctrl = 32'd195;
            end

            // 目标约 2kHz
            3'd3: begin
                square_freq_ctrl   = 32'd24_999;
                triangle_freq_ctrl = 32'd97;
            end

            // 目标约 5kHz
            3'd4: begin
                square_freq_ctrl   = 32'd9_999;
                triangle_freq_ctrl = 32'd38;
            end

            // 目标约 10kHz
            3'd5: begin
                square_freq_ctrl   = 32'd4_999;
                triangle_freq_ctrl = 32'd19;
            end

            default: begin
                square_freq_ctrl   = 32'd499_999;
                triangle_freq_ctrl = 32'd1_960;
            end
        endcase
    end

endmodule