module freq_meter_adc #(
    parameter DATA_WIDTH = 8,
    parameter THRESHOLD  = 8'd128
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [DATA_WIDTH-1:0] adc_data,
    input  wire                  adc_valid,

    output reg  [31:0]           period_cnt,
    output reg                   period_valid
);

    reg sig_bin;
    reg sig_bin_d;

    wire rising_edge;
    assign rising_edge = sig_bin & ~sig_bin_d;

    reg [31:0] cnt_run;
    reg        counting;

    // ADC数据转单bit过阈值信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_bin <= 1'b0;
        end else if (adc_valid) begin
            sig_bin <= (adc_data > THRESHOLD);
        end
    end

    // 延迟一拍，用于边沿检测
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_bin_d <= 1'b0;
        end else begin
            sig_bin_d <= sig_bin;
        end
    end

    // 周期计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_run      <= 32'd0;
            period_cnt   <= 32'd0;
            period_valid <= 1'b0;
            counting     <= 1'b0;
        end else begin
            period_valid <= 1'b0;   // 默认只打一拍

            if (adc_valid) begin
                if (counting) begin
                    cnt_run <= cnt_run + 1'b1;
                end

                if (rising_edge) begin
                    if (!counting) begin
                        counting <= 1'b1;
                        cnt_run  <= 32'd0;
                    end else begin
                        period_cnt   <= cnt_run;
                        period_valid <= 1'b1;
                        cnt_run      <= 32'd0;
                    end
                end
            end
        end
    end

endmodule