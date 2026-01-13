module ha_tan_so (
    input clk_in,    
    input rst,      
    output reg clk_out
);

	parameter LIMIT = 24999999; // Chia xuong 1Hz

    integer count;

    always @(posedge clk_in or negedge rst) begin
        if (!rst) begin
            count <= 0;
            clk_out <= 0;
        end else begin
            if (count == LIMIT) begin
                count <= 0;       
                clk_out <= ~clk_out; 
            end else begin
                count <= count + 1; 
            end
        end
    end

endmodule