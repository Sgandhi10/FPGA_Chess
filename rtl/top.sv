/*******************************************************************************
* File: DD2_Final_PRJ.sv
* Author: Soham Gandhi and Aniruddh Chauhan
* Date: 2025-04-22
* Description:
* Version: 1.0
*******************************************************************************/
import common_enums::*;

module top  #(
    parameter SCREEN_WIDTH = 640,  // Screen width in pixels
    parameter SCREEN_HEIGHT = 480, // Screen height in pixels
    parameter COLOR_DEPTH = 8      // Color depth (bits per channel)
) (
    input   logic        CLOCK_50,
    input   logic [3:0]  KEY,
    
    // I/O
    input   logic [9:0]  SW,
    output  logic [6:0]  HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
    output  logic [9:0]  LED,

    // UART Communication
    input   logic        RX,
    output  logic        TX,

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
    logic player, curr_player; // 0 for white, 1 for black

    // 8x8 boards
    logic [3:0] stable_board        [8][8];
    logic [3:0] disp_board          [8][8];
    logic       square_highlight    [8][8]; 

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

    // === FSM for screen transitions ===
    logic setup_complete, override;
    screen_fsm #(
        .CLK_FREQ_HZ(SYS_CLK_FREQ_HZ)
    ) screen_fsm_inst (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enter(key3out),
        .override(override),

        .state(state),
        .setup_complete(setup_complete)
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

    // For debugging purposes, assign the state to LEDs
    assign LED[1:0] = state; 
    assign LED[4] = curr_player;

    move_state_t move_state;
    assign LED[3:2] = move_state;

    logic moved;
    logic [11:0] output_packet;

    // === Board Controller ===
    board board_inst(
        .CLOCK_50(CLOCK_50),
        .reset_n(reset_n),
        
        .player(player),
        .curr_player(curr_player),
        .dir(SW[0]), 
        .sys_state(state),
        
        .key1out(key1out), // + dir
        .key2out(key2out), // - dir
        .key3out(key3out), // + enter

        .stable_board(stable_board), // 8x8 board input

        .disp_board(disp_board), // 8x8 board output
        .square_highlight(square_highlight), // 8x8 board output
        .moved(moved),
        .output_packet(output_packet),

        // debug
        .move_state(move_state)
    );

    // === Communication ===
    logic start_counter, load_counter;
    logic [15:0] data_out_rx;
    logic [1:0] mode_sel;
    UART_handler uart_handler_inst (
        .clk(CLOCK_50),
        .reset_n(reset_n),

        .disp_board(disp_board),
        .output_packet(output_packet),
        .SW(SW[3:1]),
        .setup_complete(setup_complete),
        .moved(moved),

        .stable_board(stable_board),
        .parity_error_rx(LED[9]),
        .override(override),
        .start_counter(start_counter),
        .player(player),
        .curr_player(curr_player), 
        .data_out_rx(data_out_rx),
        .mode_sel(mode_sel),
        .load_counter(load_counter),

        .RX(RX),
        .TX(TX)
    );


    screen_gen #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SCREEN_HEIGHT(SCREEN_HEIGHT),
        .COLOR_DEPTH(COLOR_DEPTH)
    ) tpg (
        .vga_clk(VGA_CLK),
        .reset_n(reset_n),
        .state(state_vga),
        .board(disp_board),
        .square_highlight(square_highlight),
        .vga_r(VGA_R),
        .vga_g(VGA_G),
        .vga_b(VGA_B),
        .hcount(hcount),
        .vcount(vcount)
    );


    // assign mode_sel = (data_out_rx[15:14] == 2'b10) ? data_out_rx[12:11] : SW[2:1];
    hex_counter #(
        .CLK_FREQ_HZ(SYS_CLK_FREQ_HZ)
    ) hex_counter_inst (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .start(start_counter),
        .mode_sel(mode_sel),
        .load(load_counter || override),
        .hex0(HEX0), .hex1(HEX1), .hex2(HEX2),
        .hex3(HEX3), .hex4(HEX4), .hex5(HEX5),
        .time_up(time_up)
    );

endmodule
