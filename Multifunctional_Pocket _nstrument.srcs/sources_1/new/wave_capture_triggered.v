module wave_capture_triggered #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter FRAME_LEN  = 640
)(
    input  wire                   clk,
    input  wire                   rst_n,

    input  wire                   capture_enable,

    input  wire [DATA_WIDTH-1:0]  adc_data,
    input  wire                   adc_valid,
    input  wire                   trig_pulse,

    output reg                    wr_en,
    output reg  [ADDR_WIDTH-1:0]  wr_addr,
    output reg  [DATA_WIDTH-1:0]  wr_data,

    output reg                    capturing,
    output reg                    frame_done
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_en      <= 1'b0;
            wr_addr    <= {ADDR_WIDTH{1'b0}};
            wr_data    <= {DATA_WIDTH{1'b0}};
            capturing  <= 1'b0;
            frame_done <= 1'b0;
        end else begin
            wr_en      <= 1'b0;
            frame_done <= 1'b0;

            //================================================
            // 1. 等待触发
            //    只有 capture_enable = 1 时才允许开始新一帧
            //================================================
            if (!capturing) begin
                if (capture_enable && trig_pulse) begin
                    capturing <= 1'b1;
                    wr_addr   <= {ADDR_WIDTH{1'b0}};
                end
            end

            //================================================
            // 2. 触发后采集一整帧
            //================================================
            else begin
                if (adc_valid) begin
                    wr_en   <= 1'b1;
                    wr_data <= adc_data;

                    if (wr_addr >= FRAME_LEN - 1) begin
                        wr_addr    <= {ADDR_WIDTH{1'b0}};
                        capturing  <= 1'b0;
                        frame_done <= 1'b1;
                    end else begin
                        wr_addr <= wr_addr + 1'b1;
                    end
                end
            end
        end
    end

endmodule