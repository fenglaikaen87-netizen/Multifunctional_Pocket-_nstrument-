`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst_n;
    reg [1:0] mode;
    reg [2:0] freq_sel;

    wire [7:0] wave_out;
    wire       pwm_out;

    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .freq_sel(freq_sel),
        .wave_out(wave_out),
        .pwm_out(pwm_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n   = 1'b0;
        mode    = 2'b00;
        freq_sel = 3'd0;

        #100;
        rst_n = 1'b1;

        // ·½²¨
        mode = 2'b00;
        freq_sel = 3'd0;
        #100000;

        freq_sel = 3'd1;
        #100000;

        // Èý½Ç²¨
        mode = 2'b01;
        freq_sel = 3'd0;
        #200000;

        freq_sel = 3'd1;
        #200000;

        // ÕýÏÒ²¨
        mode = 2'b10;
        freq_sel = 3'd0;
        #300000;

        freq_sel = 3'd1;
        #300000;

        freq_sel = 3'd2;
        #300000;

        $stop;
    end

endmodule