module vga_grid_test(
    input  wire       video_on,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,

    output reg  [3:0] vga_r,
    output reg  [3:0] vga_g,
    output reg  [3:0] vga_b
);

    wire border;
    wire axis_x;
    wire axis_y;
    wire grid_x;
    wire grid_y;

    assign border = (pixel_x == 10'd0)   ||
                    (pixel_x == 10'd639) ||
                    (pixel_y == 10'd0)   ||
                    (pixel_y == 10'd479);

    assign axis_x = (pixel_x == 10'd320);
    assign axis_y = (pixel_y == 10'd240);

    assign grid_x = (pixel_x % 40 == 0);
    assign grid_y = (pixel_y % 40 == 0);

    always @(*) begin
        if (!video_on) begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end else if (border) begin
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'hF;
        end else if (axis_x || axis_y) begin
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (grid_x || grid_y) begin
            vga_r = 4'h3;
            vga_g = 4'h3;
            vga_b = 4'h3;
        end else begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end
    end

endmodule