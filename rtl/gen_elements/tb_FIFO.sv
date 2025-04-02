/*******************************************************************************
* File: tb_FIFO.sv
* Author: Soham Gandhi
* Date: 2025-03-14
* Description: Simple test bench to ensure functionality for the simple FIFO module.
* Version: 1.0
*******************************************************************************/

module tb_FIFO ();
    logic clk, rst_n, push, pop, full, empty;
    logic [7:0] data_in, data_out;

    FIFO #(
        .N_BITS(8),
        .N_SIZE(4)
    ) f (
        .clk(clk),
        .rst_n(rst_n),
        .push(push),
        .pop(pop),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        push = 0;
        pop = 0;
        data_in = 0;
        #10;
        rst_n = 1;
        #10;
        push = 1;
        data_in = 8'hFF;
        #10;
        push = 0;
        #10;
        pop = 1;
        #10;
        assert (data_out == 8'hFF) else $error("Data out does not match expected value");

        // Test for empty flag
        pop = 1;
        #10;
        assert (empty == 1) else $error("Empty flag does not match expected value");

        // Test for full flag
        pop = 0;
        push = 1;
        data_in = 8'h1F;
        #10;
        data_in = 8'h2F;
        #10;
        data_in = 8'h3F;
        #10;
        data_in = 8'h4F;
        #10;
        data_in = 8'h5F;
        assert (full == 1) else $error("Full flag does not match expected value");
        #10;

        // Test for wrap around
        pop = 1;
        push = 0;
        #10;
        assert (data_out == 8'h1F) else $error("Data out does not match expected value");
        #10;
        assert (data_out == 8'h2F) else $error("Data out does not match expected value");
        #10;
        assert (data_out == 8'h3F) else $error("Data out does not match expected value");
        #10;
        assert (data_out == 8'h4F) else $error("Data out does not match expected value");
        #30;
        assert (empty == 1) else $error("Empty flag does not match expected value");
        #20;

        // Test for push and pop at the same time
        push = 1;
        pop = 0;
        data_in = 8'h5F;
        #10;
        pop = 1;
        data_in = 8'h6F;
        #10;
        data_in = 8'h7F;
        #10;
        data_in = 8'h8F;
        #10;
        push = 0;
        pop = 0;
        #20;
        pop = 1;
        #50;


        pop = 0;
        push = 0;
        #10;
        pop = 1;
        push = 1;
        data_in = 8'h6F;
        #10;
        data_in = 8'h7F;
        #10;
        data_in = 8'h8F;
        #10;
        data_in = 8'h9F;
        #10;
        pop = 0;
        push = 0;
        #30;
        $stop;
    end
endmodule