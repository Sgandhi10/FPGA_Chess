/*******************************************************************************
* File: vga_frame_buffer.sv
* Author: Soham Gandhi
* Date: 2025-04-06
* Description: This file will automatically update the 2-port ram with the new
*   data based on the asynchronous buffer from the application.
* Version: 1.0
*******************************************************************************/

module vga_frame_buffer #(
    // Parameters
    parameter SCREEN_WIDTH = 640;  // Screen width in pixels
    parameter SCREEN_HEIGHT = 480; // Screen height in pixels
    parameter COLOR_DEPTH = 8;     // Color depth (bits per channel)
) (
    // System Signals
    input logic sys_clk;
    input logic vga_clk;
    input logic reset_n;
    
    // data from the application
    input logic [23:0] data_in [640][480]; // 24-bit color data (RGB)
    input logic wren, // Write enable signal for the RAM

    // 2-Port RAM
    output  logic [18:0]                addr;
    input   logic [23:0]                data;
);
    localparam int MAX = SCREEN_HEIGHT * SCREEN_WIDTH;

    // Instantiate the 2-Port RAM
    RAM_2P ram (
        .data_in(data),
        .inclock(sys_clk),
        .outclock(vga_clk),
        .rdaddress(addr),
        .wraddress(addr_counter),
        .wren(wren), // Always write to the RAM
        .q(data) // Output data from the RAM
    );

    // Address counter for the 2-Port RAM
    logic [18:0] addr_counter;
    
    always_ff @(posedge sys_clk or negedge reset_n) begin
        if (!reset_n) begin
            addr_counter <= '0;
        end else begin
            if (addr_counter < MAX) begin
                addr_counter <= addr_counter + 'd1; 
            end else begin
                addr_counter <= '0; // Reset the counter after reaching max
            end
        end
    end

    assign addr = addr_counter;
    
    // Write data to the 2-Port RAM based on the address counter
    always_ff @(posedge vga_clk or negedge reset_n) begin
        if (!reset_n) begin
            data <= '0;
        end else begin
            data <= data_in[addr_counter % SCREEN_WIDTH][addr_counter / SCREEN_WIDTH];
        end
    end
endmodule