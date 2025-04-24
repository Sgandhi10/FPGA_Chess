/*******************************************************************************
* File: DD2_Final_PRJ.sv
* Author: Soham Gandhi and Aniruddh Chauhan
* Date: 2025-04-22
* Description:
* Version: 1.0
*******************************************************************************/
import common_enums::*;

module DD2_Final_PRJ  #(
    parameter SCREEN_WIDTH = 640,  // Screen width in pixels
    parameter SCREEN_HEIGHT = 480, // Screen height in pixels
    parameter COLOR_DEPTH = 8      // Color depth (bits per channel)
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
    localparam SYS_CLK_FREQ_HZ = 50_000_000;
    localparam VGA_CLK_FREQ_HZ = 25_175_000;

    logic [9:0] hcount, vcount;
    logic reset_n, key1out, key2out, key3out, time_up;
    screen_state_t state;

    // Flattened 8x8 board
    logic [3:0] board [8][8];

    // Initialize board
     initial begin
        board[0] = '{0, 1, 2, 3, 4, 2, 1, 0};
        board[1] = '{5, 5, 5, 5, 5, 5, 5, 5};
	     board[2] = '{default: 15};
        board[3] = '{default: 15};
        board[4] = '{default: 15};
        board[5] = '{default: 15};
        board[6] = '{11, 11, 11, 11, 11, 11, 11, 11};
        board[7] = '{6, 7, 8, 9, 10, 8, 7, 6};
    end

    assign reset_n = KEY[0]; // Active low reset

    vga_pll_25_175 pll (
        .refclk(CLOCK_50),
        .rst(~reset_n),
        .outclk_0(VGA_CLK), // 25 MHz
        .locked()
    );

    keypress keypress_key1(
        .clock(CLOCK_50),
        .reset_n(reset_n),
        .key_in(KEY[1]),
        .enable_out(key1out)
    );

    keypress keypress_key2(
        .clock(CLOCK_50),
        .reset_n(reset_n),
        .key_in(KEY[2]),
        .enable_out(key2out)
    );

    keypress keypress_key3(
        .clock(CLOCK_50),
        .reset_n(reset_n),
        .key_in(KEY[3]),
        .enable_out(key3out)
    );

    // VGA controller instance
    vga_controller vga_ctrl (
        .vga_clk(VGA_CLK),
        .reset_n(reset_n),

        .vga_hs(VGA_HS),
        .vga_vs(VGA_VS),
        .vga_blank_n(VGA_BLANK_N),
        .vga_sync_n(VGA_SYNC_N),

        .hcount(hcount),
        .vcount(vcount)
    );

    screen_fsm #(
        .CLK_FREQ_HZ(SYS_CLK_FREQ_HZ)
    ) screen_fsm_inst (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enter(key3out),
        .state(state)
    );

    // === CDC Synchronization ===
    // Synchronize the state signal to the VGA_CLK domain
	screen_state_t state_vga;
    state_sync #(
        .bits(2)
    ) state_sync_inst (
        .clk_vga(VGA_CLK),       // VGA clock domain
        .state_50(state),        // State signal from screen_fsm (CLOCK_50 domain)
        .state_vga(state_vga)    // Synchronized state signal for VGA_CLK domain
    );
    assign LED[1:0] = state_vga; // For debugging
    assign LED[3:2] = state; // For debugging

    screen_gen #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .COLOR_DEPTH(COLOR_DEPTH)
    ) tpg (
        .vga_clk(VGA_CLK),
        .reset_n(reset_n),
        .state(state_vga),
        .board(board),
        .vga_r(VGA_R),
        .vga_g(VGA_G),
        .vga_b(VGA_B),
        .hcount(hcount),
        .vcount(vcount)
    );

    hex_counter #(
        .CLK_FREQ_HZ(SYS_CLK_FREQ_HZ)
    ) hex_counter_inst (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .state(state),
        .mode_sel(SW[2:1]),
        .hex0(HEX0), .hex1(HEX1), .hex2(HEX2),
        .hex3(HEX3), .hex4(HEX4), .hex5(HEX5),
        .time_up(time_up)
    );

endmodule
