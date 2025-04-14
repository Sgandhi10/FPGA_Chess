/*******************************************************************************
* File: tb_UART_RX.sv
* Author: Soham Gandhi
* Date: 2025-04-10
* Description: Testbench for UART RX module
* Version: 1.0
*******************************************************************************/
`timescale 1ns/1ps

module tb_UART_RX();
    // Parameters
    localparam BAUD_RATE      = 9600;                       // Baud rate in bps
    localparam CLOCK_FREQ     = 50_000_000;                   // Clock frequency in Hz
    localparam DATA_WIDTH     = 8;                          // Number of data bits
    localparam PARITY         = 1;                          // Parity (0: None, 1: Even, 2: Odd)
    localparam CLK_PERIOD     = 20;                         // Clock period in ns (for TB)
    localparam real BIT_PERIOD     = 1e9 / BAUD_RATE;    // Period per UART bit


    // Inputs
    logic clk;
    logic baud_tick;
    logic rst_n;
    logic rx;
    
    // Outputs
    logic [DATA_WIDTH-1:0] data_out;
    logic data_valid;
    logic parity_error;

    // Instantiate the Baud_Tick module to generate baud rate ticks
    Baud_Tick #(
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ),
        .OVERSAMPLE(16) // Oversampling factor
    ) baud_tick_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );
    
    // Instantiate the UART RX module
    UART_RX #(
        .BAUD_RATE(BAUD_RATE),
        .DATA_WIDTH(DATA_WIDTH),
        .CLOCK_FREQ(CLOCK_FREQ),
        .PARITY(PARITY),
        .OVERSAMPLE(16) 
    ) uut (
        .clk(clk),
        .baud_tick(baud_tick),
        .rst_n(rst_n),
        .rx(rx),

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
        wait(rst_n == 1);
        $display("Reset released, starting transmission...");
        
        // Loop through each sample data and send it to the UART RX module
        for (int i = 0; i < 8; i++) begin
            $display("Sending data: %h", sample_data[i]);
            // Start bit (active low)
            rx = 0;
            #(BIT_PERIOD);
            
            // Send data bits
            for (int j = 0; j < DATA_WIDTH; j++) begin
                rx = sample_data[i][j];
                #(BIT_PERIOD);
            end

            // Parity bit (if applicable)
            if (PARITY == 1) begin
                // Even parity: parity bit = 1 if number of 1s in data is even
                rx = ~^sample_data[i];
                #(BIT_PERIOD);
            end else if (PARITY == 2) begin
                // Odd parity: parity bit = 1 if number of 1s in data is odd
                rx = ^sample_data[i];
                #(BIT_PERIOD);
            end

            // Stop bit (active high)
            rx = 1;
            #(2*BIT_PERIOD);
            
            // Wait for a short period before sending the next byte
            #(2 * BIT_PERIOD);
        end
        
        // Finish simulation after sending all data
        #(2 * BIT_PERIOD);
    end

    // Monitor outputs
    initial begin
        wait(rst_n == 1);
        $display("Reset released, monitoring outputs...");
        for (int z = 0; z < $size(sample_data); z++) begin
            @(posedge data_valid);
            assert (data_out == sample_data[z]) else begin
                $error("Data mismatch! Expected: %h, Received: %h", sample_data[z], data_out);
            end
            if (PARITY == 1) begin
                assert (parity_error) begin
                    $error("Parity error detected for data: %h", sample_data[z]);
                end else 
                    $display("Data received: %h, Parity error: %b", data_out, parity_error);
                end
            end
        $display("All data received, stopping simulation.");
        #(2 * BIT_PERIOD) $stop;
    end
endmodule