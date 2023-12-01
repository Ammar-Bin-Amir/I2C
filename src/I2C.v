module i2c (
    input wire clk,
    input wire rst,
    input wire [2:0] address,
    input wire [31:0] write_data,
    input wire we,
    input wire re,
    output reg [31:0] read_data
);
    
    // Register Interface

    localparam ENABLE = 3'b000;
    localparam SLAVE_ADDRESS = 3'b001;
    localparam READ_WRITE = 3'b010;
    localparam REGISTER_ADDRESS = 3'b011;
    localparam DATA_IN = 3'b100;
    localparam DATA_OUT = 3'b101;

    reg enable;
    reg [6:0] slave_address;
    reg read_write;
    reg [7:0] register_address;
    reg [31:0] data_in;
    wire [31:0] data_out;

    always @(*) begin
        if (rst) begin
            enable <= 0;
            slave_address <= 0;
            read_write <= 0;
            register_address <= 0;
            data_in <= 0;
        end
        else begin
            case (address)
                ENABLE: begin
                    if (we == 1'b1) begin
                        enable = write_data[0];
                    end
                    else begin
                        enable = enable;
                    end
                end
                SLAVE_ADDRESS: begin
                    if (we == 1'b1) begin
                        slave_address = write_data[6:0];
                    end
                    else begin
                        slave_address = slave_address;
                    end
                end
                READ_WRITE: begin
                    if (we == 1'b1) begin
                        read_write = write_data[0];
                    end
                    else begin
                        read_write = read_write;
                    end
                end
                REGISTER_ADDRESS: begin
                    if (we == 1'b1) begin
                        register_address = write_data[7:0];
                    end
                    else begin
                        register_address = register_address;
                    end
                end
                DATA_IN: begin
                    if (we == 1'b1) begin
                        data_in = write_data;
                    end
                    else begin
                        data_in = data_in;
                    end
                end
                DATA_OUT: begin
                    if (re == 1'b1) begin
                        read_data = data_out;
                    end
                end
                // default: 
            endcase
        end
    end

    // Master-Slave Interface
    
    wire scl;
    wire sda_out;
    wire sda_in;

    i2c_master uut_master (
        .clk (clk),
        .rst (rst),
        .en (enable),
        .scl (scl),
        .ext_slave_address_in (slave_address),
        .ext_read_write_in (read_write),
        .ext_register_address_in (register_address),
        .ext_data_in (data_in),
        .sda_out (sda_out),
        .sda_in (sda_in),
        .ext_data_out (data_out)
    );

    i2c_slave uut_slave (
        .clk (clk),
        .rst (rst),
        .scl (scl),
        .sda_out (sda_out),
        .sda_in (sda_in)
    );

endmodule