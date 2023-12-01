# Verilog Files

SRC_MASTER = $(shell pwd)/src/I2C_Master.v
TB_MASTER = $(shell pwd)/tb/I2C_Master_tb.v
VVP_MASTER = $(shell pwd)/temp/I2C_Master_tb.vvp
VCD_MASTER = $(shell pwd)/temp/I2C_Master_tb.vcd

SRC_SLAVE = $(shell pwd)/src/I2C_Slave.v
TB_SLAVE = $(shell pwd)/tb/I2C_Slave_tb.v
VVP_SLAVE = $(shell pwd)/temp/I2C_Slave_tb.vvp
VCD_SLAVE = $(shell pwd)/temp/I2C_Slave_tb.vcd

SRC_I2C = $(shell pwd)/src/I2C.v
TB_I2C = $(shell pwd)/tb/I2C_tb.v
VVP_I2C = $(shell pwd)/temp/I2C_tb.vvp
VCD_I2C = $(shell pwd)/temp/I2C_tb.vcd

# Compilation Settings

COMPILER = iverilog
COMPILER_FLAG = -o

# Simulation Settings

SIMULATION_FLAG = vvp

# Target: MAIN

all: i2c

everything: i2c master slave

clean: 
	rm -rf temp

# Target: Master Adaptor

master: compile_master
	$(SIMULATION_FLAG) $(VVP_MASTER)

compile_master: 
	mkdir -p temp
	$(COMPILER) $(COMPILER_FLAG) $(VVP_MASTER) $(TB_MASTER) $(SRC_MASTER)

clean_master: 
	rm -rf $(VCD_MASTER)
	rm -rf $(VVP_MASTER)

# Target: Slave Adaptor

slave: compile_slave
	$(SIMULATION_FLAG) $(VVP_SLAVE)

compile_slave: 
	mkdir -p temp
	$(COMPILER) $(COMPILER_FLAG) $(VVP_SLAVE) $(TB_SLAVE) $(SRC_SLAVE)

clean_slave: 
	rm -rf $(VCD_SLAVE)
	rm -rf $(VVP_SLAVE)

# Target: I2C

i2c: compile_i2c
	$(SIMULATION_FLAG) $(VVP_I2C)

compile_i2c: 
	mkdir -p temp
	$(COMPILER) $(COMPILER_FLAG) $(VVP_I2C) $(TB_I2C) $(SRC_I2C) $(SRC_MASTER) $(SRC_SLAVE)

clean_i2c: 
	rm -rf $(VCD_I2C)
	rm -rf $(VVP_I2C)

