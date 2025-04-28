/*******************************************************************************
* File: state_sync.sv
* Author: Soham Gandhi
* Date: 2025-04-23
* Description: This module synchronizes a state signal from the 50 MHz clock domain to the VGA clock domain.
* Version: 1.0
*******************************************************************************/
module state_sync #(
    parameter int bits = 1
) (
    input  wire                clk_vga,    // VGA clock domain
    input  wire [bits-1:0]     state_50,   // Signal from CLOCK_50 domain
    output reg  [bits-1:0]     state_vga   // Synchronized signal in VGA_CLK domain
);
    // Two-stage sync registers
    (* syn_synchronizer = "true" *) reg [bits-1:0] sync1;
    (* syn_synchronizer = "true" *) reg [bits-1:0] sync2;

    always_ff @(posedge clk_vga) begin
        sync1     <= state_50;   // First stage
        sync2     <= sync1;      // Second stage
        state_vga <= sync2;
    end

endmodule
