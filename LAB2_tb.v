`timescale 1ns / 1ps

module tb_image_filter;

    // --- 1. THAM SỐ CẤU HÌNH ---  
    parameter WIDTH  = 430;
    parameter HEIGHT = 554;
    parameter IMG_SIZE = WIDTH * HEIGHT;

    // --- 2. KHAI BÁO TÍN HIỆU ---
    // Tín hiệu Input cho DUT
    reg clk;
    reg rst; 
    reg [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;

    // Tín hiệu Output từ DUT
    wire [7:0] pixel_out;
    wire [9:0] x_pos; 
    wire [9:0] y_pos;
    wire valid_out;

    // --- 3. BỘ NHỚ GIẢ LẬP ---
    reg [7:0] mem_in  [0 : IMG_SIZE-1]; 
    reg [7:0] mem_out [0 : IMG_SIZE-1]; 

    integer file_out_handle;
    integer i;

    // --- 4. GỌI TOP MODULE (DUT) ---

    top #(
        .W(WIDTH), 
        .H(HEIGHT)
    ) uut (
        .clk(clk),
        .rst(rst), // Kết nối tín hiệu rst
        .p0(p0), .p1(p1), .p2(p2),
        .p3(p3), .p4(p4), .p5(p5),
        .p6(p6), .p7(p7), .p8(p8),
        .pixel_out(pixel_out),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .valid_out(valid_out)
    );

    // --- 5. TẠO CLOCK (Chu kỳ 10ns) ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- 6. LOGIC CẤP DỮ LIỆU (DATA FEEDER) ---
    // Khi x_pos, y_pos thay đổi, TB cấp ngay 9 pixel mới
    always @(x_pos or y_pos) begin
        #1; // Delay nhỏ mô phỏng độ trễ truy cập
        
        p0 = get_pixel(x_pos - 1, y_pos - 1);
        p1 = get_pixel(x_pos    , y_pos - 1);
        p2 = get_pixel(x_pos + 1, y_pos - 1);
        
        p3 = get_pixel(x_pos - 1, y_pos);
        p4 = get_pixel(x_pos    , y_pos);     
        p5 = get_pixel(x_pos + 1, y_pos);
        
        p6 = get_pixel(x_pos - 1, y_pos + 1);
        p7 = get_pixel(x_pos    , y_pos + 1);
        p8 = get_pixel(x_pos + 1, y_pos + 1);
    end

    // Hàm an toàn: Trả về 0 nếu tọa độ ra ngoài viền
    function [7:0] get_pixel;
        input integer x;
        input integer y;
        begin
            if (x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT)
                get_pixel = 8'd0; 
            else
                get_pixel = mem_in[y * WIDTH + x];
        end
    endfunction

    // --- 7. LOGIC THU THẬP KẾT QUẢ ---
    always @(negedge clk) begin
        if (valid_out) begin
            mem_out[y_pos * WIDTH + x_pos] = pixel_out;
        end
    end

    // --- 8. KỊCH BẢN CHẠY TEST (MAIN) ---
    initial begin
        // A. Nạp dữ liệu
        // LƯU Ý: Nếu chạy lỗi file not found, hãy điền đường dẫn tuyệt đối (E:/...)
        $display("Loading pic_input.txt...");
        $readmemh("pic_input.txt", mem_in);

        // B. Reset hệ thống
        // Module top dùng logic: if (!rst) -> Reset tích cực thấp (Mức 0 là Reset)
        rst = 0; // Kéo xuống 0 để Reset
        #20;
        rst = 1; // Thả lên 1 để chạy
        $display("System started. Processing image...");

        // C. Chờ hệ thống chạy xong
        // Thời gian chờ = 430 * 554 * 10ns ~ 2.4ms -> Chờ 2.5ms cho chắc
        #2500000; 
        
        // D. Xuất kết quả
        $display("Processing done. Writing output to pic_output.txt...");
        file_out_handle = $fopen("pic_output.txt", "w");
        
        for (i = 0; i < IMG_SIZE; i = i + 1) begin
            // Xử lý các điểm viền chưa được ghi (đang là x hoặc z) thành 00
            if (mem_out[i] === 8'bx || mem_out[i] === 8'bz) 
                $fdisplay(file_out_handle, "00");
            else
                $fdisplay(file_out_handle, "%h", mem_out[i]);
        end

        $fclose(file_out_handle);
        $display("Finished! Please check pic_output.txt");
        $finish;
    end

endmodule