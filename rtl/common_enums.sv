/*******************************************************************************
* File: common_enums.sv
* Author: Soham Gandhi
* Date: 2025-04-22
* Description: Enums used in multiple modules
* Version: 1.0
*******************************************************************************/

package common_enums;
    typedef enum logic [2:0] {
        TITLE_SCREEN,
        PLAYER_SCREEN,
        SETUP_SCREEN,
        CHESS_SCREEN,
        WON_END_SCREEN,
        LOST_END_SCREEN
    } screen_state_t;

    typedef enum logic [1:0] {
        PLAYER_SEL,
        PIECE_SEL,
        POS_SEL,
        MOVE_VAL
    } move_state_t;

    typedef enum logic [1:0] {
        WAIT_DATA,
        REQ_DATA,
        HANDLE_DATA
    } uart_state_t;

    // typedef enum logic [3:0] {
    //     EMPTY,
    //     BLACK_PAWN,

    // } chess_pieces;
endpackage