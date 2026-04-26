module dds_sine_gen #(
    parameter PHASE_WIDTH = 24,
    parameter DATA_WIDTH  = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [PHASE_WIDTH-1:0] phase_step,
    output reg  [DATA_WIDTH-1:0] sine_out
);

    // 相位累加器
    reg [PHASE_WIDTH-1:0] phase_acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase_acc <= 0;
        else
            phase_acc <= phase_acc + phase_step;
    end

    // 64点查表地址：取相位高6位
    wire [5:0] rom_addr;
    assign rom_addr = phase_acc[PHASE_WIDTH-1 -: 6];

    // 64点8位正弦表，范围约 0~255，中心值 128
    always @(*) begin
        case (rom_addr)
            6'd0  : sine_out = 8'd128;
            6'd1  : sine_out = 8'd140;
            6'd2  : sine_out = 8'd153;
            6'd3  : sine_out = 8'd165;
            6'd4  : sine_out = 8'd176;
            6'd5  : sine_out = 8'd188;
            6'd6  : sine_out = 8'd198;
            6'd7  : sine_out = 8'd208;
            6'd8  : sine_out = 8'd218;
            6'd9  : sine_out = 8'd226;
            6'd10 : sine_out = 8'd234;
            6'd11 : sine_out = 8'd240;
            6'd12 : sine_out = 8'd245;
            6'd13 : sine_out = 8'd250;
            6'd14 : sine_out = 8'd253;
            6'd15 : sine_out = 8'd254;
            6'd16 : sine_out = 8'd255;
            6'd17 : sine_out = 8'd254;
            6'd18 : sine_out = 8'd253;
            6'd19 : sine_out = 8'd250;
            6'd20 : sine_out = 8'd245;
            6'd21 : sine_out = 8'd240;
            6'd22 : sine_out = 8'd234;
            6'd23 : sine_out = 8'd226;
            6'd24 : sine_out = 8'd218;
            6'd25 : sine_out = 8'd208;
            6'd26 : sine_out = 8'd198;
            6'd27 : sine_out = 8'd188;
            6'd28 : sine_out = 8'd176;
            6'd29 : sine_out = 8'd165;
            6'd30 : sine_out = 8'd153;
            6'd31 : sine_out = 8'd140;
            6'd32 : sine_out = 8'd128;
            6'd33 : sine_out = 8'd115;
            6'd34 : sine_out = 8'd102;
            6'd35 : sine_out = 8'd90;
            6'd36 : sine_out = 8'd79;
            6'd37 : sine_out = 8'd67;
            6'd38 : sine_out = 8'd57;
            6'd39 : sine_out = 8'd47;
            6'd40 : sine_out = 8'd37;
            6'd41 : sine_out = 8'd29;
            6'd42 : sine_out = 8'd21;
            6'd43 : sine_out = 8'd15;
            6'd44 : sine_out = 8'd10;
            6'd45 : sine_out = 8'd5;
            6'd46 : sine_out = 8'd2;
            6'd47 : sine_out = 8'd1;
            6'd48 : sine_out = 8'd0;
            6'd49 : sine_out = 8'd1;
            6'd50 : sine_out = 8'd2;
            6'd51 : sine_out = 8'd5;
            6'd52 : sine_out = 8'd10;
            6'd53 : sine_out = 8'd15;
            6'd54 : sine_out = 8'd21;
            6'd55 : sine_out = 8'd29;
            6'd56 : sine_out = 8'd37;
            6'd57 : sine_out = 8'd47;
            6'd58 : sine_out = 8'd57;
            6'd59 : sine_out = 8'd67;
            6'd60 : sine_out = 8'd79;
            6'd61 : sine_out = 8'd90;
            6'd62 : sine_out = 8'd102;
            6'd63 : sine_out = 8'd115;
            default: sine_out = 8'd128;
        endcase
    end

endmodule