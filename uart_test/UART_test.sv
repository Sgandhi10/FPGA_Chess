/*******************************************************************************
* File: UART_test.sv
* Author: Soham Gandhi
* Date: 2025-04-14
* Description: Hardware test program to ensure UART works on the FPGA.
* Version: 1.0
*******************************************************************************/

module UART_test (
    input   logic        CLOCK_50,
    input   logic [3:0]  KEY,
    
    // For future use
    input   logic [9:0]  SW,
    output  logic [9:0]  LED,

    // RX/TX signals
    input   logic        RXD,
    output  logic        TXD
);
    // Internal signals
    logic rst_n, clk;
    logic [15:0] data_in_tx;
    logic data_valid;
    logic req_data;
    logic [15:0] data_out_rx;
    logic pending_data_rx;
    logic parity_error_rx;

    // Active low reset
    assign rst_n = KEY[0]; 
    assign clk = CLOCK_50;
    assign data_in_tx = {SW[9:0], 6'd0}; // 16-bit data to be sent over UART

    // Key press handling
    keypress k1 (
        .clock (clk),
        .reset_n (rst_n),
        .key_in (KEY[1]),
        .enable_out (data_valid)
    );
    
    // UART instance
    UART #(
		  .DATA_WIDTH(16),
        .BAUD_RATE(115200),
        .CLOCK_FREQ(50_000_000),
        .PARITY(1),
        .OVERSAMPLE(16)
	 ) uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_valid(data_valid),
        .data_in_tx(data_in_tx),
        .tx(TXD),
        .rx(RXD),
        .req_data(req_data),
        .data_out_rx(data_out_rx),
        .pending_data_rx(pending_data_rx),
        .parity_error_rx(parity_error_rx)
    );

    // Always block for controlling LEDs based on received data
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_data <= 0;
            LED[9:0] <= 0;
        end
        else begin
            req_data <= 0;
            if (pending_data_rx) begin
                req_data <= 1;
            end
            if (req_data) begin
                LED[9:0] <= data_out_rx[15:6]; // Display received data on LEDs
            end
        end
    end

endmodule
