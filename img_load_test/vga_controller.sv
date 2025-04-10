/*******************************************************************************
* File: vga_controller.sv
* Author: Soham Gandhi
* Date: 2025-03-27
* Description: VGA Controller module
* Version: 1.0
*******************************************************************************/

module vga_controller(
    input logic vga_clk,               // 25 MHz clock
    input logic reset_n,           // Active low reset

    output logic vga_hs,           // Horizontal sync signal
    output logic vga_vs,           // Vertical sync signal
    output logic vga_blank_n,      // Blank signal (active high)
    output logic vga_sync_n,       // Sync signal (active low)

    // Optional signals for pixel coordinates
    output logic [9:0] hcount,     // Current pixel x-coordinate
    output logic [9:0] vcount      // Current pixel y-coordinate
);
    // Increment counters for horizontal and vertical sync
    always_ff @(posedge vga_clk or negedge reset_n) begin
        if (!reset_n) begin
            hcount <= 0;
            vcount <= 0;
        end else begin
            if (hcount < 799) begin
                hcount <= hcount + 'd1;
            end else begin
                hcount <= 'd0;
                if (vcount < 524) begin
                    vcount <= vcount + 'd1;
                end else begin
                    vcount <= 'd0;
                end
            end
        end
    end

    assign vga_hs = (hcount >= 655 & hcount < 751) ? 'd0 : 'd1;
    assign vga_vs = (vcount >= 489 & vcount < 491) ? 'd0 : 'd1;
    assign vga_sync_n = vga_hs | vga_vs; // Active low sync signal
    assign vga_blank_n = (hcount < 640 && vcount < 480) ? 'd1 : 'd0; // Active high blank signal

endmodule