/*******************************************************************************
* File: tb_UART.sv
* Author: Soham Gandhi
* Date: 2025-04-13
* Description: Testbench for UART module with loopback between TX and RX.
*              Verifies correct data transmission and reception with FIFO and parity.
* Version: 1.0
*******************************************************************************/

`timescale 1ns/1ps

module tb_UART;

    // === Parameters ===
    localparam int DATA_WIDTH  = 8;
    localparam int BAUD_RATE   = 9600;
    localparam int CLOCK_FREQ  = 50_000_000;
    localparam int PARITY      = 1; // Even
    localparam int OVERSAMPLE  = 16;
    localparam real CLK_PERIOD = 1e9 / CLOCK_FREQ;

    // === DUT I/O ===
    logic clk;
    logic rst_n;

    logic data_valid;
    logic [DATA_WIDTH-1:0] data_in_tx;
    logic tx;
    logic rx;
    logic req_data;
    logic [DATA_WIDTH-1:0] data_out_rx;
    logic pending_data_rx;
    logic parity_error_rx;

    // === TX Stimulus Data ===
    logic [DATA_WIDTH-1:0] tx_data_array [0:15];

    // === DUT Instance ===
    UART #(
        .DATA_WIDTH(DATA_WIDTH),
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ),
        .PARITY(PARITY),
        .OVERSAMPLE(OVERSAMPLE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_valid(data_valid),
        .data_in_tx(data_in_tx),
        .tx(tx),
        .rx(rx),
        .req_data(req_data),
        .data_out_rx(data_out_rx),
        .pending_data_rx(pending_data_rx),
        .parity_error_rx(parity_error_rx)
    );

    // === Clock Generation ===
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // === Reset ===
    initial begin
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    // === Connect TX to RX for Loopback ===
    assign rx = tx;

    // === Initialize TX Data Array ===
    initial begin
        tx_data_array[0]  = 8'h55;
        tx_data_array[1]  = 8'hAA;
        tx_data_array[2]  = 8'hFF;
        tx_data_array[3]  = 8'h00;
        tx_data_array[4]  = 8'h3C;
        tx_data_array[5]  = 8'hC3;
        tx_data_array[6]  = 8'h69;
        tx_data_array[7]  = 8'h96;
        tx_data_array[8]  = 8'h01;
        tx_data_array[9]  = 8'hFE;
        tx_data_array[10] = 8'h10;
        tx_data_array[11] = 8'hEF;
        tx_data_array[12] = 8'hA5;
        tx_data_array[13] = 8'h5A;
        tx_data_array[14] = 8'h81;
        tx_data_array[15] = 8'h7E;
    end

    // === TX Driver ===
    initial begin
        data_valid = 0;
        data_in_tx = 0;

        wait(rst_n);
        #100;

        for (int i = 0; i < $size(tx_data_array); i++) begin
            @(posedge clk);
            data_in_tx = tx_data_array[i];
            data_valid = 1;
            @(posedge clk);
            data_valid = 0;
        end
    end

    // === RX Monitor ===
    int index = 0;
    initial begin
        req_data = 0;
        wait(rst_n);
        #200;

        forever begin
            @(posedge clk);
            if (pending_data_rx) begin
                req_data = 1;
                @(posedge clk);
                req_data = 0;

                @(posedge clk); // Wait for data_out_rx to update

                if (data_out_rx !== tx_data_array[index]) begin
                    $display("Mismatch @%0t ns: Sent = %h | Received = %h", $time, tx_data_array[index], data_out_rx);
                end else if (parity_error_rx) begin
                    $display("Parity error @%0t ns: Data = %h", $time, data_out_rx);
                end else begin
                    $display("Data match @%0t ns: %h", $time, data_out_rx);
                end

                index++;
                if (index == $size(tx_data_array)) begin
                    #1000;
                    $display("=== Simulation Complete ===");
                    $stop;
                end
            end
        end
    end

endmodule
