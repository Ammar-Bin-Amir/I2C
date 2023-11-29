# I<sup>2</sup>C

The I<sup>2</sup>C (Inter-Integrated Circuit) is a widely used synchronous serial communication protocol employed to connect multiple electronic devices on a board or across boards.

## Verilog Implementation

The RTL design of I<sup>2</sup>C has been implemented by using verilog. The architecture is divided into three essential modules: the Master, Slave, and the I<sup>2</sup>C top-level module that acts as the Register Interface (RIF) unit.

## Architecture

The master device governs the communication flow by controlling the SCL line to generate clock pulses, synchronizing the transmission between devices. Additionally, the SDA line serves a dual-purpose: for transmitting data from the master to the slave (while labeled as MOSI in other protocols) and for the opposite direction, carrying data from the slave to the master (analogous to MISO). Alongside these essential communication lines, I<sup>2</sup>C employs a mechanism for addressing devices on the bus. Instead of a dedicated Chip Select (CS) line as in other protocols, I<sup>2</sup>C devices are uniquely addressed by the master during communication, allowing it to select specific slave devices for interaction.

## Transaction Format

In I<sup>2</sup>C transactions, the acknowledgment bit's role is pivotal, confirming successful data transmission between devices. Its issuance, dependent on the transaction's direction (write or read), validates each byte's receipt during the transaction, ensuring accurate and error-free data exchange. Additionally, in read operations, a repeated start occurs post-register address to signify the transition from write to read mode, enabling subsequent data retrieval from the slave device.

- ### 8-Bit Slave Address with Read/Write Bit as LSB

The transaction starts with a 8-bit address of the slave device. The LSB (Least Significant Bit) of this byte determines the operation type: a '0' for a write operation (master sending data to the slave) and a '1' for a read operation (master requesting data from the slave).

- ### 8-Bit Register Address

Following the slave address, an 8-bit register address is sent. This register address specifies the internal register or memory location within the slave device where the data will be written (for write operations) or read from (for read operations).

- ### 32-Bit Data

For write operations, after sending the register address, the master sends a 32-bit data payload to be written into the specified register. For read operations, the master initiates the read request, and the slave responds by sending the 32-bit data in response to the register address.
