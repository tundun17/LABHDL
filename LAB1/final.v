module final (
    input         CLOCK_50, 
    input  [3:0]  KEY,      
    input  [17:0] SW,       
    output [6:0]  HEX0,     
    output [17:0] LEDR      
);

    wire rst_wire;
    wire load_wire;
    wire [2:0] data_wire;
    wire [6:0] hex_wire;

    assign rst_wire  = KEY[0];     
    assign load_wire = SW[0];      
    assign data_wire = SW[3:1];    
    
    assign HEX0 = hex_wire;

    assign LEDR[0]   = load_wire;
    assign LEDR[3:1] = data_wire;

    TOP_nap_kit u_final_inst (
        .clk_50MHz  (CLOCK_50), 
        .rst      (rst_wire), 
        .load  (load_wire), 
        .in_data  (data_wire), 
        .seg  (hex_wire)
    );

endmodule
