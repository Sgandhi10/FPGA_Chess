/*******************************************************************************
* File: tb_UART_TX.sv
* Author: Soham Gandhi
* Date: 2025-04-13
* Description: Testbench for the UART TX module.
* Version: 1.0
*******************************************************************************/

`timescale 1ns/1ps

module tb_UART_TX ();
    // Parameters
    localparam DATA_WIDTH = 8; // Data width in bits
    localparam BAUD_RATE = 9600; // Baud rate
    localparam CLOCK_FREQ = 50_000_000; // Clock frequency in Hz
    localparam OVERSAMPLE = 16; // Oversampling factor
    localparam PARITY = 1; // 0: None, 1: Even, 2: Odd
    localparam CLK_PERIOD = 20; // Clock period in ns (for TB)
    localparam BAUD_PERIOD = 1e9 / BAUD_RATE; // Period per UART bit

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [DATA_WIDTH-1:0] data_in;

    // Outputs
    wire tx;
    wire tx_busy;

    wire baud_tick; // Baud rate tick signal

    // Instantiate the Baud_Tick module to generate baud rate ticks
    Baud_Tick #(
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ),
        .OVERSAMPLE(OVERSAMPLE) // Oversampling factor
    ) baud_tick_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // Instantiate the UART TX module
    UART_TX #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ)
    ) uut (
        .clk(clk),
        .baud_tick(baud_tick),
        .rst_n(rst_n),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #20 rst_n = 1; // Release reset after two clock cycles
    end

    // Sample Data Array
    reg [DATA_WIDTH-1:0] sample_data [8] = '{
        8'h55, // 01010101
        8'hAA, // 10101010
        8'hFF, // 11111111
        8'h00, // 00000000
        8'h7F, // 01111111
        8'h80, // 10000000
        8'h3C, // 00111100
        8'hC3  // 11000011
    };

    // Stimulus generation
    initial begin
        // Wait for reset to be released
        data_in = 0;
        start = 0;
        @(posedge rst_n);
        #10; // Wait for a few clock cycles

        // Loop through sample data and transmit each byte
        for (int i = 0; i < 8; i++) begin
            data_in = sample_data[i];
            start = 1; // Start transmission
            #(BAUD_PERIOD); // Wait for a few clock cycles
            start = 0; // Stop transmission
             @(negedge tx_busy); // Wait until transmission is busy
        end

        // Finish simulation after all data is transmitted
        #100;
        $stop;
    end

    // Monitor the transmission
    initial begin
        $monitor("Time: %0t | Data: %h | TX: %b | TX Busy: %b", $time, data_in, tx, tx_busy);
    end
endmodule