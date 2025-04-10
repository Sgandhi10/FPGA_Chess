/*******************************************************************************
* File: UART_Controller.sv
* Author: Soham Gandhi
* Date: 2025-04-03
* Description: A simple uart controller module to send data between two devices
* Version: 1.0
*******************************************************************************/

module UART_Controller #(
    parameter DATA_WIDTH=32,
    parameter PARITY_BIT=1
) (
    // UART lines
    input   rx,
    output  tx,

    // System Signals
    input sys_clk,
    input uart_clk,
    input rst_n,

    // Input Fifo Signals
    input                       i_push,
    input  [DATA_WIDTH-1 : 0]   i_data,
    output                      i_fifo_full,
    output                      i_fifo_empty,

    // Output Fifo Signals
    input                       o_pop,
    output [DATA_WIDTH-1 : 0]   o_data,
    output                      o_fifo_full,
    output                      o_fifo_empty
);
    // Input FIFO
    uart_fifo (
        
    )

    // Output FIFO

    always_ff @(posedge uart_clk or negedge rst_n) begin
        if (!rst_n) begin
            
    end
endmodule
