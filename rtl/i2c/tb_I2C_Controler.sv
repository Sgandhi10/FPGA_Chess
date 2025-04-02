/******************************************************************************
* Filename : tb_I2C_Controller.sv
* Author : Soham Gandhi
* Date : 2/23/2025
* Version : 1.0 (SG) Initial Version
* Description : This file contains the test bench for I2C Controller(Master) module.
*               Implementation based off https://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/
******************************************************************************/

`timescale 1ns/1ns

module tb_I2C_Controller();
    localparam PERIOD = 10;

    // i2c signals
    wire sda;
    wire scl;
    reg sda_drive;
    reg scl_drive;
    assign sda = (sda_drive) ? 1'b0 : 1'bz;  // Tri-state logic
    assign scl = (scl_drive) ? 1'b0 : 1'bz;  // Tri-state logic
    
    // System Signals
    logic clk, rst_n;

    // Device Signals
    logic [6:0] p_addr;
    logic [31:0] p_data;
    logic p_rw;
    logic i_valid;

    // Device Output Signals
    logic o_valid;
    logic [31:0] o_data;

    // Data Struct
    typedef struct {
        logic [6:0] addr;
        logic [31:0] data;
        logic rw;
    } i2c_data_t;

    // Input Stimulus Data
    i2c_data_t i2c_data[3] = '{
        '{7'h50, 32'h12345678, 1'b0}, 
        '{7'h00, 32'h87654321, 1'b0},
        '{7'h00, 32'h00000000, 1'b0}
    };

    // Instantiate I2C Controller
    I2C_Controller #(
        .ADDR_WIDTH(7),
        .DATA_WIDTH(32)
    ) i2c_controller(
        // i2c controller inputs
        .scl(scl),                            // i2c clock signal
        .sda(sda),                            // i2c data signal
        
        // Device Input Signals
        .clk(clk),                            // System clock signal
        .rst_n(rst_n),                        // System asynchronous negative edge reset signal

        .p_addr(p_addr),                      // Peripheral Address
        .p_data(p_data),                      // Peripheral Data

        .p_rw(p_rw),                          // Peripheral Read/Write
        .i_valid(i_valid),                    // Input Valid

        // Device Output Signals
        .o_valid(o_valid),                    // Output Valid
        .o_data(o_data)                       // Output Data (Read Data)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever begin
            #(PERIOD/2) clk = ~clk;
        end
    end

    // Test Plan
    // To appropriately test the module we need to follow the I2C protocol and send the required signals
    // The following test plan is based off https://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/

    // Test Case 1: Send Address and Data

    // Stimulus Generations
    initial begin
        rst_n = 0;
        sda_drive = 0;
        scl_drive = 0;
        i_valid = 0;
        p_addr = 0;
        p_data = 0;
        p_rw = 0;
        #PERIOD;
        rst_n = 1;
        #PERIOD;
        for (int i = 0; i < $size(i2c_data); i++) begin
            p_addr = i2c_data[i].addr; // Slave Address
            p_data = i2c_data[i].data; // Data to be sent
            p_rw = i2c_data[i].rw; // Write
            i_valid = 1; // Input Valid
            #PERIOD;
        end
        i_valid = 0; // Input Valid
        while (1) begin
            wait(i2c_controller.pres_state == i2c_controller.ACK); // Wait for ACK state
            // #(PERIOD);
            sda_drive = 1; // Release SDA
            #PERIOD;
            sda_drive = 0;
            #PERIOD;
        end
    end
    

    // Monitor
    initial begin

    end
endmodule