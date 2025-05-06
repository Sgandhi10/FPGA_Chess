/*******************************************************************************
* File: hex_counter.sv
* Author: Soham Gandhi
* Date: 2025-04-22
* Description: This module is a counter that will show the remaining time in 
*              normal time format. MM:SS:mm
* Version: 1.0
*******************************************************************************/
import common_enums::*;

module hex_counter #(
    parameter int CLK_FREQ_HZ = 50_000_000 // Clock frequency (50 MHz)
)(
    input  logic             clk,         // 50 MHz system clock
    input  logic             reset_n,     // Active-low reset
    input  logic             load,
    input  logic             start,       // Start counter
    input  logic             count,
    input  logic [1:0]       mode_sel,    // Mode selector for initial time
    output logic [6:0]       hex0, hex1, hex2, hex3, hex4, hex5,
    output logic             time_up      // Active-high when countdown ends
);

    // Max time = 30 min = 180000 centiseconds (18 bits)
    logic [17:0] total_cs;       // Countdown time in centiseconds (1/100s)
    logic [17:0] initial_time;   // Time preset from mode_sel
    logic [25:0] clk_counter;    // Clock divider for 100Hz tick
    logic        start_flag;     // starts clock
    logic        loaded;

    // Time breakdown into BCD units
    logic [7:0] cs, sec, min;

    // Set initial time based on mode_sel
    always_comb begin
        case (mode_sel)
            2'd0: initial_time = 18'd6000;     // 1 min
            2'd1: initial_time = 18'd18000;    // 3 min
            2'd2: initial_time = 18'd60000;    // 10 min
            2'd3: initial_time = 18'd180000;   // 30 min
            default: initial_time = 18'd6000;
        endcase
    end

    // Main countdown logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            total_cs    <= 0;
            clk_counter <= 0;
            start_flag  <= 0;
            loaded <= 0;
        end else begin
            // Load time once when entering CHESS_SCREEN
            if (load) begin
                loaded <= 1;
                total_cs <= initial_time;
            end
            if (!start_flag && start) begin
                start_flag <= 1;
            end else if (!start_flag && !loaded) begin
                total_cs <= initial_time;
            end
            
            if (start_flag && total_cs > 0 && count) begin
                clk_counter <= clk_counter + 1;
                if (clk_counter == (CLK_FREQ_HZ / 100 - 1)) begin
                    clk_counter <= 0;
                    total_cs    <= total_cs - 1;
                end
            end
        end
    end
    
    assign time_up = (total_cs == 0);

    // Convert total_cs to MM:SS:mm
    assign cs  = total_cs % 100;
    assign sec = (total_cs / 100) % 60;
    assign min = (total_cs / 6000);

    // Instantiate hex_display modules
    hex_display hex0_disp (.hex_num(cs  % 10), .segments(hex0));
    hex_display hex1_disp (.hex_num(cs  / 10), .segments(hex1));
    hex_display hex2_disp (.hex_num(sec % 10), .segments(hex2));
    hex_display hex3_disp (.hex_num(sec / 10), .segments(hex3));
    hex_display hex4_disp (.hex_num(min % 10), .segments(hex4));
    hex_display hex5_disp (.hex_num(min / 10), .segments(hex5));

endmodule
