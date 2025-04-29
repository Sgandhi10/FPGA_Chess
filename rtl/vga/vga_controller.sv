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
    logic [9:0] hcount_int, vcount_int;
    // Increment counters for horizontal and vertical sync
    always_ff @(posedge vga_clk or negedge reset_n) begin
        if (!reset_n) begin
            hcount_int <= 0;
            vcount_int <= 0;
        end else begin
            if (hcount_int < 799) begin
                hcount_int <= hcount_int + 10'd1;
            end else begin
                hcount_int <= 'd0;
                if (vcount_int < 524) begin
                    vcount_int <= vcount_int + 10'd1;
                end else begin
                    vcount_int <= 10'd0;
                end
            end
        end
    end

    assign vga_hs = (hcount_int >= 655 && hcount_int < 751) ? 1'd0 : 1'd1;
    assign vga_vs = (vcount_int >= 489 && vcount_int < 491) ? 1'd0 : 1'd1;
    assign vga_sync_n = vga_hs | vga_vs;
    assign vga_blank_n = (hcount_int < 640 && vcount_int < 480) ? 1'd1 : 1'd0;

    assign hcount = (hcount_int < 640) ? hcount_int : 0;
    assign vcount = (vcount_int < 480) ? vcount_int : 0;
endmodule
