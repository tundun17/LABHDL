module Dem (
    input clk,
    input rst,
    input load,
    input [2:0] in_data,
    output [2:0] out_data
);

    reg [2:0] current_state;
    reg [2:0] next_state;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state = 3'd0;
        end else if (load) begin
            case (in_data)
                3'd2: current_state = 3'd0;
                3'd3: current_state = 3'd1;
                3'd5: current_state = 3'd2;
                // neu data = 2 thi ve index 0
                3'd0: current_state = 3'd4;
                // neu data = 3 thi ve index 1
                3'd4: current_state = 3'd6;
                3'd6: current_state = 3'd7;
                default: current_state <= 3'd0;  
            endcase
        end else begin
            current_state <= next_state;
        end
    end

always @(*) begin
    next_state = current_state + 1; 
end

always @(*) begin
    case (current_state)
        3'd0: out_data = 3'd2;
        3'd1: out_data = 3'd3;
        3'd2: out_data = 3'd5;
        3'd3: out_data = 3'd2;
        3'd4: out_data = 3'd0;
        3'd5: out_data = 3'd3;
        3'd6: out_data = 3'd4;
        3'd7: out_data = 3'd6;
        default: out_data = 3'd2; 
    endcase
end
    
endmodule