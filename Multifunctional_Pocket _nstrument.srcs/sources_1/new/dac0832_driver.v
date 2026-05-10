module dac0832_driver (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,

    output reg  [7:0] dac_data,
    output wire       dac_cs_n,
    output wire       dac_wr1_n,
    output wire       dac_wr2_n,
    output wire       dac_xfer_n,
    output wire       dac_byte2
);

    // DAC0832 flow-through / 直通模式
    // CS, WR1, WR2, XFER 拉低
    // ILE / BYTE2 拉高
    assign dac_cs_n   = 1'b0;
    assign dac_wr1_n  = 1'b0;
    assign dac_wr2_n  = 1'b0;
    assign dac_xfer_n = 1'b0;
    assign dac_byte2  = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dac_data <= 8'd128;
        end else begin
            dac_data <= data_in;
        end
    end

endmodule