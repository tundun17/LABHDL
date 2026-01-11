`timescale 1ns / 1ps

module tb_rgb2gray;

    // --- CẬP NHẬT KÍCH THƯỚC ẢNH CỦA BẠN ---
    parameter WIDTH  = 2048;
    parameter HEIGHT = 1365;
    parameter IMG_SIZE = WIDTH * HEIGHT; // ~2.8 triệu pixel

    reg clk;
    reg rst;
    
    // Input
    reg [7:0] R_in, G_in, B_in;
    reg [7:0] brightness_val;

    // Output
    wire [7:0] gray_out;
    wire valid_out;

    // Bộ nhớ (Lớn)
    // Lưu ý: Máy tính cần đủ RAM để mô phỏng mảng này
    reg [23:0] mem_in [0 : IMG_SIZE-1]; 
    reg [7:0]  mem_out [0 : IMG_SIZE-1];

    integer file_out;
    integer ptr, i;

    // Gọi module
    rgb2gray uut (
        .clk(clk),
        .rst(rst),
        .R(R_in), .G(G_in), .B(B_in),
        .brightness(brightness_val),
        .gray_out(gray_out),
        .valid_out(valid_out)
    );

    // Clock 10ns
    initial begin
        clk = 0; forever #5 clk = ~clk;
    end

    // --- ĐẨY DỮ LIỆU VÀO (NEGEDGE) ---
    always @(negedge clk) begin
        if (!rst) begin
            ptr <= 0;
            R_in <= 0; G_in <= 0; B_in <= 0;
        end else begin
            if (ptr < IMG_SIZE) begin
                // Tách 24-bit Hex thành 3 kênh màu
                R_in <= mem_in[ptr][23:16];
                G_in <= mem_in[ptr][15:8];
                B_in <= mem_in[ptr][7:0];
                ptr <= ptr + 1;
            end
        end
    end

    // --- THU DỮ LIỆU RA (NEGEDGE) ---
    integer out_ptr = 0;
    always @(negedge clk) begin
        if (valid_out && out_ptr < IMG_SIZE) begin
            mem_out[out_ptr] = gray_out;
            out_ptr = out_ptr + 1;
        end
    end

    // --- MAIN ---
    initial begin
        $display("Loading rgb_input.txt (Size: %0dx%0d)...", WIDTH, HEIGHT);
        // Đọc file input do Python tạo
        $readmemh("rgb_input.txt", mem_in);

        // THỬ NGHIỆM: Tăng độ sáng lên 30 đơn vị
        brightness_val = 30; 

        rst = 0;
        #20;
        rst = 1;
        $display("Simulation started. This may take a while...");

        // Chờ đến khi thu đủ số lượng pixel
        wait (out_ptr == IMG_SIZE);
        #100;

        $display("Processing DONE! Writing gray_output.txt...");
        file_out = $fopen("gray_output.txt", "w");
        for (i = 0; i < IMG_SIZE; i = i + 1) begin
             $fdisplay(file_out, "%02h", mem_out[i]);
        end
        $fclose(file_out);
        $display("Finished!");
        $finish;
    end

endmodule