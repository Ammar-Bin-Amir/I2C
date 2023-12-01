`timescale 1ns/1ns

module i2c_tb;
    
    reg clk;
    reg rst;
    reg en;
    reg [6:0] ext_slave_address_in;
    reg ext_read_write_in;
    reg [7:0] ext_register_address_in;
    reg [31:0] ext_data_in;
    wire [31:0] ext_data_out;

    i2c uut (
        .clk (clk),
        .rst (rst),
        .en (en),
        .ext_slave_address_in (ext_slave_address_in),
        .ext_read_write_in (ext_read_write_in),
        .ext_register_address_in (ext_register_address_in),
        .ext_data_in (ext_data_in),
        .ext_data_out (ext_data_out)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        #10 rst = 1;
        #50 rst = 0;
        // Write Data
        // Invalid Slave Address, Register Address 67cd
        #50 ext_slave_address_in = 7'b110_1011; ext_read_write_in = 0; ext_register_address_in = 8'hbf; ext_data_in = 32'h12_34_58_ae;
        #30 en = 1;
        #20 en = 0;
        // Valid Slave Address, Invalid Register Address
        #1000 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 0; ext_register_address_in = 8'hfb; ext_data_in = 32'h34_58_ae_12;
        #30 en = 1;
        #20 en = 0;
        // Valid Slave Address, Register Address
        #1500 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 0; ext_register_address_in = 8'h0b; ext_data_in = 32'h58_ae_12_34;
        #30 en = 1;
        #20 en = 0;
        // Read Data
        // Invalid Slave Address, Register Address 67cd
        #3000 ext_slave_address_in = 7'b110_1011; ext_read_write_in = 1; ext_register_address_in = 8'hfb; ext_data_in = 32'hae_12_34_58;
        #30 en = 1;
        #20 en = 0;
        // Valid Slave Address, Invalid Register Address
        #1000 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 1; ext_register_address_in = 8'hbf; ext_data_in = 32'h58_12_34_ae;
        #30 en = 1;
        #20 en = 0;
        // Valid Slave Address, Register Address
        #1500 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 1; ext_register_address_in = 8'h0f; ext_data_in = 32'h58_34_12_ae;
        #30 en = 1;
        #20 en = 0;
        #4000 $finish;
    end
    
    initial begin
        $dumpfile("./temp/I2C_tb.vcd");
        $dumpvars(0,i2c_tb);
    end

endmodule