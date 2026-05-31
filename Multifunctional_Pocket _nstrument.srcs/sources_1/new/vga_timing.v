module vga_timing(
    input  wire       pclk,       // VGA 像素时钟，仿真中用 25MHz
    input  wire       rst_n,

    output reg        hsync,
    output reg        vsync,
    output wire       video_on,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y
);

    //====================================================
    // 640x480 @ 60Hz VGA 标准时序
    // pclk ≈ 25MHz
    //====================================================

    // 水平方向
    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    // 垂直方向
    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    reg [9:0] h_cnt;
    reg [9:0] v_cnt;

    //====================================================
    // 行计数 / 场计数
    //====================================================
    always @(posedge pclk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 10'd0;

                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 10'd0;
                else
                    v_cnt <= v_cnt + 1'b1;

            end else begin
                h_cnt <= h_cnt + 1'b1;
            end
        end
    end

    //====================================================
    // HSYNC / VSYNC
    // VGA 同步信号一般低有效
    //====================================================
    always @(*) begin
        if (h_cnt >= H_VISIBLE + H_FRONT &&
            h_cnt <  H_VISIBLE + H_FRONT + H_SYNC)
            hsync = 1'b0;
        else
            hsync = 1'b1;
    end

    always @(*) begin
        if (v_cnt >= V_VISIBLE + V_FRONT &&
            v_cnt <  V_VISIBLE + V_FRONT + V_SYNC)
            vsync = 1'b0;
        else
            vsync = 1'b1;
    end

    assign video_on = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    assign pixel_x = h_cnt;
    assign pixel_y = v_cnt;

endmodule