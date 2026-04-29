module freq_calc #(
    parameter SAMPLE_FREQ = 1_000_000
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire [31:0] period_cnt,
    input  wire        period_valid,

    output reg  [31:0] freq_value
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq_value <= 32'd0;
        end else begin
            if (period_valid) begin
                if (period_cnt != 32'd0)
                    freq_value <= SAMPLE_FREQ / period_cnt;
                else
                    freq_value <= 32'd0;
            end
        end
    end

endmodule