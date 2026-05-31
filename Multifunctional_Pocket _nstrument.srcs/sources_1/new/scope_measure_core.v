module scope_measure_core #(
    parameter SAMPLE_FREQ = 1_000_000
)(
    input  wire       clk,
    input  wire       rst_n,

    input  wire [7:0] adc_data,
    input  wire       adc_valid,

    output wire [31:0] period_cnt,
    output wire        period_valid,

    output wire [31:0] freq_value,

    output wire [7:0]  max_val,
    output wire [7:0]  min_val,
    output wire [7:0]  vpp,
    output wire [7:0]  mid_val,
    output wire        measure_valid
);

    freq_meter_adc #(
        .DATA_WIDTH (8),
        .THRESHOLD  (8'd128)
    ) u_freq_meter_adc (
        .clk          (clk),
        .rst_n        (rst_n),

        .adc_data     (adc_data),
        .adc_valid    (adc_valid),

        .period_cnt   (period_cnt),
        .period_valid (period_valid)
    );

    freq_calc #(
        .SAMPLE_FREQ (SAMPLE_FREQ)
    ) u_freq_calc (
        .clk          (clk),
        .rst_n        (rst_n),

        .period_cnt   (period_cnt),
        .period_valid (period_valid),

        .freq_value   (freq_value)
    );

    scope_measure #(
        .DATA_WIDTH (8),
        .WINDOW_LEN (1024)
    ) u_scope_measure (
        .clk           (clk),
        .rst_n         (rst_n),

        .adc_data      (adc_data),
        .sample_valid  (adc_valid),

        .max_val       (max_val),
        .min_val       (min_val),
        .vpp           (vpp),
        .mid_val       (mid_val),
        .measure_valid (measure_valid)
    );

endmodule