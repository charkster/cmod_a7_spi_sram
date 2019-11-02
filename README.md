# cmod_a7_spi_sram
SPI slave to External SRAM interface for Cmod A7

This Systemverilog design is intended for a Digilent Cmod A7 FPGA board.
A SPI slave instance is created, which then connects to an interface to drive reads and writes to the 512KB external SRAM
on the Cmod A7 board. This allows a SPI master (Raspberry Pi) to load the SRAM with values and read them back.
The FPGA will then have access to 512KB of data loaded from the SPI master. 

My next project is a waveform generator that uses the data stored in the external SRAM to drive 1, 2, 4 or 8 GPIO pins with data stored in the SRAM. This is identical to how ATE (Automated Test Equipment) is able to drive and capture function patterns when screening new silicon. As patterns are driven out, captured data from another 1, 2, 4 or 8 pins can be stored into the SRAM (proof that the functional pattern is working).

The project after the SRAM waveform generator is to use a micro SD card as waveform storage (no SRAM, but use a SPI interface to a 1TB micro SD card).

Now back to the SPI to external SRAM interface...

spi_regmap_top.sv is the top-level design which has the instances of the SPI slave, sram interface and optional register map.

spi_slave_lbus.sv is the SPI slave with a "LBUS" interface. LBUS is just a name for a parallel bus with separate address and data and a read strobe and write strobe.

lbus_ext_sram.sv is the LBUS interface to the external SRAM. The SRAM interface is parallel address and data, with read and write data being multiplexed on the same 8bit bus.

lbus_regmap.sv is a register memory map that has a LBUS interface. It is not necessary to accessing the SRAM, but is included as control data should be stored here. Configuration of the future waveform generator will reside here. It is included as an example of how multiple LBUS interaces connect to the single SPI slave.

tb_spi_slave_top.sv is a testbench which shows how SPI bus cycles are translated into SRAM and register map reads and writes. It does not have a SRAM memory model included.

CmodA7_Master.xdc is the pin constraint file which maps spi_regmap_top ports to FPGA pins.

project_4.xpr is the Vivado project file. It can't be used directly, but may contain some implementation details.

spi_slave_memory_ext_sram.py is the python class used to do SPI reads and writes to the Cmod A7 board. Written for the Raspberry Pi.

OTHER NOTES: 
(1) The oscillator on the Cmod A7 board is 12MHz
(2) One board button is used as an asynchronous reset
(3) I am able to configure my Raspberry Pi for a 2MHz SPI clock and load the SRAM in about 10 seconds

Here is the link to the Cmod A7 board.
https://store.digilentinc.com/cmod-a7-breadboardable-artix-7-fpga-module/
