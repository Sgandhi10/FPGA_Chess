/*******************************************************************************
* File: common_enums.sv
* Author: Soham Gandhi
* Date: 2025-04-22
* Description: Enums used in multiple modules
* Version: 1.0
*******************************************************************************/

package common_enums;
    typedef enum logic [1:0] {
        TITLE_SCREEN,
        PLAYER_SCREEN,
        SETUP_SCREEN,
        CHESS_SCREEN
    } screen_state_t;

    typedef enum logic [1:0] {
        PLAYER_SEL,
        PIECE_SEL,
        POS_SEL,
        MOVE_VAL
    } move_state_t;
endpackage