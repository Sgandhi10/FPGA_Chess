/*******************************************************************************
* File: test_pattern_gen.sv
* Author: Soham Gandhi
* Date: 2025-03-27
* Description: Test Pattern Generator for VGA
* Version: 1.0
*******************************************************************************/

module test_pattern_gen #(
    parameter SCREEN_WIDTH = 640,  // Screen width in pixels
    parameter SCREEN_HEIGHT = 480, // Screen height in pixels
    parameter COLOR_DEPTH = 8     // Color depth (bits per channel)
) (
    input   logic                   vga_clk,    // 25 MHz clock
    input   logic                   reset_n,    // Active low reset
    input   logic [9:0]             SW,         // Switches
        

    // Optional
    input   logic [9:0]             hcount,
    input   logic [9:0]             vcount,

    output  logic [COLOR_DEPTH-1:0] vga_r,      // Red color output
    output  logic [COLOR_DEPTH-1:0] vga_g,      // Green color output
    output  logic [COLOR_DEPTH-1:0] vga_b       // Blue color output
);
    // SW 0: Solid color
    // SW 1: Checkerboard
    // SW 2: Gradient

	logic check_pattern;
	assign check_pattern = ((hcount >> 5) + (vcount >> 5)) & 1'b1;
	 
	 // Create a checkerboard based on the x, y positions
    always_ff @(posedge vga_clk, negedge reset_n) begin
        if (!reset_n) begin
            vga_r <= 'd0;
            vga_g <= 'd0;
            vga_b <= 'd0;
        end else begin
            if (SW[0]) begin
                vga_r <= 8'hFF;
                vga_g <= 8'h00;
                vga_b <= 8'h00;
            end else if (SW[1]) begin
                if (check_pattern) begin
                    vga_r <= 8'hFF; // White color
                    vga_g <= 8'hFF; // White color
                    vga_b <= 8'hFF; // White color
                end else begin
                    vga_r <= 8'h00; // Black color
                    vga_g <= 8'h00; // Black color
                    vga_b <= 8'h00; // Black color
                end
            end else if (SW[2]) begin
                vga_r <= hcount[7:0];
                vga_g <= vcount[7:0];
                vga_b <= {hcount[3:0], vcount[3:0]};
            end else begin
                vga_r <= 8'hFF;
                vga_g <= 8'hFF;
                vga_b <= 8'hFF;
            end
        end
    end
endmodule
