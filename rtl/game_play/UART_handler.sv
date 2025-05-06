/*******************************************************************************
* File: UART_handler.sv
* Author: Soham Gandhi
* Date: 2025-05-01
* Description: This module handles all the communication aspects for the UART 
* protocol. This module is meant to help separate the UART aspects from the other 
* aspects, and keep the top level module clean.
* Version: 1.0
*******************************************************************************/
import common_enums::*;

module UART_handler(
    // System Signals
    input  logic clk,
    input  logic reset_n,

    input  logic [3:0]  disp_board[8][8],
    input  logic [11:0] output_packet,
    input  logic [3:1]  SW,
    input  logic 		setup_complete,
    input  logic        moved,
    input  logic        won,
    input  logic        lost_in,

    output logic [3:0]  stable_board[8][8],
    output logic        parity_error_rx,
    output logic        override,
    output logic        start_counter,
    output logic        player,
    output logic        curr_player,
    output logic [15:0] data_out_rx,
    output logic [1:0]  mode_sel,
    output logic        load_counter,
    // output logic        lost_out,
    // output logic        won_out,

    // RX/TX
    input  logic RX,
    output logic TX
);
    // TX
    logic data_in_valid;
    logic [15:0] data_in_tx;

    // RX
    logic req_data, pending_data_rx;
    UART #(
        .DATA_WIDTH(16),
        .BAUD_RATE(115200),
        .CLOCK_FREQ(50_000_000),
        .PARITY(1),
        .OVERSAMPLE(16)
    ) uart_inst (
        .clk(clk),
        .rst_n(reset_n),
        
        .data_valid(data_in_valid),
        .data_in_tx(data_in_tx),
        .tx(TX),

        .rx(RX),
        .req_data(req_data),
        .data_out_rx(data_out_rx),
        .pending_data_rx(pending_data_rx),
        .parity_error_rx(parity_error_rx)
    );

    uart_state_t uart_state;
    logic [2:0] pos1_x, pos1_y, pos2_x, pos2_y;
    logic [1:0] mode_sel_tx;
    logic mode_sel_selector;
    assign mode_sel = (mode_sel_selector) ? mode_sel_tx : SW[2:1];
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            req_data <= 0;
            player <= 0;
            override <= 0;
            start_counter <= 0;
            data_in_tx <= 0;
            data_in_valid <= 0;

            // Stable Board default (player 0) -> White
            stable_board[0] <= '{0, 1, 2, 3, 4, 2, 1, 0};
            stable_board[1] <= '{default: 5};
            stable_board[2] <= '{default: 15};
            stable_board[3] <= '{default: 15};
            stable_board[4] <= '{default: 15};
            stable_board[5] <= '{default: 15};
            stable_board[6] <= '{default: 11};
            stable_board[7] <= '{6, 7, 8, 9, 10, 8, 7, 6};

            curr_player <= 0;
            uart_state <= WAIT_DATA;
            mode_sel_selector <= 0;
            load_counter <= 0;
            // lost_out <= 0;
            // won_out <= 0;
        end else begin
            // TX Port Handler
            if (setup_complete) begin
                player <= SW[3]; // Toggle player on key press
                data_in_tx <= {2'b10, SW[3], mode_sel, 11'b0};
                data_in_valid <= 1;

                // Setup Stable board
                if (SW[3]) begin
                    stable_board[0] <= '{6, 7, 8, 10, 9, 8, 7, 6};
                    stable_board[1] <= '{default: 11};
                    stable_board[6] <= '{default: 5};
                    stable_board[7] <= '{0, 1, 2, 4, 3, 2, 1, 0};
                end
                load_counter <= 1;
                start_counter <= 0;
            end else if (moved && !override) begin
                load_counter <= 0;
                start_counter <= 1;
                curr_player <= ~player;
                
                // Update Board
                for (int i = 0; i < 8; i++) begin
                    for (int j = 0; j < 8; j++) begin
                        stable_board[i][j] <= disp_board[i][j];
                    end
                end
                
                data_in_tx <= {2'b00, output_packet, 2'b00};
                data_in_valid <= 1;
            // end else if (won || lost_in) begin
            //     data_in_tx <= {2'b11, won, 13'b0};
            //     data_in_valid <= 1;
            end else begin
                load_counter <= 0;
                data_in_valid <= 0;

                // RX handler
                case(uart_state)
                WAIT_DATA: begin
                    override <= 0;
                    start_counter <= 0;
                    if (pending_data_rx) begin
                        req_data <= 1;
                        uart_state <= REQ_DATA;
                    end
                end
                REQ_DATA: begin
                    start_counter <= 0;
                    req_data <= 0;
                    override <= 0;
                    uart_state <= HANDLE_DATA;
                end
                HANDLE_DATA: begin
                    case (data_out_rx[15:14])
                        2'b10: begin
                            player <= ~data_out_rx[13];
                            override <= 1;
                            start_counter <= 0;
                            if (!data_out_rx[13]) begin
                                stable_board[0] <= '{6, 7, 8, 10, 9, 8, 7, 6};
                                stable_board[1] <= '{default: 11};
                                stable_board[6] <= '{default: 5};
                                stable_board[7] <= '{0, 1, 2, 4, 3, 2, 1, 0};
                            end
                            mode_sel_selector <= 1;
                        end
                        2'b00: begin
                            stable_board[pos2_y][pos2_x] <= stable_board[pos1_y][pos1_x];
                            stable_board[pos1_y][pos1_x] <= 15;
                            start_counter <= 1;
                            curr_player <= ~curr_player;
                            override <= 0;
                        end
                        // 2'b11: begin
                        //     lost_out <= data_out_rx[13];
                        //     won_out <= ~data_out_rx[13];
                        //     override <= 0;
                        //     start_counter <= 0;
                        // end
                        default: begin
                            start_counter <= 0;
                            override <= 0;
                        end
                    endcase
                    uart_state <= WAIT_DATA;
                end
            endcase
            end 
        end
    end

    always_comb begin
        pos1_x = 3'd7 - data_out_rx[13:11];
        pos1_y = 3'd7 - data_out_rx[10:8];
        pos2_x = 3'd7 - data_out_rx[7:5];
        pos2_y = 3'd7 - data_out_rx[4:2];

        mode_sel_tx = data_out_rx[12:11];
    end
endmodule