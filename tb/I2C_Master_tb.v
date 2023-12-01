`timescale 1ns/1ns

module i2c_master_tb;
    
    reg clk;
    reg rst;
    reg en;
    // Serial Clock
    wire scl;
    // Serial Data
    reg [6:0] ext_slave_address_in;
    reg ext_read_write_in;
    reg [7:0] ext_register_address_in;
    reg [31:0] ext_data_in;
    wire sda_out;
    reg sda_in;
    wire [31:0] ext_data_out;

    i2c_master uut (
        .clk (clk),
        .rst (rst),
        .en (en),
        .scl (scl),
        .ext_slave_address_in (ext_address_in),
        .ext_read_write_in (ext_read_write_in),
        .ext_register_address_in (ext_register_address_in),
        .ext_data_in (ext_data_in),
        .sda_out (sda_out),
        .sda_in (sda_in),
        .ext_data_out (ext_data_out)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        #10 rst = 1;
        #50 rst = 0;
        #3000 $finish;
    end

    initial begin
        $dumpfile("./temp/I2C_Master_tb.vcd");
        $dumpvars(0,i2c_master_tb);
    end

endmodule