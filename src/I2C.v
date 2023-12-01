module i2c (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [6:0] ext_slave_address_in,
    input wire ext_read_write_in,
    input wire [7:0] ext_register_address_in,
    input wire [31:0] ext_data_in,
    output wire [31:0] ext_data_out
);
    
    wire scl;
    wire sda_out;
    wire sda_in;

    i2c_master uut_master (
        .clk (clk),
        .rst (rst),
        .en (en),
        .scl (scl),
        .ext_slave_address_in (ext_slave_address_in),
        .ext_read_write_in (ext_read_write_in),
        .ext_register_address_in (ext_register_address_in),
        .ext_data_in (ext_data_in),
        .sda_out (sda_out),
        .sda_in (sda_in),
        .ext_data_out (ext_data_out)
    );

    i2c_slave uut_slave (
        .clk (clk),
        .rst (rst),
        .scl (scl),
        .sda_out (sda_out),
        .sda_in (sda_in)
    );

endmodule