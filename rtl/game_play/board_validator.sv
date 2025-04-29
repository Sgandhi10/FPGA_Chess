/*******************************************************************************
* File: board.sv
* Author: Aniruddh Chauhan
* Date: 2025-04-27
* Description: Game logic file/ Chess moves valid/invalid checker
* Version: 1.1
*******************************************************************************/
module board_validator (
    input logic         CLOCK_50,
    input logic         reset_n,

    input logic  [2:0]  old_x, old_y,
    input logic  [2:0]  new_x, new_y,
    input logic  [2:0]  piece_type,
    input logic  [3:0]  board_in  [8][8], // 8x8 board input

    output logic [3:0]  board_out [8][8],
    output logic        board_valid
);


//Calcualte distance from old position to new position
//need this to be a pipeline stage since values are needed for checking valid move or not

logic [2:0] h_delta_reg, v_delta_reg;
always_ff @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n) 
    begin
        h_delta_reg <= 0;
        v_delta_reg <= 0;
    end 
    
    else 
    begin
        if (new_x >= old_x) 
            h_delta_reg <= new_x - old_x;
        else                
            h_delta_reg <= old_x - new_x;

        if (new_y >= old_y) 
            v_delta_reg <= new_y - old_y;
        else                
            v_delta_reg <= old_y - new_y;
    end
end

//Path clear
logic path_clear;

always_comb begin
 path_clear = 1'b1;

//Check if its vertical move BAisc

  if (old_x == new_x) begin
            // Vertical move
            if (old_y < new_y) begin //up
                for (int y = old_y + 1; y < new_y; y++) begin
                    if (board_in[y][old_x] != 4'd15) path_clear = 0;
                end
            end else begin //down
                for (int y = new_y + 1; y < old_y; y++) begin
                    if (board_in[y][old_x] != 4'd15) path_clear = 0;
                end
            end
        end
        else if (old_y == new_y) begin
            // Horizontal move baisc
            if (old_x < new_x) begin //left
                for (int x = old_x + 1; x < new_x; x++) begin
                    if (board_in[old_y][x] != 4'd15) path_clear = 0;
                end
            end else begin //right
                for (int x = new_x + 1; x < old_x; x++) begin
                    if (board_in[old_y][x] != 4'd15) path_clear = 0;
                end
            end
        end
		  
		  
        else if (h_delta_reg == v_delta_reg) begin
            // Diagonal move
            int dx = (new_x > old_x) ? 1 : -1;
            int dy = (new_y > old_y) ? 1 : -1;
            int x = old_x + dx;
            int y = old_y + dy;
   // stack overflow
	
	
	
/*	boolean isBishopMoveBlocked(int srcX,int srcY,int destX,int destY) {
  // assume we have already done the tests above
  int dirX = destX > srcX ? 1 : -1;
  int dirY = destY > srcY ? 1 : -1;
  for (int i=1; i < Math.abs(destX - srcX) - 1; ++i) {
    if (pieceOnSquare(srcX + i*dirX, srcY + i*dirY) {
      return false;
    }
  }
  return true;
}*/
            while (x != new_x && y != new_y) begin
                if (board_in[y][x] != 4'd15) path_clear = 0;
                x += dx;
                y += dy;
            end
        end
    end
//Horse movement??









//check if move is valid for each piece as listed
// White 
// 0 -> Rook
// 1 -> Knight
// 2 -> Bishop
// 3 -> Queen
// 4 -> King
// 5 -> Pawn

// Black
// 6 -> Rook 
// 7 -> Knight
// 8 -> Bishop
// 9 -> Queen
// 10-> King
// 11-> Pawn
// 15 -> NONE

always_comb begin
        board_valid = 1'd0; // default: move not valid

        case (piece_type)
            4'd0, 4'd6: // Rooks
                board_valid = (h_delta_reg == 0 || v_delta_reg == 0) && path_clear;

            4'd1, 4'd7: // Knights
                board_valid = (h_delta_reg == 2 && v_delta_reg == 1) || (h_delta_reg == 1 && v_delta_reg == 2);

            4'd2, 4'd8: // Bishops
                board_valid = (h_delta_reg == v_delta_reg) && path_clear;

            4'd3, 4'd9: // Queens
                board_valid = ((h_delta_reg == 0 || v_delta_reg == 0) || (h_delta_reg == v_delta_reg)) && path_clear;

            4'd4, 4'd10: // Kings
                board_valid = (h_delta_reg <= 1 && v_delta_reg <= 1);

            4'd5: // White Pawn
                board_valid = (
                    (old_y == 3'd6 && v_delta_reg == 2 && h_delta_reg == 0 && board_in[old_y-1][old_x] == 4'd15 && board_in[new_y][new_x] == 4'd15) || // Double forward from start
                    (v_delta_reg == 1 && h_delta_reg == 0 && new_y < old_y && board_in[new_y][new_x] == 4'd15) || // Single forward
                    (v_delta_reg == 1 && h_delta_reg == 1 && new_y < old_y && board_in[new_y][new_x] != 4'd15)    // Diagonal capture
                );

            4'd11: // Black Pawn
                board_valid = (
                    (old_y == 3'd1 && v_delta_reg == 2 && h_delta_reg == 0 && board_in[old_y+1][old_x] == 4'd15 && board_in[new_y][new_x] == 4'd15) || // Double forward from start
                    (v_delta_reg == 1 && h_delta_reg == 0 && new_y > old_y && board_in[new_y][new_x] == 4'd15) || // Single forward
                    (v_delta_reg == 1 && h_delta_reg == 1 && new_y > old_y && board_in[new_y][new_x] != 4'd15)    // Diagonal capture
                );

            default:
                board_valid = 1'd0;
        endcase
    end

    // Update board_out (combinational copy with optional update)
    always_comb begin
        board_out = board_in; // Default: copy everything

        if (board_valid) begin
            board_out[new_y][new_x] = board_in[old_y][old_x]; // Move the piece
            board_out[old_y][old_x] = 4'd15;                  // Empty the old square
        end
    end




endmodule