module scope_measure #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_LEN = 100000
)(
    input  wire                    clk,
    input  wire                    rst_n,

    input  wire [DATA_WIDTH-1:0]   adc_data,
    input  wire                    sample_valid,

    output reg  [DATA_WIDTH-1:0]   max_val,
    output reg  [DATA_WIDTH-1:0]   min_val,
    output reg  [DATA_WIDTH-1:0]   vpp,
    output reg  [DATA_WIDTH-1:0]   mid_val,
    output reg                     measure_valid
);

    //====================================================
    // 1. 统计窗口计数器
    //====================================================
    reg [31:0] sample_cnt;

    //====================================================
    // 2. 当前窗口内的临时最大值 / 最小值
    //====================================================
    reg [DATA_WIDTH-1:0] max_temp;
    reg [DATA_WIDTH-1:0] min_temp;

    //====================================================
    // 3. 主逻辑
    //====================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt    <= 32'd0;
            max_temp      <= {DATA_WIDTH{1'b0}};
            min_temp      <= {DATA_WIDTH{1'b1}};

            max_val       <= {DATA_WIDTH{1'b0}};
            min_val       <= {DATA_WIDTH{1'b0}};
            vpp           <= {DATA_WIDTH{1'b0}};
            mid_val       <= {DATA_WIDTH{1'b0}};
            measure_valid <= 1'b0;
        end else begin
            // 默认拉低，只在一整个窗口统计结束时拉高一拍
            measure_valid <= 1'b0;

            if (sample_valid) begin

                // 更新窗口内最大值
                if (adc_data > max_temp)
                    max_temp <= adc_data;

                // 更新窗口内最小值
                if (adc_data < min_temp)
                    min_temp <= adc_data;

                // 窗口计数
                if (sample_cnt >= WINDOW_LEN - 1) begin
                    sample_cnt <= 32'd0;

                    // 锁存本窗口测量结果
                    max_val <= max_temp;
                    min_val <= min_temp;
                    vpp     <= max_temp - min_temp;
                    mid_val <= (max_temp + min_temp) >> 1;

                    measure_valid <= 1'b1;

                    // 开始下一轮统计
                    max_temp <= {DATA_WIDTH{1'b0}};
                    min_temp <= {DATA_WIDTH{1'b1}};
                end else begin
                    sample_cnt <= sample_cnt + 1'b1;
                end
            end
        end
    end

endmodule