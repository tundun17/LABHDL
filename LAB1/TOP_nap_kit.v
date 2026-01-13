module TOP_nap_kit (
    input clk_50MHz,    
    input rst,          
    input load,        
    input [2:0] in_data,
    output [6:0] seg,  
    output [17:0] LEDR  
);

    wire wire_clk_slow;
    wire [2:0] wire_data;

    assign LEDR[17] = wire_clk_slow; 
    assign LEDR[0]  = load;     
    assign LEDR[3:1] = in_data;   

    ha_tan_so u0_Div (
        .clk_in(clk_50MHz),
        .rst(rst),
        .clk_out(wire_clk_slow)
    );

    LAB1 u1_Dem (
        .clk(wire_clk_slow),
        .rst(rst),
        .load(load),
        .in_data(in_data),
        .out_data(wire_data)
    );

    led7 u2_Led7 (
        .bin(wire_data),
        .seg(seg)
    );

endmodule