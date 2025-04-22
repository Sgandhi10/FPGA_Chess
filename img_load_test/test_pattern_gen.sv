/*******************************************************************************
* File: test_pattern_gen.sv
* Author: Soham Gandhi & Aniruddh Chauhan
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
    input  logic [9:0]             SW,
    input  logic [9:0]             hcount,
    input  logic [9:0]             vcount,
    output logic [COLOR_DEPTH-1:0] vga_r,
    output logic [COLOR_DEPTH-1:0] vga_g,
    output logic [COLOR_DEPTH-1:0] vga_b
);

    // --- Color Palette: index to RGB mapping
    logic [(COLOR_DEPTH * 3)-1:0] color_array [4] = '{
        24'hEEEED2,  // 0 – light square (tan)
        24'h69923E,  // 1 – dark square (green)
        24'h4B4847,  // 2 – background
        24'hFFFFFF   // 3 – white/piece
    };

    // --- Constants for layout
    localparam CHESS_TILE_SIZE = 56;
    localparam CHESS_PIECE_SIZE = 56;
    localparam BOARD_ORIGIN_X = 16;
    localparam BOARD_ORIGIN_Y = 16;

    // ROM output wires
    logic [1:0] title_pixel, player_pixel, board_pixel, piece_pixel, selected_pixel;

    // Addressing for all screens
    logic [18:0] rom_address;
    assign rom_address = vcount * SCREEN_WIDTH + hcount;

    // Addressing for sprite ROM
    logic [18:0] piece_rom_addr;

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
    logic [3:0] piece_map[8][8];

    initial begin
        piece_map[0] = '{0, 1, 2, 3, 4, 2, 1, 0};
        piece_map[1] = '{5, 5, 5, 5, 5, 5, 5, 5};
        piece_map[6] = '{11, 11, 11, 11, 11, 11, 11, 11};
        piece_map[7] = '{6, 7, 8, 9, 10, 8, 7, 6};
        piece_map[2] = '{default: 15};
        piece_map[3] = '{default: 15};
        piece_map[4] = '{default: 15};
        piece_map[5] = '{default: 15};
    end

    // --- ROMs
    title_screen_rom2 title_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(title_pixel)
    );

    player_screen_rom2 player_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(player_pixel)
    );

    chess_board_rom board_rom_inst (
        .address(rom_address),
        .clock(vga_clk),
        .q(board_pixel)
    );

    chess_piece_rom2 pieces_rom (
        .address(piece_rom_addr),
        .clock(vga_clk),
        .q(piece_pixel)
    );

    // --- Main pixel generation
    always_comb begin
		piece_rom_addr = 0;
		selected_pixel  = board_pixel;
		piece_index     = 0;
		in_sprite_area  = 0;
		
        case (SW[1:0])
            2'b00: selected_pixel = title_pixel;
            2'b01: selected_pixel = player_pixel;
            2'b10: selected_pixel = board_pixel;
            2'b11: begin
                selected_pixel = board_pixel;
                if (hcount >= BOARD_ORIGIN_X && hcount < BOARD_ORIGIN_X + 8 * CHESS_TILE_SIZE &&
                    vcount >= BOARD_ORIGIN_Y && vcount < BOARD_ORIGIN_Y + 8 * CHESS_TILE_SIZE) begin

                    piece_index = piece_map[tile_row][tile_col];
                    in_sprite_area = (piece_index < 12);

                    if (in_sprite_area) begin
                        piece_rom_addr = piece_index * CHESS_PIECE_SIZE * CHESS_PIECE_SIZE + rel_y * CHESS_PIECE_SIZE + rel_x;
                        selected_pixel = (piece_pixel != 0) ? piece_pixel : board_pixel;
                    end 
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

























