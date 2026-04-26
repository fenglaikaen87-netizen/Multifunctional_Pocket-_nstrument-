module freq_ctrl_basic(
    input  wire [2:0] freq_sel,
    output reg  [31:0] freq_ctrl
);

    always @(*) begin
        case (freq_sel)
            3'd0: freq_ctrl = 32'd100000; // ×îµÍÆµ
            3'd1: freq_ctrl = 32'd50000;
            3'd2: freq_ctrl = 32'd20000;
            3'd3: freq_ctrl = 32'd10000;
            3'd4: freq_ctrl = 32'd5000;
            3'd5: freq_ctrl = 32'd2000;   // ×î¸ßÆµ

            default: freq_ctrl = 32'd100000;
        endcase
    end

endmodule