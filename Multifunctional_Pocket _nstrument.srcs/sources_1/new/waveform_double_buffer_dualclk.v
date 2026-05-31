module waveform_double_buffer_dualclk #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10,
    parameter FRAME_LEN  = 640
)(
    //====================================================
    // 写端：系统时钟域，100MHz
    //====================================================
    input  wire                   sys_clk,
    input  wire                   rst_n,

    input  wire                   wr_en,
    input  wire [ADDR_WIDTH-1:0]  wr_addr,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    input  wire                   frame_done,

    output wire                   capture_enable,

    //====================================================
    // 读端：VGA 时钟域，25MHz
    //====================================================
    input  wire                   vga_clk,
    input  wire                   vga_frame_start,
    input  wire [ADDR_WIDTH-1:0]  rd_addr,
    output reg  [DATA_WIDTH-1:0]  rd_data,

    //====================================================
    // 调试信号
    //====================================================
    output reg                    display_bank,
    output reg                    write_bank,
    output reg                    swap_pending
);

    //====================================================
    // 双 buffer 存储区
    // mem0 / mem1 各存一帧 640 点
    //====================================================
    reg [DATA_WIDTH-1:0] mem0 [0:FRAME_LEN-1];
    reg [DATA_WIDTH-1:0] mem1 [0:FRAME_LEN-1];

    integer i;

    initial begin
        for (i = 0; i < FRAME_LEN; i = i + 1) begin
            mem0[i] = 8'd128;
            mem1[i] = 8'd128;
        end
    end

    //====================================================
    // sys_clk 域：交换请求 toggle
    //====================================================
    reg swap_req_toggle;

    // VGA 域返回的 ack toggle，同步到 sys_clk 域
    reg swap_ack_sync1;
    reg swap_ack_sync2;
    reg swap_ack_last;

    //====================================================
    // VGA 域：同步 sys_clk 域来的 req toggle
    //====================================================
    reg swap_req_sync1;
    reg swap_req_sync2;
    reg swap_req_last;

    reg swap_ack_toggle;

    // 有未交换的新帧时，禁止下一次采集
    assign capture_enable = ~swap_pending;

    //====================================================
    // 1. sys_clk 域：写 buffer + 发出交换请求
    //====================================================
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            write_bank      <= 1'b1;
            swap_pending    <= 1'b0;
            swap_req_toggle <= 1'b0;

            swap_ack_sync1  <= 1'b0;
            swap_ack_sync2  <= 1'b0;
            swap_ack_last   <= 1'b0;
        end else begin
            // 同步 VGA 域 ack
            swap_ack_sync1 <= swap_ack_toggle;
            swap_ack_sync2 <= swap_ack_sync1;

            // 写入当前 write_bank
            if (wr_en) begin
                if (wr_addr < FRAME_LEN) begin
                    if (write_bank == 1'b0)
                        mem0[wr_addr] <= wr_data;
                    else
                        mem1[wr_addr] <= wr_data;
                end
            end

            // 一帧写完，发出交换请求
            if (frame_done && !swap_pending) begin
                swap_pending    <= 1'b1;
                swap_req_toggle <= ~swap_req_toggle;
            end

            // 收到 VGA 域 ack 后，说明显示 buffer 已经切换
            // 此时写端切到另一块 buffer，允许下一轮采集
            if (swap_ack_sync2 != swap_ack_last) begin
                swap_ack_last <= swap_ack_sync2;

                if (swap_pending) begin
                    write_bank   <= ~write_bank;
                    swap_pending <= 1'b0;
                end
            end
        end
    end

    //====================================================
    // 2. vga_clk 域：读 buffer + 在帧边界交换显示 buffer
    //====================================================
    always @(posedge vga_clk or negedge rst_n) begin
        if (!rst_n) begin
            display_bank    <= 1'b0;
            rd_data         <= 8'd128;

            swap_req_sync1  <= 1'b0;
            swap_req_sync2  <= 1'b0;
            swap_req_last   <= 1'b0;
            swap_ack_toggle <= 1'b0;
        end else begin
            // 同步 sys_clk 域来的 req
            swap_req_sync1 <= swap_req_toggle;
            swap_req_sync2 <= swap_req_sync1;

            // VGA 读取当前 display_bank
            if (rd_addr < FRAME_LEN) begin
                if (display_bank == 1'b0)
                    rd_data <= mem0[rd_addr];
                else
                    rd_data <= mem1[rd_addr];
            end else begin
                rd_data <= 8'd128;
            end

            // 只有在 VGA 新一帧开始时才交换显示 buffer
            if (vga_frame_start && (swap_req_sync2 != swap_req_last)) begin
                swap_req_last   <= swap_req_sync2;
                display_bank    <= ~display_bank;
                swap_ack_toggle <= ~swap_ack_toggle;
            end
        end
    end

endmodule