/*******************************************************************************
* File: tb_UART_Individual.sv
* Author: Soham Gandhi
* Date: 2025-04-13
* Description: Full system testbench for UART TX and RX modules. Send data from 
* TX and receive it on RX. Check for data integrity and parity.
* Version: 1.0
*******************************************************************************/

`timescale 1ns/1ps

module tb_UART_Individual();
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
    wire [DATA_WIDTH-1:0] data_out;
    wire data_valid;
    wire parity_error;
    
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
    ) uart_tx (
        .clk(clk),
        .baud_tick(baud_tick),
        .rst_n(rst_n),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Instantiate the UART RX module
    UART_RX #(
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH),
        .CLOCK_FREQ(CLOCK_FREQ),
        .PARITY(PARITY),
        .OVERSAMPLE(OVERSAMPLE) 
    ) uart_rx (
        .clk(clk),
        .baud_tick(baud_tick),
        .rst_n(rst_n),
        .rx(tx), // Connect TX output to RX input for loopback
        .data_out(data_out),
        .data_valid(data_valid),
        .parity_error(parity_error)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #(2 * CLK_PERIOD) rst_n = 1; // Release reset after two clock cycles
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
        for (int i = 0; i < $size(sample_data); i++) begin
            wait (!tx_busy); // Ensure previous TX is idle
            data_in = sample_data[i];
            start = 1;
            #(2*BAUD_PERIOD); // Wait for one baud period to simulate start bit
            start = 0;
            @(negedge tx_busy); // Wait for TX to complete before next byte
        end

        // Finish simulation after all data is transmitted
        #100;
        $stop;
    end

    // Monitor received data and check for parity errors
    initial begin
        @(posedge rst_n);
        #10; // Wait for a few clock cycles
        $display("Reset released, starting reception...");
        for (int i = 0; i < $size(sample_data); i++) begin
            @(posedge data_valid);
            if (data_out != sample_data[i]) begin
                $display("Data mismatch! Expected: %h, Received: %h", sample_data[i], uart_rx.data_out);
            end else if (parity_error) begin
                $display("Parity error detected for data: %h", uart_rx.data_out);
            end else begin
                $display("Data received correctly: %h", uart_rx.data_out);
            end
        end
        $stop;
    end
endmodule