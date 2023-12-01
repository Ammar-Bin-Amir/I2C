module i2c_master (
    input wire clk,
    input wire rst,
    input wire en,
    // Serial Clock
    output reg scl,
    // Serial Data
    input wire [6:0] ext_slave_address_in,
    input wire ext_read_write_in,
    input wire [7:0] ext_register_address_in,
    input wire [31:0] ext_data_in,
    output reg sda_out,
    input wire sda_in,
    output wire [31:0] ext_data_out
);

    /* SERIAL CLOCK */
    
    reg clock_count;

    always @(posedge clk) begin
        if (rst) begin
            clock_count <= 0;
        end
        else begin
            if ((current_state == IDLE) || (current_state == STOP)) begin
                clock_count <= 0;
            end
            else if (next_state == REPEATED_START) begin
                clock_count <= 0;
            end
            else begin
                if (clock_count == 1) begin
                    clock_count <= 0;
                end
                else begin
                    clock_count <= clock_count + 1;
                end
            end
        end
    end

    /* BIT COUNTER */

    reg [5:0] bit_count;

    always @(posedge clk) begin
        if (rst) begin
            bit_count <= 0;
        end
        else begin
            if ((current_state == IDLE) || (current_state == START) || (current_state == STOP) || (current_state == REPEATED_START)) begin
                bit_count <= 0;
            end
            else begin
                if (scl == 1'b1) begin
                bit_count <= bit_count + 1;
                end
                else begin
                    bit_count <= bit_count;
                end
            end
        end
    end

    /* SLAVE ADDRESS & READ / WRITE */

    reg [7:0] slave_address_save;
    reg read_write_save;

    always @(posedge clk or rst) begin
        if (rst) begin
            slave_address_save <= 0;
            read_write_save <= 0;
        end
        else begin
            if (current_state == SLAVE_ADDRESS) begin
                if (scl == 1'b1) begin
                    slave_address_save <= {slave_address_save[6:0],1'b0};
                end
                else begin
                    slave_address_save <= slave_address_save;
                end
            end
            else begin
                slave_address_save <= {ext_slave_address_in,ext_read_write_in};
            end
            read_write_save <= ext_read_write_in;
        end
    end

    /* REGISTER ADDRESS */

    reg [7:0] register_address_save;

    always @(posedge clk) begin
        if (rst) begin
            register_address_save <= 0;
        end
        else begin
            if (current_state == REGISTER_ADDRESS) begin
                if (scl == 1'b1) begin
                    register_address_save <= {register_address_save[6:0],1'b0};
                end
                else begin
                    register_address_save <= register_address_save;
                end
            end
            else begin
                register_address_save <= ext_register_address_in;
            end
        end
    end

    /* DATA */

    reg [31:0] data_write, data_read;

    always @(posedge clk) begin
        if (rst) begin
            data_write <= 0;
            data_read <= 0;
        end
        else begin
            if ((current_state == DATA_BYTE_1) || (current_state == DATA_BYTE_2) || (current_state == DATA_BYTE_3) || (current_state == DATA_BYTE_4)) begin
                // Write
                if (read_write_save == 0) begin
                    if (scl == 1'b1) begin
                        data_write <= {data_write[30:0],1'b0};
                    end
                    else begin
                        data_write <= data_write;
                    end
                end
                // Read
                else if (read_write_save == 1) begin
                    if (scl == 1'b0) begin
                        data_read <= {data_read[30:0],sda_in};
                    end
                    else begin
                        data_read <= data_read;
                    end
                end
                else begin
                    data_write <= data_write;
                    data_read <= data_read;
                end
            end
            else begin
                data_write <= ext_data_in;
                data_read <= data_read;
            end
        end
    end

    assign ext_data_out = data_read;

    /* DATA ACKNOWLEDGEMENT */

    reg ack;

    always @(*) begin
        if (rst) begin
            ack = 1;
        end
        else begin
            if ((bit_count == 26) || (bit_count == 35) || (bit_count == 44) || (bit_count == 53)) begin
                ack = 0;
            end
            else begin
                ack = 1;
            end
        end
    end
    
    /* FINITE STATE MACHINE */

    localparam IDLE = 4'h0;
    localparam START = 4'h1;
    localparam SLAVE_ADDRESS = 4'h2;
    localparam SLAVE_ADDRESS_ACKNOWLEDGE = 4'h3;
    localparam REGISTER_ADDRESS = 4'h4;
    localparam REGISTER_ADDRESS_ACKNOWLEDGE = 4'h5;
    localparam DATA_BYTE_1 = 4'h6;
    localparam DATA_BYTE_1_ACKNOWLEDGE = 4'h7;
    localparam DATA_BYTE_2 = 4'h8;
    localparam DATA_BYTE_2_ACKNOWLEDGE = 4'h9;
    localparam DATA_BYTE_3 = 4'ha;
    localparam DATA_BYTE_3_ACKNOWLEDGE = 4'hb;
    localparam DATA_BYTE_4 = 4'hc;
    localparam DATA_BYTE_4_ACKNOWLEDGE = 4'hd;
    localparam STOP = 4'he;
    localparam REPEATED_START = 4'hf;

    reg [3:0] current_state, next_state;
    reg repeated_start_indication;
    reg delayed_repeated_start_indication;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= 0;
            delayed_repeated_start_indication <= 0;
        end
        else begin
            current_state <= next_state;
            delayed_repeated_start_indication <= repeated_start_indication;
        end
    end

    always @(*) begin
        if (rst) begin
            next_state = 0;
            repeated_start_indication = 0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    scl = 1;
                    sda_out = 1;
                    if (en == 1'b1) begin
                        next_state = START;
                    end
                end
                START: begin
                    scl = ~clock_count;
                    sda_out = 0;
                    repeated_start_indication = 0;
                    next_state = SLAVE_ADDRESS;
                end
                SLAVE_ADDRESS: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = slave_address_save[7];
                    end
                    // Read
                    if (read_write_save == 1) begin
                        // Start
                        if (repeated_start_indication == 1'b0) begin
                            if (bit_count == 7) begin
                                sda_out = 0;
                            end
                            else begin
                                sda_out = slave_address_save[7];
                            end
                        end
                        // Repeated Start
                        if (repeated_start_indication == 1'b1) begin
                            sda_out = slave_address_save[7];
                        end 
                    end
                    // Next State
                    if ((bit_count == 7) && (scl == 1'b1)) begin
                        next_state = SLAVE_ADDRESS_ACKNOWLEDGE;
                    end
                end
                SLAVE_ADDRESS_ACKNOWLEDGE: begin
                    scl = ~clock_count;
                    sda_out = 1;
                    // ACK
                    if ((bit_count == 8) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                        next_state = REGISTER_ADDRESS;
                    end
                    // NACK
                    if ((bit_count == 8) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                        next_state = STOP;
                    end
                end
                REGISTER_ADDRESS: begin
                    scl = ~clock_count;
                    sda_out = register_address_save[7];
                    if ((bit_count == 16) && (scl == 1'b1)) begin
                        next_state = REGISTER_ADDRESS_ACKNOWLEDGE;
                    end
                end
                REGISTER_ADDRESS_ACKNOWLEDGE: begin
                    scl = ~clock_count;
                    sda_out = 1;
                    // Write
                    if (read_write_save == 0) begin
                        // ACK
                        if ((bit_count == 17) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                            next_state = DATA_BYTE_1;
                        end
                        // NACK
                        if ((bit_count == 17) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                    // Read
                    if (read_write_save == 1) begin
                        // Start
                        if (repeated_start_indication == 1'b0) begin
                            // ACK
                            if ((bit_count == 17) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                                next_state = REPEATED_START;
                            end
                            // NACK
                            if ((bit_count == 17) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                                next_state = STOP;
                            end
                        end
                        // Repeated Start
                        if (repeated_start_indication == 1'b1) begin
                            // ACK
                            if ((bit_count == 17) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                                next_state = DATA_BYTE_1;
                            end
                            // NACK
                            if ((bit_count == 17) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                                next_state = STOP;
                            end
                        end
                    end
                    
                end
                DATA_BYTE_1: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = data_write[31];
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = 1;
                    end
                    // Next State
                    if ((bit_count == 25) && (scl == 1'b1)) begin
                        next_state = DATA_BYTE_1_ACKNOWLEDGE;
                    end
                end
                DATA_BYTE_1_ACKNOWLEDGE: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = 1;
                        // ACK
                        if ((bit_count == 26) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                            next_state = DATA_BYTE_2;
                        end
                        // NACK
                        if ((bit_count == 26) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = ack;
                        // ACK
                        if ((bit_count == 26) && (scl == 1'b1) && (sda_out == 1'b0)) begin
                            next_state = DATA_BYTE_2;
                        end
                        // NACK
                        if ((bit_count == 26) && (scl == 1'b1) && (sda_out == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                end
                DATA_BYTE_2: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = data_write[23];
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = 1;
                    end
                    // Next State
                    if ((bit_count == 34) && (scl == 1'b1)) begin
                        next_state = DATA_BYTE_2_ACKNOWLEDGE;
                    end
                end
                DATA_BYTE_2_ACKNOWLEDGE: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = 1;
                        // ACK
                        if ((bit_count == 35) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                            next_state = DATA_BYTE_3;
                        end
                        // NACK
                        if ((bit_count == 35) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = ack;
                        // ACK
                        if ((bit_count == 35) && (scl == 1'b1) && (sda_out == 1'b0)) begin
                            next_state = DATA_BYTE_3;
                        end
                        // NACK
                        if ((bit_count == 35) && (scl == 1'b1) && (sda_out == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                end
                DATA_BYTE_3: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = data_write[15];
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = 1;
                    end
                    // Next State
                    if ((bit_count == 43) && (scl == 1'b1)) begin
                        next_state = DATA_BYTE_3_ACKNOWLEDGE;
                    end
                end
                DATA_BYTE_3_ACKNOWLEDGE: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = 1;
                        // ACK
                        if ((bit_count == 44) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                            next_state = DATA_BYTE_4;
                        end
                        // NACK
                        if ((bit_count == 44) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = ack;
                        // ACK
                        if ((bit_count == 44) && (scl == 1'b1) && (sda_out == 1'b0)) begin
                            next_state = DATA_BYTE_4;
                        end
                        // NACK
                        if ((bit_count == 44) && (scl == 1'b1) && (sda_out == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                end
                DATA_BYTE_4: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = data_write[7];
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = 1;
                    end
                    // Next State
                    if ((bit_count == 52) && (scl == 1'b1)) begin
                        next_state = DATA_BYTE_4_ACKNOWLEDGE;
                    end
                end
                DATA_BYTE_4_ACKNOWLEDGE: begin
                    scl = ~clock_count;
                    // Write
                    if (read_write_save == 0) begin
                        sda_out = 1;
                        // ACK
                        if ((bit_count == 53) && (scl == 1'b1) && (sda_in == 1'b0)) begin
                            next_state = STOP;
                        end
                        // NACK
                        if ((bit_count == 53) && (scl == 1'b1) && (sda_in == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                    // Read
                    if (read_write_save == 1) begin
                        sda_out = ~ack;
                        // ACK
                        if ((bit_count == 53) && (scl == 1'b1) && (sda_out == 1'b0)) begin
                            next_state = STOP;
                        end
                        // NACK
                        if ((bit_count == 53) && (scl == 1'b1) && (sda_out == 1'b1)) begin
                            next_state = STOP;
                        end
                    end
                end
                STOP: begin
                    scl = 1;
                    sda_out = 0;
                    next_state = IDLE;
                end
                REPEATED_START: begin
                    scl = 1;
                    sda_out = 0;
                    repeated_start_indication = 1;
                    next_state = SLAVE_ADDRESS;
                end
                default: next_state = IDLE;
            endcase
        end
    end
    
endmodule