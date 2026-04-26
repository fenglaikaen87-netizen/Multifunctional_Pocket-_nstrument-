`timescale 1ns/1ps

module tb_top;

    reg clk;
    reg rst_n;
    reg [1:0] mode;
    reg [2:0] freq_sel;

    wire [7:0]  wave_out;
    wire        pwm_out;
    wire [31:0] period_cnt;

    //====================================================
    // 实例化顶层模块
    //====================================================
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .mode(mode),
        .freq_sel(freq_sel),
        .wave_out(wave_out),
        .pwm_out(pwm_out),
        .period_cnt(period_cnt)
    );

    //====================================================
    // 100MHz时钟
    //====================================================
    initial clk = 1'b0;
    always #5 clk = ~clk;

    //====================================================
    // 激励信号
    //====================================================
    initial begin
        rst_n    = 1'b0;
        mode     = 2'b00;   // 先选方波
        freq_sel = 3'd0;

        #100;
        rst_n = 1'b1;

        //========================
        // 测试不同频率档位下的方波周期计数
        //========================
        #50000;
        freq_sel = 3'd1;

        #50000;
        freq_sel = 3'd2;

        #50000;
        freq_sel = 3'd3;

        #50000;
        freq_sel = 3'd4;

        #50000;
        freq_sel = 3'd5;

        //========================
        // 切到别的mode也可以观察 wave_out / pwm_out
        // 但 period_cnt 现在还是测 square_out
        //========================
        #50000;
        mode = 2'b01;   // 三角波

        #50000;
        mode = 2'b10;   // 正弦波

        #50000;
        $stop;
    end

endmodule