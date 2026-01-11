module rgb2gray (
    input clk,
    input rst,
    input [7:0] R,
    input [7:0] G,
    input [7:0] B,
    input [7:0] brightness, // Chỉnh độ sáng (cộng thêm)

    output reg [7:0] gray_out,
    output reg valid_out
);

    reg [15:0] mult_r, mult_g, mult_b;
    reg [15:0] sum_gray;
    reg [8:0]  temp_bright; // 9 bit để check tràn 255

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            gray_out <= 0;
            valid_out <= 0;
            mult_r <= 0; mult_g <= 0; mult_b <= 0;
            sum_gray <= 0;
            temp_bright <= 0;
        end else begin
            // Y = 0.299*R + 0.587*G + 0.114*B
            // Nhân với 256: 77, 150, 29
            mult_r <= R * 77;
            mult_g <= G * 150;
            mult_b <= B * 29;

            sum_gray <= (mult_r + mult_g + mult_b);

            // chia 256 bằng cach lấy 8 bit cao + chỉnh độ sáng
            temp_bright = sum_gray[15:8] + brightness;

            // Nếu kết quả > 255 thì giữ mức 255
            if (temp_bright[8] == 1) 
                gray_out <= 255; 
            else 
                gray_out <= temp_bright[7:0]; 
                
            valid_out <= 1; 
        end
    end

endmodule