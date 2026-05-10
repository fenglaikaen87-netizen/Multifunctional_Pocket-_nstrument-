`timescale 1ns / 1ps

module tb_dac0832_driver;

    reg        clk;
    reg        rst_n;
    reg  [7:0] data_in;

    wire [7:0] dac_data;
    wire       dac_cs_n;
    wire       dac_wr1_n;
    wire       dac_wr2_n;
    wire       dac_xfer_n;
    wire       dac_byte2;

    dac0832_driver uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .data_in    (data_in),

        .dac_data   (dac_data),
        .dac_cs_n   (dac_cs_n),
        .dac_wr1_n  (dac_wr1_n),
        .dac_wr2_n  (dac_wr2_n),
        .dac_xfer_n (dac_xfer_n),
        .dac_byte2  (dac_byte2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz
    end

    initial begin
        rst_n   = 0;
        data_in = 8'd0;

        #100;
        rst_n = 1;

        #100;
        data_in = 8'd0;

        #100;
        data_in = 8'd64;

        #100;
        data_in = 8'd128;

        #100;
        data_in = 8'd192;

        #100;
        data_in = 8'd255;

        #200;
        $stop;
    end

endmodule