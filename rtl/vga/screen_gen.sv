/*******************************************************************************
* File: screen_gen.sv
* Author: Soham Gandhi and Ani
* Date: 2025-04-22
* Description: Test Pattern Generator for VGA
* Version: 2.0
*******************************************************************************/
import common_enums::*;

module screen_gen #(
    parameter SCREEN_WIDTH = 640,  // Screen width in pixels
    parameter SCREEN_HEIGHT = 480, // Screen height in pixels
    parameter COLOR_DEPTH = 8      // Color depth (bits per channel)
) (
    input   logic                   vga_clk,        // 25 MHz clock
    input   logic                   reset_n,        // Active low reset
    input   screen_state_t          state,          // System State

    input   logic [3:0]             board [8][8],   // Flattened 8x8 board pattern
        
    // Optional
    input   logic [9:0]             hcount,         // Horizontal Pixel Count
    input   logic [9:0]             vcount,         // Vertical Pixel Count

    output  logic [COLOR_DEPTH-1:0] vga_r,          // Red color output
    output  logic [COLOR_DEPTH-1:0] vga_g,          // Green color output
    output  logic [COLOR_DEPTH-1:0] vga_b           // Blue color output
);
   
    // --- Color Palette: index to RGB mapping
    logic [(COLOR_DEPTH * 3)-1:0] color_array [5] = '{
        24'hEEEED2,  // 0 – light square (tan)
        24'h4B4847,  // 1 – dark square (green)
        24'h69923E,  // 2 – background
        24'hFFFFFF,  // 3 – white/piece
        24'h000000   // 4 – transparent (will be ignored in logic)
    };

    // --- Constants for layout
    localparam CHESS_TILE_SIZE = 56;
    localparam CHESS_PIECE_SIZE = 56;
    localparam BOARD_ORIGIN_X = 16;
    localparam BOARD_ORIGIN_Y = 16;

    // ROM output wires
    logic [2:0] title_pixel, player_pixel, board_pixel, piece_pixel, selected_pixel;

    // Addressing for all screens
    logic [18:0] rom_address;
    assign rom_address = vcount * SCREEN_WIDTH + hcount;

    // Addressing for sprite ROM
    logic [15:0] piece_rom_addr;

    // Tile position logic
    logic [2:0] tile_row ;
    logic [2:0] tile_col; 

    logic [5:0] rel_x;
    logic [5:0] rel_y;
    assign tile_col = (hcount - BOARD_ORIGIN_X) / CHESS_TILE_SIZE;
    assign tile_row = (vcount - BOARD_ORIGIN_Y) / CHESS_TILE_SIZE;

    assign rel_x = hcount - (BOARD_ORIGIN_X + tile_col * CHESS_TILE_SIZE);
    assign rel_y = vcount - (BOARD_ORIGIN_Y + tile_row * CHESS_TILE_SIZE);

    logic [3:0] piece_index;
    logic in_sprite_area;

    // Piece layout (12 sprites in ROM): index from 0–11
    // --- ROMs
    title_screen_rom title_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(title_pixel)
    );

    player_screen_rom player_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(player_pixel)
    );

    chess_board_rom board_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(board_pixel)
    );

    chess_piece_rom pieces_rom (
        .address(piece_rom_addr),
        .clock(vga_clk),
        .q(piece_pixel)
    );

    // --- Main pixel generation
    always_comb begin
        piece_rom_addr = 0;
        selected_pixel = board_pixel;
        piece_index    = 0;
        in_sprite_area = 0;

        case (state)
            TITLE_SCREEN: selected_pixel = title_pixel;
            PLAYER_SCREEN: selected_pixel = player_pixel;
            SETUP_SCREEN: selected_pixel = board_pixel;
            CHESS_SCREEN: begin
                if (hcount >= BOARD_ORIGIN_X && hcount < BOARD_ORIGIN_X + 8 * CHESS_TILE_SIZE &&
                    vcount >= BOARD_ORIGIN_Y && vcount < BOARD_ORIGIN_Y + 8 * CHESS_TILE_SIZE) begin

                    piece_index = board[tile_row][tile_col];
                    in_sprite_area = (piece_index < 12);

                    if (in_sprite_area) begin
                        piece_rom_addr = piece_index * CHESS_PIECE_SIZE * CHESS_PIECE_SIZE +
                                         (rel_y) * CHESS_PIECE_SIZE + rel_x;
                        selected_pixel = (piece_pixel != 3'd4) ? piece_pixel : board_pixel;
                    end else begin
                        selected_pixel = board_pixel;
                    end
                end else begin
                    selected_pixel = board_pixel;
                end
            end
            default: selected_pixel = board_pixel;
        endcase
    end

    // --- Output RGB signals
    assign {vga_r, vga_g, vga_b} = {
        color_array[selected_pixel][23:16],
        color_array[selected_pixel][15:8],
        color_array[selected_pixel][7:0]
    };

endmodule
