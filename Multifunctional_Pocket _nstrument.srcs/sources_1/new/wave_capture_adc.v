module wave_capture_adc #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 10
)(
    input  wire                   clk,
    input  wire                   rst_n,

    input  wire [DATA_WIDTH-1:0]  adc_data,
    input  wire                   adc_valid,

    output reg                    wr_en,
    output reg  [ADDR_WIDTH-1:0]  wr_addr,
    output reg  [DATA_WIDTH-1:0]  wr_data
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_en   <= 1'b0;
            wr_addr <= {ADDR_WIDTH{1'b0}};
            wr_data <= {DATA_WIDTH{1'b0}};
        end else begin
            wr_en <= 1'b0;

            if (adc_valid) begin
                wr_en   <= 1'b1;
                wr_data <= adc_data;

                if (wr_addr >= 10'd639)
                    wr_addr <= 10'd0;
                else
                    wr_addr <= wr_addr + 1'b1;
            end
        end
    end

endmodule