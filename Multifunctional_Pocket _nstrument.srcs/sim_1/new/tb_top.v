`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst_n;

    reg [1:0] mode;
    reg [2:0] freq_sel;

    wire [7:0] wave_out;
    wire       pwm_out;

    wire [7:0] dac_data;
    wire       dac_cs_n;
    wire       dac_wr1_n;
    wire       dac_wr2_n;
    wire       dac_xfer_n;
    wire       dac_byte2;

    top uut (
        .clk        (clk),
        .rst_n      (rst_n),

        .mode       (mode),
        .freq_sel   (freq_sel),

        .wave_out   (wave_out),
        .pwm_out    (pwm_out),

        .dac_data   (dac_data),
        .dac_cs_n   (dac_cs_n),
        .dac_wr1_n  (dac_wr1_n),
        .dac_wr2_n  (dac_wr2_n),
        .dac_xfer_n (dac_xfer_n),
        .dac_byte2  (dac_byte2)
    );

    // 100MHz 时钟
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n    = 0;
        mode     = 2'b00;
        freq_sel = 3'd0;

        #100;
        rst_n = 1;

        // 方波
        mode = 2'b00;
        freq_sel = 3'd0;
        #200000;

        // 三角波
        mode = 2'b01;
        freq_sel = 3'd0;
        #200000;

        // 正弦波
        mode = 2'b10;
        freq_sel = 3'd0;
        #200000;

        // 改频率档位
        freq_sel = 3'd2;
        #200000;

        freq_sel = 3'd5;
        #200000;

        $stop;
    end

endmodule