module scope_measure #(
    parameter DATA_WIDTH = 8,
    parameter WINDOW_LEN = 1024
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

    reg [31:0] sample_cnt;

    reg [DATA_WIDTH-1:0] max_temp;
    reg [DATA_WIDTH-1:0] min_temp;

    wire [DATA_WIDTH-1:0] max_next;
    wire [DATA_WIDTH-1:0] min_next;

    assign max_next = (adc_data > max_temp) ? adc_data : max_temp;
    assign min_next = (adc_data < min_temp) ? adc_data : min_temp;

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
            measure_valid <= 1'b0;

            if (sample_valid) begin

                if (sample_cnt >= WINDOW_LEN - 1) begin
                    sample_cnt <= 32'd0;

                    // 输出包含当前采样点在内的窗口结果
                    max_val <= max_next;
                    min_val <= min_next;
                    vpp     <= max_next - min_next;
                    mid_val <= (max_next + min_next) >> 1;

                    measure_valid <= 1'b1;

                    // 下一轮从初始值重新统计
                    max_temp <= {DATA_WIDTH{1'b0}};
                    min_temp <= {DATA_WIDTH{1'b1}};
                end else begin
                    sample_cnt <= sample_cnt + 1'b1;

                    max_temp <= max_next;
                    min_temp <= min_next;
                end
            end
        end
    end

endmodule