        module led7 (
            input [2:0] bin,
            output reg [6:0] seg
        );

        always @(*) begin
            case (bin)
                // gfedcba
                3'd0: seg = 7'b1000000; // Số 0 (Tắt g)
                3'd1: seg = 7'b1111001; // Số 1 (Sáng b,c)
                3'd2: seg = 7'b0100100; // Số 2 
                3'd3: seg = 7'b0110000; // Số 3
                3'd4: seg = 7'b0011001; // Số 4
                3'd5: seg = 7'b0010010; // Số 5
                3'd6: seg = 7'b0000010; // Số 6
                3'd7: seg = 7'b1111000; // Số 7
                default: seg = 7'b1111111; 
            endcase
        end
        
        endmodule