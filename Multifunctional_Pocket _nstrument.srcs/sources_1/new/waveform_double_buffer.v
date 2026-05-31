module waveform_double_buffer #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter FRAME_LEN  = 640
)(
    input  wire                   clk,
    input  wire                   rst_n,

    //====================================================
    // 写端口：ADC 采集侧
    //====================================================
    input  wire                   wr_en,
    input  wire [ADDR_WIDTH-1:0]  wr_addr,
    input  wire [DATA_WIDTH-1:0]  wr_data,

    // 一帧采集完成脉冲
    input  wire                   frame_done,

    // VGA 新一帧开始，用于安全交换 buffer
    input  wire                   vga_frame_start,

    //====================================================
    // 读端口：VGA 显示侧
    //====================================================
    input  wire [ADDR_WIDTH-1:0]  rd_addr,
    output reg  [DATA_WIDTH-1:0]  rd_data,

    //====================================================
    // 调试信号
    //====================================================
    output reg                    display_bank,
    output reg                    write_bank,
    output reg                    swap_pending,
    output wire                   capture_enable
);

    reg [DATA_WIDTH-1:0] mem0 [0:FRAME_LEN-1];
    reg [DATA_WIDTH-1:0] mem1 [0:FRAME_LEN-1];

    integer i;

    initial begin
        for (i = 0; i < FRAME_LEN; i = i + 1) begin
            mem0[i] = 8'd128;
            mem1[i] = 8'd128;
        end
    end

    assign capture_enable = ~swap_pending;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            display_bank <= 1'b0;
            write_bank   <= 1'b1;
            swap_pending <= 1'b0;
            rd_data      <= 8'd128;
        end else begin

            //================================================
            // 1. 写入当前 write_bank
            //================================================
            if (wr_en) begin
                if (wr_addr < FRAME_LEN) begin
                    if (write_bank == 1'b0)
                        mem0[wr_addr] <= wr_data;
                    else
                        mem1[wr_addr] <= wr_data;
                end
            end

            //================================================
            // 2. VGA 根据 rd_addr 读取当前 display_bank
            //================================================
            if (rd_addr < FRAME_LEN) begin
                if (display_bank == 1'b0)
                    rd_data <= mem0[rd_addr];
                else
                    rd_data <= mem1[rd_addr];
            end else begin
                rd_data <= 8'd128;
            end

            //================================================
            // 3. 一帧采完后，提出交换请求
            //================================================
            if (frame_done) begin
                swap_pending <= 1'b1;
            end

            //================================================
            // 4. 只在 VGA 新一帧开始时交换 buffer
            //================================================
            if (vga_frame_start && swap_pending) begin
                display_bank <= write_bank;
                write_bank   <= display_bank;
                swap_pending <= 1'b0;
            end
        end
    end

endmodule