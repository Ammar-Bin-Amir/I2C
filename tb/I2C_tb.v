`timescale 1ns/1ns

module i2c_tb;
    
    reg clk;
    reg rst;
    reg [2:0] address;
    reg [31:0] write_data;
    reg we;
    reg re;
    wire [31:0] read_data;

    i2c uut (
        .clk (clk),
        .rst (rst),
        .address (address),
        .write_data (write_data),
        .we (we),
        .re (re),
        .read_data (read_data)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        #10 rst = 1;
        #50 rst = 0;
        #100 we = 1'b1; re = 1'b1;
        // // Write Data
        // // Invalid Slave Address, Register Address
        // // #50 ext_slave_address_in = 7'b110_1011; ext_read_write_in = 0; ext_register_address_in = 8'hbf; ext_data_in = 32'h12_34_58_ae;
        // // #30 en = 1;
        // // #20 en = 0;
        // #50 address = 1; write_data = 7'b110_1011;
        // #20 address = 2; write_data = 1'b0;
        // #20 address = 3; write_data = 8'hbf;
        // #20 address = 4; write_data = 32'h12_34_58_ae;
        // #20 address = 0; write_data = 1'b1;
        // #30 address = 0; write_data = 1'b0;
        // // Valid Slave Address, Invalid Register Address
        // // #1000 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 0; ext_register_address_in = 8'hfb; ext_data_in = 32'h34_58_ae_12;
        // // #30 en = 1;
        // // #20 en = 0;
        // #1000 address = 1; write_data = 7'b110_0011;
        // #20 address = 2; write_data = 1'b0;
        // #20 address = 3; write_data = 8'hfb;
        // #20 address = 4; write_data = 32'h34_58_ae_12;
        // #20 address = 0; write_data = 1'b1;
        // #30 address = 0; write_data = 1'b0;
        // Valid Slave Address, Register Address
        // #1500 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 0; ext_register_address_in = 8'h0b; ext_data_in = 32'h58_ae_12_34;
        // #30 en = 1;
        // #20 en = 0;
        #1500 address = 1; write_data = 7'b110_0011;
        #20 address = 2; write_data = 1'b0;
        #20 address = 3; write_data = 8'h0b;
        #20 address = 4; write_data = 32'h58_ae_12_34;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        // // Read Data
        // // // Invalid Slave Address, Register Address 67cd
        // // #3000 ext_slave_address_in = 7'b110_1011; ext_read_write_in = 1; ext_register_address_in = 8'hfb; ext_data_in = 32'hae_12_34_58;
        // // #30 en = 1;
        // // #20 en = 0;
        // #3000 address = 1; write_data = 7'b110_1011;
        // #20 address = 2; write_data = 1'b1;
        // #20 address = 3; write_data = 8'hfb;
        // #20 address = 4; write_data = 32'hae_12_34_58;
        // #20 address = 0; write_data = 1'b1;
        // #30 address = 0; write_data = 1'b0;
        // #1000 address = 5;
        // // Valid Slave Address, Invalid Register Address
        // // #1000 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 1; ext_register_address_in = 8'hbf; ext_data_in = 32'h58_12_34_ae;
        // // #30 en = 1;
        // // #20 en = 0;
        // #50 address = 1; write_data = 7'b110_0011;
        // #20 address = 2; write_data = 1'b1;
        // #20 address = 3; write_data = 8'hbf;
        // #20 address = 4; write_data = 32'h58_12_34_ae;
        // #20 address = 0; write_data = 1'b1;
        // #30 address = 0; write_data = 1'b0;
        // #1500 address = 5;
        // Valid Slave Address, Register Address
        // #1500 ext_slave_address_in = 7'b110_0011; ext_read_write_in = 1; ext_register_address_in = 8'h0f; ext_data_in = 32'h58_34_12_ae;
        // #30 en = 1;
        // #20 en = 0;
        #3500 address = 1; write_data = 7'b110_0011;
        #20 address = 2; write_data = 1'b1;
        #20 address = 3; write_data = 8'h0f;
        #20 address = 4; write_data = 32'h58_34_12_ae;
        #20 address = 0; write_data = 1'b1;
        #30 address = 0; write_data = 1'b0;
        #3000 address = 5;
        #4000 $finish;
    end
    
    initial begin
        $dumpfile("./temp/I2C_tb.vcd");
        $dumpvars(0,i2c_tb);
    end

endmodule