module waveform_buffer #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10
)(
    input  wire                   clk,

    // 写端口：采样侧写入
    input  wire                   wr_en,
    input  wire [ADDR_WIDTH-1:0]  wr_addr,
    input  wire [DATA_WIDTH-1:0]  wr_data,

    // 读端口：VGA 根据 pixel_x 读取
    input  wire [ADDR_WIDTH-1:0]  rd_addr,
    output reg  [DATA_WIDTH-1:0]  rd_data
);

    // 640 点足够显示一行波形
    reg [DATA_WIDTH-1:0] mem [0:639];

    always @(posedge clk) begin
        if (wr_en) begin
            if (wr_addr < 10'd640)
                mem[wr_addr] <= wr_data;
        end

        if (rd_addr < 10'd640)
            rd_data <= mem[rd_addr];
        else
            rd_data <= 8'd128;
    end

endmodule