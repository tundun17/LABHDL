`timescale 1ns / 1ps

module tb_image_filter;

    // --- CẤU HÌNH ---
    parameter WIDTH  = 430;
    parameter HEIGHT = 554;
    parameter IMG_SIZE = WIDTH * HEIGHT;

    reg clk;
    reg rst;
    reg [7:0] pixel_in;

    wire [7:0] pixel_out;
    wire valid_out;
    wire [9:0] x_curr;
    wire [9:0] y_curr;

    reg [7:0] mem_in  [0 : IMG_SIZE-1]; 
    reg [7:0] mem_out [0 : IMG_SIZE-1]; 
    
    integer file_out_handle;
    integer ptr;
    integer i;

    // --- GỌI MODULE TOP ---
    top #( .W(WIDTH), .H(HEIGHT) ) uut (
        .clk(clk),
        .rst(rst),
        .pixel_in(pixel_in),
        .pixel_out(pixel_out),
        .valid_out(valid_out),
        .x_pos_out(x_curr),
        .y_pos_out(y_curr)
    );

    // --- CLOCK ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --- CẤP DỮ LIỆU ---
    always @(negedge clk) begin
        if (!rst) begin
            ptr <= 0;
            pixel_in <= 0;
        end else begin
            if (ptr < IMG_SIZE) begin
                pixel_in <= mem_in[ptr];
                ptr <= ptr + 1;
            end else begin
                pixel_in <= 0;
            end
        end
    end

    // --- GHI KẾT QUẢ & LẤP ĐẦY VIỀN ---
    always @(negedge clk) begin
        if (valid_out) begin
            mem_out[(y_curr - 1) * WIDTH + (x_curr - 1)] = pixel_out;
            if (y_curr == 2) begin
                mem_out[0 * WIDTH + (x_curr - 1)] = pixel_out; // Lấp dòng 0
                mem_out[1 * WIDTH + (x_curr - 1)] = pixel_out; // Lấp dòng 1
            end
            if (x_curr == 2) begin
                mem_out[(y_curr - 1) * WIDTH + 0] = pixel_out; // Lấp cột trái
                if (y_curr == 2) begin // Góc trên trái
                     mem_out[0] = pixel_out;
                     mem_out[WIDTH] = pixel_out;
                end
            end
        end
    end

    // --- MAIN ---
    initial begin
        $display("Loading input...");
        $readmemh("pic_input.txt", mem_in); 

        rst = 0;
        #25;      
        rst = 1;  
        
        $display("System started. Waiting for completion...");
        wait (y_curr == HEIGHT - 1 && x_curr == WIDTH - 1);
        #100; 
        
        $display("Processing DONE! Writing output file...");
        
        file_out_handle = $fopen("pic_output.txt", "w");
        
        for (i = 0; i < IMG_SIZE; i = i + 1) begin
            if (mem_out[i] === 8'bx) 
                $fdisplay(file_out_handle, "00");
            else
                $fdisplay(file_out_handle, "%h", mem_out[i]);
        end

        $fclose(file_out_handle);
        $display("Finished successfully!");
        $finish;
    end

endmodule