/*******************************************************************************
* File        : Baud_Tick.sv
* Author      : Soham Gandhi
* Date        : 2025-04-13
* Description : Creates a baud rate tick for UART communication.
* Version     : 1.0
*******************************************************************************/

`timescale 1ns/1ps

module Baud_Tick #(
    // === Parameters ===
    parameter int BAUD_RATE   = 9600,          // Baud rate in bps
    parameter int CLOCK_FREQ  = 50_000_000,    // Clock frequency in Hz
    parameter int OVERSAMPLE  = 16             // Oversampling factor
) (
    // === Inputs ===
    input  logic clk,     // System clock
    input  logic rst_n,   // Active-low reset

    // === Outputs ===
    output logic baud_tick // Baud rate tick signal
);

    // === Local Parameters ===
    localparam int FRACTIONAL = 16; // Fixed-point (24.8 format uses 8 fractional bits)
    localparam int BAUD_DIV   = CLOCK_FREQ / (BAUD_RATE * OVERSAMPLE);

    // Scaled fractional part for precision (BAUD_FRAC in 24.8 fixed-point)
    localparam logic [63:0] BAUD_FRAC = 
        ((CLOCK_FREQ * (1 << FRACTIONAL)) / (BAUD_RATE * OVERSAMPLE)) - 
        (BAUD_DIV << FRACTIONAL);

    // === Internal Registers ===
    int accumulator;

    // === Baud Tick Generation ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= 0;
            baud_tick   <= 0;
        end else begin
            accumulator += (1 << FRACTIONAL);
            baud_tick   <= 0;

            if (accumulator >= (BAUD_DIV << FRACTIONAL)) begin
                accumulator <= (accumulator - (BAUD_DIV << FRACTIONAL)) + BAUD_FRAC;
                baud_tick   <= 1;
            end
        end
    end

endmodule : Baud_Tick
