/*******************************************************************************
* File: tb_UART_Controller.sv
* Author: Soham Gandhi
* Date: 2025-04-03
* Description: Test bench for the UART controller
* Version: 1.0
*******************************************************************************/
`timescale 1ns/1ns
module tb_UART_Controller ();
    ////////////////////////////////////////////////////////////////////////////
    // System Signals
    ////////////////////////////////////////////////////////////////////////////
    // System Clock (50 MHz)
    logic sys_clk;
    initial begin
        sys_clk = 0;
        forever #25 sys_clk = ~sys_clk; // 50 MHz clock
    end
    // UART Clock (1152000 Baud Rate)
    logic uart_clk;
    initial begin
        uart_clk = 0;
        forever #434 uart_clk = ~uart_clk; // 1152000 Baud Rate
    end

    // Reset Signal
    logic rst_n;
    initial begin
        rst_n = 0;
        #100 rst_n = 1; // Release reset after 100 ns
    end

    ////////////////////////////////////////////////////////////////////////////
    // DUT Instantiation
    ////////////////////////////////////////////////////////////////////////////
    // UART RX and TX lines
    logic rx;
    logic tx;

    // Input FIFO Signals
    logic i_push;
    logic [31:0] i_data;
    logic i_fifo_full;
    logic i_fifo_empty;

    // Output FIFO Signals
    logic o_pop;
    logic [31:0] o_data;
    logic o_fifo_full;
    logic o_fifo_empty;

    // Instantiate the UART Controller
    UART_Controller #(
        .DATA_WIDTH(32),
        .PARITY_BIT(1)
    ) dut (
        .rx(rx),
        .tx(tx),
        .sys_clk(sys_clk),
        .uart_clk(uart_clk),
        .rst_n(rst_n),
        .i_push(i_push),
        .i_data(i_data),
        .i_fifo_full(i_fifo_full),
        .i_fifo_empty(i_fifo_empty),
        .o_pop(o_pop),
        .o_data(o_data),
        .o_fifo_full(o_fifo_full),
        .o_fifo_empty(o_fifo_empty)
    );

    ////////////////////////////////////////////////////////////////////////////
    // Test Bench
    ////////////////////////////////////////////////////////////////////////////
    // Test Data Packets
    int [5] test_data ={
        32'b00000000,
        32'bFFFFFFFF,
        32'b12345678,
        32'b87654321,
        32'bF0F0F0F0
    };

    // RX Stimulus Generation
    initial begin
        // Initialize RX line to high (idle state)
        rx = 1'b1;
        #100; // Wait for reset to release

        // Send test data packets
        foreach (test_data[i]) begin
            // Start bit (low)
            rx = 1'b0;
            #434; // Wait for one bit time

            // Send data bits
            for (int j = 0; j < 32; j++) begin
                rx = test_data[i][j];
                #434; // Wait for one bit time
            end

            // Stop bit (high)
            rx = 1'b1;
            #434; // Wait for one bit time
        end
        // Finish simulation after sending all packets
        #1000;
        $stop;
    end

    // Checker for Output FIFO
    initial begin
        o_pop = 1'b0;
        #100; // Wait for reset to release

        // Check if output FIFO is empty
        if (o_fifo_empty) begin
            $display("Output FIFO is empty at time %0t", $time);
        end else begin
            // Pop data from output FIFO
            o_pop = 1'b1;
            #434; // Wait for one bit time
            o_pop = 1'b0;
            $display("Popped data: %h at time %0t", o_data, $time);
        end

        // Finish simulation after checking output FIFO
        #1000;
        $stop;
    end
    
endmodule