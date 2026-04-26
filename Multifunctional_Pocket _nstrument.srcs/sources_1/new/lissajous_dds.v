module lissajous_dds #(
    parameter PHASE_WIDTH = 24,
    parameter DATA_WIDTH  = 8
)(
    input  wire clk,
    input  wire rst_n,

    input  wire [PHASE_WIDTH-1:0] phase_step_x,
    input  wire [PHASE_WIDTH-1:0] phase_step_y,
    input  wire [PHASE_WIDTH-1:0] phase_offset_y,

    output reg  [DATA_WIDTH-1:0] x_out,
    output reg  [DATA_WIDTH-1:0] y_out
);

    //====================================================
    // 1. 两个相位累加器
    //====================================================
    reg [PHASE_WIDTH-1:0] phase_acc_x;
    reg [PHASE_WIDTH-1:0] phase_acc_y;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc_x <= 0;
            phase_acc_y <= 0;
        end else begin
            phase_acc_x <= phase_acc_x + phase_step_x;
            phase_acc_y <= phase_acc_y + phase_step_y;
        end
    end

    //====================================================
    // 2. 相位偏移
    //====================================================
    wire [PHASE_WIDTH-1:0] phase_y_shifted;

    assign phase_y_shifted = phase_acc_y + phase_offset_y;

    //====================================================
    // 3. 取高6位作为64点LUT地址
    //====================================================
    wire [5:0] addr_x;
    wire [5:0] addr_y;

    assign addr_x = phase_acc_x[PHASE_WIDTH-1 -: 6];
    assign addr_y = phase_y_shifted[PHASE_WIDTH-1 -: 6];

    //====================================================
    // 4. 64点正弦查表函数
    //====================================================
    function [7:0] sine_lut_64;
        input [5:0] addr;
        begin
            case (addr)
                6'd0 : sine_lut_64 = 8'd128;
                6'd1 : sine_lut_64 = 8'd140;
                6'd2 : sine_lut_64 = 8'd152;
                6'd3 : sine_lut_64 = 8'd165;
                6'd4 : sine_lut_64 = 8'd176;
                6'd5 : sine_lut_64 = 8'd188;
                6'd6 : sine_lut_64 = 8'd199;
                6'd7 : sine_lut_64 = 8'd209;
                6'd8 : sine_lut_64 = 8'd218;
                6'd9 : sine_lut_64 = 8'd226;
                6'd10: sine_lut_64 = 8'd234;
                6'd11: sine_lut_64 = 8'd240;
                6'd12: sine_lut_64 = 8'd245;
                6'd13: sine_lut_64 = 8'd250;
                6'd14: sine_lut_64 = 8'd253;
                6'd15: sine_lut_64 = 8'd255;
                6'd16: sine_lut_64 = 8'd255;
                6'd17: sine_lut_64 = 8'd255;
                6'd18: sine_lut_64 = 8'd253;
                6'd19: sine_lut_64 = 8'd250;
                6'd20: sine_lut_64 = 8'd245;
                6'd21: sine_lut_64 = 8'd240;
                6'd22: sine_lut_64 = 8'd234;
                6'd23: sine_lut_64 = 8'd226;
                6'd24: sine_lut_64 = 8'd218;
                6'd25: sine_lut_64 = 8'd209;
                6'd26: sine_lut_64 = 8'd199;
                6'd27: sine_lut_64 = 8'd188;
                6'd28: sine_lut_64 = 8'd176;
                6'd29: sine_lut_64 = 8'd165;
                6'd30: sine_lut_64 = 8'd152;
                6'd31: sine_lut_64 = 8'd140;
                6'd32: sine_lut_64 = 8'd128;
                6'd33: sine_lut_64 = 8'd115;
                6'd34: sine_lut_64 = 8'd103;
                6'd35: sine_lut_64 = 8'd90;
                6'd36: sine_lut_64 = 8'd79;
                6'd37: sine_lut_64 = 8'd67;
                6'd38: sine_lut_64 = 8'd56;
                6'd39: sine_lut_64 = 8'd46;
                6'd40: sine_lut_64 = 8'd37;
                6'd41: sine_lut_64 = 8'd29;
                6'd42: sine_lut_64 = 8'd21;
                6'd43: sine_lut_64 = 8'd15;
                6'd44: sine_lut_64 = 8'd10;
                6'd45: sine_lut_64 = 8'd5;
                6'd46: sine_lut_64 = 8'd2;
                6'd47: sine_lut_64 = 8'd0;
                6'd48: sine_lut_64 = 8'd0;
                6'd49: sine_lut_64 = 8'd0;
                6'd50: sine_lut_64 = 8'd2;
                6'd51: sine_lut_64 = 8'd5;
                6'd52: sine_lut_64 = 8'd10;
                6'd53: sine_lut_64 = 8'd15;
                6'd54: sine_lut_64 = 8'd21;
                6'd55: sine_lut_64 = 8'd29;
                6'd56: sine_lut_64 = 8'd37;
                6'd57: sine_lut_64 = 8'd46;
                6'd58: sine_lut_64 = 8'd56;
                6'd59: sine_lut_64 = 8'd67;
                6'd60: sine_lut_64 = 8'd79;
                6'd61: sine_lut_64 = 8'd90;
                6'd62: sine_lut_64 = 8'd103;
                6'd63: sine_lut_64 = 8'd115;
                default: sine_lut_64 = 8'd128;
            endcase
        end
    endfunction

    //====================================================
    // 5. 输出两路正弦
    //====================================================
    always @(*) begin
        x_out = sine_lut_64(addr_x);
        y_out = sine_lut_64(addr_y);
    end

endmodule