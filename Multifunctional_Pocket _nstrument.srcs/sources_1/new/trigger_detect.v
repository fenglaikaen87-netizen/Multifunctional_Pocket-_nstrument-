module trigger_detect #(
    parameter DATA_WIDTH = 8,
    parameter THRESHOLD  = 8'd128
)(
    input  wire                  clk,
    input  wire                  rst_n,

    input  wire [DATA_WIDTH-1:0] adc_data,
    input  wire                  adc_valid,

    output reg                   trig_pulse
);

    reg sig_last;

    wire sig_now;
    assign sig_now = (adc_data >= THRESHOLD);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sig_last   <= 1'b0;
            trig_pulse <= 1'b0;
        end else begin
            trig_pulse <= 1'b0;

            if (adc_valid) begin
                // 上一次低于阈值，本次高于/等于阈值：触发
                if (sig_now && !sig_last) begin
                    trig_pulse <= 1'b1;
                end

                sig_last <= sig_now;
            end
        end
    end

endmodule