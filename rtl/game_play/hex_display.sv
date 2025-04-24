/*******************************************************************************
* File: hex_display.sv
* Author: Soham Gandhi
* Date: 2025-04-22
* Description: Converts a 4-bit binary number to a 7-segment display format.
* Version: 1.1
*******************************************************************************/
module hex_display(
    input  logic [3:0] hex_num,      // 4-bit binary number
    output logic [6:0] segments      // 7-segment display output
);
    always_comb begin
        case (hex_num)
            4'd0: segments = 7'b1000000; // 0
            4'd1: segments = 7'b1111001; // 1
            4'd2: segments = 7'b0100100; // 2
            4'd3: segments = 7'b0110000; // 3
            4'd4: segments = 7'b0011001; // 4
            4'd5: segments = 7'b0010010; // 5
            4'd6: segments = 7'b0000010; // 6
            4'd7: segments = 7'b1111000; // 7
            4'd8: segments = 7'b0000000; // 8
            4'd9: segments = 7'b0010000; // 9
            default: segments = 7'b1111111; // Off (or blank)
        endcase
    end
endmodule
