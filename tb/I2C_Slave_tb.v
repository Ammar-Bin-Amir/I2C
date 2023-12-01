`timescale 1ns/1ns

module i2c_slave_tb;
    
    reg clk;
    reg rst;
    // Serial Clock
    reg scl;
    // Serial Data
    reg sda_out;
    wire sda_in;

    i2c_slave uut (
        .clk (clk),
        .rst (rst),
        .scl (scl),
        .sda_out (sda_out),
        .sda_in (sda_in)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        #10 rst = 1;
        #50 rst = 0;
        #3000 $finish;
    end
    
    initial begin
        $dumpfile("./temp/I2C_Slave_tb.vcd");
        $dumpvars(0,i2c_slave_tb);
    end

endmodule