/*******************************************************************************
* File: UART.sv
* Author: Soham Gandhi
* Date: 2025-04-13
* Description: Full UART module with FIFOs for TX and RX, including baud rate
*              generator and parity support.
* Version: 1.0
*******************************************************************************/

`timescale 1ns/1ps

module UART #(
    parameter int DATA_WIDTH  = 8,
    parameter int BAUD_RATE   = 9600,
    parameter int CLOCK_FREQ  = 50_000_000,
    parameter int PARITY      = 1,    // 0: None, 1: Even, 2: Odd
    parameter int OVERSAMPLE  = 16
) (
    input  logic clk,
    input  logic rst_n,

    // TX Interface
    input  logic data_valid,
    input  logic [DATA_WIDTH-1:0] data_in_tx,
    output logic tx,

    // RX Interface
    input  logic rx,
    input  logic req_data,
    output logic [DATA_WIDTH-1:0] data_out_rx,
    output logic pending_data_rx,
    output logic parity_error_rx
);

    // === Baud Tick Generator ===
    logic baud_tick;
    Baud_Tick #(
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ),
        .OVERSAMPLE(OVERSAMPLE)
    ) baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // === TX FIFO ===
    logic fifo_tx_push, fifo_tx_pop;
    logic [DATA_WIDTH-1:0] fifo_tx_data_in, fifo_tx_data_out;
    logic fifo_tx_full, fifo_tx_empty;

    FIFO #(
        .N_BITS(DATA_WIDTH),
        .N_SIZE(16)
    ) fifo_tx (
        .clk(clk),
        .rst_n(rst_n),
        .push(fifo_tx_push),
        .pop(fifo_tx_pop),
        .data_in(fifo_tx_data_in),
        .data_out(fifo_tx_data_out),
        .full(fifo_tx_full),
        .empty(fifo_tx_empty)
    );

    assign fifo_tx_push    = data_valid;
    assign fifo_tx_data_in = data_in_tx;

    // === UART TX ===
    logic start, tx_busy, tx_busy_d, pending;
    
    UART_TX #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ)
    ) uart_tx (
        .clk(clk),
        .baud_tick(baud_tick),
        .rst_n(rst_n),
        .start(start),
        .data_in(fifo_tx_data_out),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // TX Control Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start         <= 0;
            fifo_tx_pop   <= 0;
            pending       <= 0;
            tx_busy_d     <= 0;
        end else begin
            tx_busy_d     <= tx_busy;
            fifo_tx_pop   <= 0;

            // Start condition: FIFO not empty and TX idle
            if (!fifo_tx_empty && !tx_busy)
                start <= 1;
            else if (start && tx_busy)
                start <= 0;

            // Pop once per byte
            if (start && !pending) begin
                fifo_tx_pop <= 1;
                pending     <= 1;
            end

            // Clear pending when tx_busy falls
            if (tx_busy_d && !tx_busy)
                pending <= 0;
        end
    end

    // === RX FIFO ===
    logic fifo_rx_push, fifo_rx_pop;
    logic [DATA_WIDTH-1:0] fifo_rx_data_in, fifo_rx_data_out;
    logic fifo_rx_full, fifo_rx_empty;

    FIFO #(
        .N_BITS(DATA_WIDTH),
        .N_SIZE(16)
    ) fifo_rx (
        .clk(clk),
        .rst_n(rst_n),
        .push(fifo_rx_push),
        .pop(fifo_rx_pop),
        .data_in(fifo_rx_data_in),
        .data_out(fifo_rx_data_out),
        .full(fifo_rx_full),
        .empty(fifo_rx_empty)
    );

    // === UART RX ===
    logic data_valid_rx, data_valid_rx_d;

    UART_RX #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ),
        .PARITY(PARITY),
        .OVERSAMPLE(OVERSAMPLE)
    ) uart_rx (
        .clk(clk),
        .baud_tick(baud_tick),
        .rst_n(rst_n),
        .rx(rx),
        .data_out(fifo_rx_data_in),
        .data_valid(data_valid_rx),
        .parity_error(parity_error_rx)
    );

    // Rising edge detect for data_valid_rx
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) data_valid_rx_d <= 0;
        else        data_valid_rx_d <= data_valid_rx;
    end

    assign fifo_rx_push      = data_valid_rx & ~data_valid_rx_d;
    assign fifo_rx_pop       = req_data;
    assign data_out_rx       = fifo_rx_data_out;
    assign pending_data_rx   = !fifo_rx_empty;

endmodule
