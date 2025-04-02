`timescale 1ns/1ns

/**************************************************************************************************
*
* I2C Peripheral Test Bench
* ------------------------
* This test bench is used to test the I2C peripheral module
*
**************************************************************************************************/

module tb_I2C_Perhiperal();
    localparam PERIOD = 10;
    
    logic clk;
    logic rst;
    inout sda;
    logic scl;

    I2C_Peripheral i2c_peripheral(
    );

    initial begin
        clk = 0;
        forever begin
            #PERIOD/2 clk = ~clk;
        end
    end

    initial begin
        rst = 1;
        sda = 1;
        scl = 1;

        #10 rst = 0
    end

endmodule
