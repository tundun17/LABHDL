`timescale 1ns / 1ps
module top #(
    parameter W = 430, 
    parameter H = 554  
) (
    input clk,
    input rst, 
    input [7:0] pixel_in,
    output [7:0] pixel_out,
    output valid_out,
    output [9:0] x_pos_out,
    output [9:0] y_pos_out
);
    reg [7:0] temp0 [0:W-1];
    reg [7:0] temp1 [0:W-1];
    reg [9:0] x_pos, y_pos;
    
    // OUTPUT DEBUG
    assign x_pos_out = x_pos;
    assign y_pos_out = y_pos;

    wire [7:0] d0, d1, d2;
    assign d2 = pixel_in;      
    assign d1 = temp0[x_pos];  
    assign d0 = temp1[x_pos];  

    always @(posedge clk) begin
        temp0[x_pos] <= d2;
        temp1[x_pos] <= d1;
    end

    reg [7:0] p0, p1, p2; 
    reg [7:0] p3, p4, p5; 
    reg [7:0] p6, p7, p8; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            x_pos <= 0; y_pos <= 0;
            p0<=0; p1<=0; p2<=0;
            p3<=0; p4<=0; p5<=0;
            p6<=0; p7<=0; p8<=0;
        end else begin
            if (x_pos < W-1) begin
                x_pos <= x_pos + 1;
            end else begin
                x_pos <= 0;
                if (y_pos < H-1) y_pos <= y_pos + 1;
                else y_pos <= 0;
            end
            
            p2 <= d0; p5 <= d1; p8 <= d2;
            p1 <= p2; p4 <= p5; p7 <= p8;
            p0 <= p1; p3 <= p4; p6 <= p7;
        end
    end

    assign valid_out = (x_pos >= 2 && y_pos >= 2);
    
    median_filter core ( 
        .p0(p0), .p1(p1), .p2(p2), 
        .p3(p3), .p4(p4), .p5(p5),
        .p6(p6), .p7(p7), .p8(p8),
        .out(pixel_out)
    );
endmodule