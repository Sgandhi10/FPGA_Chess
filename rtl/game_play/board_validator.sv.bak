module board (
    input logic         CLOCK_50,
    input logic         reset_n,

    input logic  [2:0]  old_x, old_y,
    input logic  [2:0]  new_x, new_y
    input logic  [2:0]  piece_type
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
    board_valid = 1'd0; //false default

    case (piece_type)
        4'd0, 4'd6:  //Rooks 

        4'd1, 4d'7:

        4'd2,









end




endmodule