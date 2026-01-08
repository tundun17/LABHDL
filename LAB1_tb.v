`timescale 1ns/1ps

module tb_Dem;

    // 1. Khai báo tín hiệu cho Testbench
    // Input của DUT thì khai báo là reg
    reg clk;
    reg rst;
    reg load;
    reg [2:0] in_data;

    // Output của DUT thì khai báo là wire
    wire [2:0] out_data;

    // 2. Khởi tạo (Instantiate) Unit Under Test (UUT)
    Dem uut (
        .clk(clk),
        .rst(rst), 
        .load(load),
        .in_data(in_data),
        .out_data(out_data)
    );

    // 3. Tạo xung Clock (Chu kỳ 10ns -> Tần số 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 4. Kịch bản kiểm tra (Stimulus)
    initial begin
        // Thiết lập hiển thị kết quả ra màn hình console
        $monitor("Time=%0t | RST=%b | LOAD=%b | IN=%d | OUT=%d", 
                 $time, rst, load, in_data, out_data);

        // --- GIAI ĐOẠN 1: KHỞI TẠO & RESET ---
        rst = 1;       // Ban đầu chưa reset (vì rst tích cực thấp)
        load = 0;
        in_data = 0;
        
        #10;
        rst = 0;       // Kích hoạt Reset (Active Low)
        #10;           // Giữ reset một chút
        rst = 1;       // Thả reset -> Mạch bắt đầu chạy

        // --- GIAI ĐOẠN 2: CHẠY TỰ DO (Kiểm tra chu trình đếm) ---
        // Chu trình mong muốn: 2 -> 3 -> 5 -> 2 -> 0 -> 3 -> 4 -> 6 -> lặp lại
        // Chờ khoảng 100ns (tương đương 10 chu kỳ clock) để quan sát
        #100;

        // --- GIAI ĐOẠN 3: KIỂM TRA CHỨC NĂNG LOAD ---
        
        // Test 1: Nạp số 0 -> Kỳ vọng mạch nhảy ra số 0 (index 4)
        $display("--- TEST LOAD: Nap so 0 ---");
        @ (negedge clk); // Đợi cạnh xuống để đổi dữ liệu cho an toàn
        load = 1;
        in_data = 3'd0;
        @ (negedge clk); // Giữ trong 1 chu kỳ
        load = 0;        // Tắt load, mạch phải đếm tiếp từ 0 -> 3 -> 4...
        #50;             // Quan sát kết quả

        // Test 2: Nạp số 5 -> Kỳ vọng mạch nhảy ra số 5 (index 2)
        $display("--- TEST LOAD: Nap so 5 ---");
        @ (negedge clk);
        load = 1;
        in_data = 3'd5;
        @ (negedge clk);
        load = 0;        // Tắt load, mạch phải đếm tiếp từ 5 -> 2 -> 0...
        #50;

        // Test 3: Nạp số 2 -> Kỳ vọng mạch nhảy ra số 2 (index 0 - ưu tiên đầu chuỗi)
        $display("--- TEST LOAD: Nap so 2 ---");
        @ (negedge clk);
        load = 1;
        in_data = 3'd2;
        @ (negedge clk);
        load = 0;
        #50;

        $display("--- TEST COMPLETE ---");
        $stop;
    end

endmodule