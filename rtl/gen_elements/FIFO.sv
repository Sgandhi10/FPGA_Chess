/*******************************************************************************
* File: FIFO.sv
* Author: Soham Gandhi
* Date: 2025-03-14
* Description: This file creates a basic FIFO module capable of storing N elements
*              and performing basic operations like push and pop.
* Version:  2.0 (SG): Added ability to work with push and pop on operations on the 
*                     same cycle.
*           1.0 (SG): Capable of storing elements and performing push and pop 
*                     operations on different clock cycles.
*******************************************************************************/

module FIFO #(
    parameter N_BITS = 64,
    parameter N_SIZE = 8    // Assume N_SIZE is a power of 2 (No need for wrap around logic)
) (
    input   logic clk,
    input   logic rst_n,
    input   logic push,
    input   logic pop,
    input   logic [N_BITS-1:0] data_in,

    output  logic [N_BITS-1:0] data_out,
    output  logic full,
    output  logic empty
);
    // Verify that N_SIZE is a power of 2 (Generate Block)
    //if (N_SIZE != (2 ** ($clog2(N_SIZE)))) begin
    //    $error("N_SIZE must be a power of 2, but is %0d, %0d", N_SIZE, 2 ** ($clog2(N_SIZE)));
    //end

    logic [N_BITS-1:0] data [N_SIZE-1:0];
    logic [$clog2(N_SIZE):0] head, elements;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            head <= 0;
            elements <= 0;
            data_out <= 0;
        end else begin
            if (push && pop) begin 
                data[head] <= data_in;
                head <= head + 1;
                elements <= elements;
                if (head == (N_SIZE - 1)) begin
                    head <= 0;
                end
                if (empty) begin
                    data_out <= data_in;
                end
                else begin
                    data_out <= data[(head - elements) & ((1 << $clog2(N_SIZE)) - 1)];
                end
            end
            else begin 
                if (push && !full) begin
                    data[head] <= data_in;
                    head <= head + 1;
                    elements <= elements + 1;
                    if (head == (N_SIZE - 1)) begin
                        head <= 0;
                    end
                end else if (pop && !empty) begin
                    elements <= elements - 1;
                    data_out <= data[(head - elements) & ((1 << $clog2(N_SIZE)) - 1)];
                end
            end
        end
    end
    // assign ind = (head-elements-1);
    // assign data_out = data[(ind > (N_SIZE-1)) ? (ind - N_SIZE) : ind];
    assign empty = (elements == 0);
    assign full = (elements == N_SIZE);
endmodule