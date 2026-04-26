module square_gen #(
    parameter CNT_WIDTH = 32
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [CNT_WIDTH-1:0] freq_ctrl, // ·ÖÆµãÐÖµ
    output reg  square_out
);

reg [CNT_WIDTH-1:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
        square_out <= 0;
    end else begin
        if (cnt >= freq_ctrl) begin
            cnt <= 0;
            square_out <= ~square_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
end

endmodule