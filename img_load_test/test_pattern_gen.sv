/*******************************************************************************
* File: test_pattern_gen.sv
* Author: Soham Gandhi
* Date: 2025-03-27
* Description: Test Pattern Generator for VGA
* Version: 1.2
*******************************************************************************/

module test_pattern_gen #(
    parameter int SCREEN_WIDTH = 640,
    parameter int SCREEN_HEIGHT = 480,
    parameter int COLOR_DEPTH = 8  // Must be 8 for this palette
) (
    input  logic                   vga_clk,
    input  logic                   reset_n,

    input  logic [9:0]             hcount,
    input  logic [9:0]             vcount,

    output logic [COLOR_DEPTH-1:0] vga_r,
    output logic [COLOR_DEPTH-1:0] vga_g,
    output logic [COLOR_DEPTH-1:0] vga_b
);

    // --- Inline-initialized color palette (24-bit RGB)
    logic [(COLOR_DEPTH * 3)-1:0] color_array [4] = '{
        24'hD9D9D9,  // Index 0: Light gray
        24'h000000,  // Index 1: Black
        24'h69923E,  // Index 2: Green
        24'hFFFFFF   // Index 3: White
    };

    logic [1:0] mapped_color;

    // --- Flat pixel address calculation
    logic [18:0] rom_address;
    assign rom_address = vcount * SCREEN_WIDTH + hcount;

    // --- ROM Instance (startup screen bitmap)
    startup_screen_rom startup_screen_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(mapped_color)
    );
    
    assign {vga_r, vga_g, vga_b} = {
        color_array[mapped_color][23:16],  // R
        color_array[mapped_color][15:8],   // G
        color_array[mapped_color][7:0]     // B
    };

endmodule
