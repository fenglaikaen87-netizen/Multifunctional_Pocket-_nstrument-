module adc_interface_stub #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,

    output reg  [DATA_WIDTH-1:0] adc_ch1_data,
    output reg  [DATA_WIDTH-1:0] adc_ch2_data,
    output reg                   adc_valid
);

    //====================================================
    // 1. 采样节拍计数器
    // 每 100 个 100MHz clk 输出一次有效采样
    // 等效采样率：100MHz / 100 = 1MHz
    //====================================================
    reg [7:0] sample_cnt;

    //====================================================
    // 2. 假 ADC 三角波数据
    //====================================================
    reg [DATA_WIDTH-1:0] wave_cnt;

    // dir = 1：上升
    // dir = 0：下降
    reg dir;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt   <= 8'd0;
            wave_cnt     <= {DATA_WIDTH{1'b0}};
            dir          <= 1'b1;

            adc_ch1_data <= {DATA_WIDTH{1'b0}};
            adc_ch2_data <= {DATA_WIDTH{1'b1}};
            adc_valid    <= 1'b0;
        end else begin
            // 默认 adc_valid 拉低
            adc_valid <= 1'b0;

            // 每 100 个 clk 产生一次 ADC 采样点
            if (sample_cnt >= 8'd99) begin
                sample_cnt <= 8'd0;
                adc_valid  <= 1'b1;

                //================================================
                // 先输出当前 wave_cnt
                //================================================
                adc_ch1_data <= wave_cnt;
                adc_ch2_data <= {DATA_WIDTH{1'b1}} - wave_cnt;

                //================================================
                // 再更新 wave_cnt，形成 00 → ff → 00 三角波
                //================================================
                if (dir) begin
                    // 上升阶段
                    if (wave_cnt >= {DATA_WIDTH{1'b1}}) begin
                        dir      <= 1'b0;
                        wave_cnt <= wave_cnt - 1'b1;
                    end else begin
                        wave_cnt <= wave_cnt + 1'b1;
                    end
                end else begin
                    // 下降阶段
                    if (wave_cnt <= {DATA_WIDTH{1'b0}}) begin
                        dir      <= 1'b1;
                        wave_cnt <= wave_cnt + 1'b1;
                    end else begin
                        wave_cnt <= wave_cnt - 1'b1;
                    end
                end

            end else begin
                sample_cnt <= sample_cnt + 1'b1;
            end
        end
    end

endmodule