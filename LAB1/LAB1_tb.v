`timescale 1ns/1ps

module tb_Dem;

    reg clk;
    reg rst;
    reg load;
    reg [2:0] in_data;

    wire [2:0] out_data;

    Dem uut (
        .clk(clk),
        .rst(rst), 
        .load(load),
        .in_data(in_data),
        .out_data(out_data)
    );


    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $monitor("Time=%0t | RST=%b | LOAD=%b | IN=%d | OUT=%d", 
                 $time, rst, load, in_data, out_data);

        rst = 1;       
        load = 0;
        in_data = 0;
        
        #10;
        rst = 0;     
        #10;          
        rst = 1;      

        #100;

        
        // Test 1: nap so 0
        $display("--- TEST LOAD: Nap so 0 ---");
        @ (negedge clk); 
        load = 1;
        in_data = 3'd0;
        @ (negedge clk);
        load = 0;     
        #50;             

        // Test 2: nap so 5
        $display("--- TEST LOAD: Nap so 5 ---");
        @ (negedge clk);
        load = 1;
        in_data = 3'd5;
        @ (negedge clk);
        load = 0;      
        #50;

        // Test 3: nap so 2
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