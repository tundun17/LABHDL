module rgb2gray (
    input clk,
    input rst,
    input [7:0] R,
    input [7:0] G,
    input [7:0] B,
    input [7:0] brightness, // Do sang 

    output reg [7:0] gray_out,
    output reg valid_out
);

    reg [15:0] mult_r, mult_g, mult_b;
    reg [15:0] sum_gray;
    reg [8:0]  temp_bright; 

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            gray_out <= 0;
            valid_out <= 0;
            mult_r <= 0; mult_g <= 0; mult_b <= 0;
            sum_gray <= 0;
            temp_bright <= 0;
        end else begin
            // Y = 0.299*R + 0.587*G + 0.114*B
            // Nhan voi 256: 77, 150, 29
            mult_r <= R * 77;
            mult_g <= G * 150;
            mult_b <= B * 29;

            sum_gray <= (mult_r + mult_g + mult_b);

            //chia 256 = lay 8 bit cao + do sang
            temp_bright = sum_gray[15:8] + brightness;

            // Neu ket qua lon hon 255 giu nguuyen
            if (temp_bright[8] == 1) 
                gray_out <= 255; 
            else 
                gray_out <= temp_bright[7:0]; 
                
            valid_out <= 1; 
        end
    end

endmodule

