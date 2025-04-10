/*******************************************************************************
* File: top.sv
* Author: Soham Gandhi
* Date: 2025-03-27
* Description: Top level module for vga controller
* Version: 1.0
*******************************************************************************/


module top #(
    parameter SCREEN_WIDTH = 640,  // Screen width in pixels
    parameter SCREEN_HEIGHT = 480, // Screen height in pixels
    parameter COLOR_DEPTH = 8     // Color depth (bits per channel)
) (
    input   logic        CLOCK_50,
    input   logic [3:0]  KEY,
	
    // For future use
    input   logic [9:0]  SW,
    output  logic [6:0]  HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
    output  logic [9:0]  LED,

    // VGA signals
    output logic [COLOR_DEPTH-1:0]  VGA_R,
    output logic [COLOR_DEPTH-1:0]  VGA_G,
    output logic [COLOR_DEPTH-1:0]  VGA_B,
    output logic                    VGA_HS,
    output logic                    VGA_VS,
    output logic                    VGA_BLANK_N,
    output logic                    VGA_SYNC_N,
    output logic                    VGA_CLK
);
	 logic [9:0] hcount, vcount;
    assign reset_n = KEY[0]; // Active low reset
    vga_pll_25_175 pll (
        .refclk(CLOCK_50),
        .rst(~reset_n),

        .outclk_0(VGA_CLK), // 25 MHz
        .locked()
    );

    // VGA controller instance
    vga_controller vga_ctrl (
        .vga_clk(VGA_CLK),
        .reset_n(reset_n),

        .vga_hs(VGA_HS),
        .vga_vs(VGA_VS),
        .vga_blank_n(VGA_BLANK_N),
        .vga_sync_n(VGA_SYNC_N),

        // Optional
        .hcount(hcount),
        .vcount(vcount),
    );


    // Test Pattern Generator instance
    test_pattern_gen #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .COLOR_DEPTH(COLOR_DEPTH)
    ) tpg (
        .vga_clk(VGA_CLK),
        .reset_n(reset_n),

        .vga_r(VGA_R),
        .vga_g(VGA_G),
        .vga_b(VGA_B),
		  
        .hcount(hcount),
        .vcount(vcount)
    );

endmodule