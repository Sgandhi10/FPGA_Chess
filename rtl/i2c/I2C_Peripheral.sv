/******************************************************************************
* Filename : I2C_Peripheral.sv
* Author : Soham Gandhi
* Date : 1/17/2025
* Description : This file contains the I2C Peripheral(Slave) module.
* Version : 1.0 (SG) Initial Version
******************************************************************************/

module I2C_Peripheral#(
    parameter ADDR_WIDTH = 7,
    parameter DATA_WIDTH = 32,
    parameter ADDRESS = 8'h50
)(
     // I2C interface
    inout logic scl,      // I2C clock signal
    inout logic sda,      // I2C data signal

    // Device Input Signals
    input logic clk,
    input logic rst_n,

    input logic [DATA_WIDTH-1 : 0] p_data,

    // Device Output Signals
    output logic o_valid,
    output logic [DATA_WIDTH-1 : 0] o_data
)
    // Setup Pull-up resistors
    pullup (scl);
    pullup (sda);

    logic sda_out; // Internal signal to control sda
    logic scl_out; // Internal signal to control scl

    logic sda_en, scl_en;

    // Tri-state buffer for SDA
    assign scl = (scl_en) ? scl_out : 1'bz;
    assign sda = (sda_en) ? sda_out : 1'bz;

    // FSM for I2C
    typedef enum logic [2:0] {
        IDLE,
        START,
        RW,
        ADDR,
        ACK,
        DATA,
        STOP
    } state_t;

    state_t pres_state;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_out <= 1'b1;
            scl_out <= 1'b1;
            sda_en <= 1'b0;
            scl_en <= 1'b0;
        end else begin
            case (pres_state)
                IDLE: begin
                    
                end
                RW: begin
                    
                end
                ADDR: begin
                    
                end
                ACK: begin
                    
                end
                DATA: begin
                    
                end
                STOP: begin
                    
                end
            endcase
        end
    end
    
endmodule