module adc_interface_stub (
    input  wire        clk,
    input  wire        rst_n,

    output reg  [7:0]  adc_ch1_data,
    output reg  [7:0]  adc_ch2_data,
    output reg         adc_valid
);

    reg [7:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt          <= 8'd0;
            adc_ch1_data <= 8'd128;
            adc_ch2_data <= 8'd128;
            adc_valid    <= 1'b0;
        end else begin
            cnt <= cnt + 1'b1;

            // 第一版：每个时钟都认为有一个有效采样
            adc_valid <= 1'b1;

            // CH1：简单上升锯齿
            adc_ch1_data <= cnt;

            // CH2：相位错开的锯齿，先用来验证双通道链路
            adc_ch2_data <= cnt + 8'd64;
        end
    end

endmodule