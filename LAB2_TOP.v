module top #(
    parameter W = 430, 
    parameter H = 554  
) (
    input clk,
    input rst, 
    input [7:0] p0, p1, p2,
    input [7:0] p3, p4, p5,
    input [7:0] p6, p7, p8,

    output [7:0] pixel_out,
    output reg [9:0] x_pos,
    output reg [9:0] y_pos,
    

    output valid_out 
);

    // --- LOGIC 1: COUNTER (GIỮ NGUYÊN) ---
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            x_pos <= 0;
            y_pos <= 0;
        end else begin
            if (x_pos < W-1) begin
                x_pos <= x_pos + 1;
            end else begin
                x_pos <= 0;
                if (y_pos < H-1) begin 
                    y_pos <= y_pos + 1;
                end else begin
                    y_pos <= 0;
                end
            end
        end
    end

    assign valid_out = (x_pos >= 1 && x_pos < W-1 && y_pos >= 1 && y_pos < H-1);

    median_filter core ( 
        .p0(p0), .p1(p1), .p2(p2), 
        .p3(p3), .p4(p4), .p5(p5),
        .p6(p6), .p7(p7), .p8(p8),
        .out(pixel_out)
    );

endmodule