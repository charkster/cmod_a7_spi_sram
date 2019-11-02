#!/usr/bin/python

import spidev
import time

class spi_slave_memory :
	spi = None
	
	_MAX_ADDRESS          = 0xFFFFF
	_REGMAP_READ_COMMAND  = 0x02
	_REGMAP_WRITE_COMMAND = 0x01
	_SRAM_READ_COMMAND    = 0x08
	_SRAM_WRITE_COMMAND   = 0x04

	# Constructor
	def __init__(self, spi_device=0, spi_channel=0, max_speed_hz = 2000000, mode = 0b00, debug=False): # 2MHz
		self.spi = spidev.SpiDev(spi_device, spi_channel)
		self.spi.max_speed_hz = max_speed_hz
		self.spi.mode = mode # CPOL,CPHA
		self.debug = debug
		
	def read_bytes(self, start_address=0x000000, num_bytes=1, dest="regmap"):
		if (self.debug == True):
			print "Called read_bytes"
		if (num_bytes == 0):
			print "Error: num_bytes must be larger than zero"
			return []
		else:
			if (dest == "regmap"):
				byte0 = self._REGMAP_READ_COMMAND
			elif (dest == "sram"):
				byte0 = self._SRAM_READ_COMMAND
			else:
				print "ERROR: must specify dest as either regmap or sram"
				return 0
			byte1 = (start_address & 0xFF0000) >> 16
			byte2 = (start_address & 0x00FF00) >> 8
			byte3 = (start_address & 0x0000FF)
			filler_bytes = [0x00] * int(num_bytes)
			read_list = self.spi.xfer2([byte0,byte1,byte2,byte3] + filler_bytes)
			read_list[0:4] = []
			if (self.debug == True):
				address = start_address
				for read_byte in read_list:
					print "Address 0x%06x Read data 0x%02x" % (address,read_byte)
					address += 1
			return read_list
	
	def write_bytes(self, start_address=0x000000, write_byte_list=[], dest="regmap"):
		if (dest == "regmap"):
			byte0 = self._REGMAP_WRITE_COMMAND
		elif (dest == "sram"):
			byte0 = self._SRAM_WRITE_COMMAND
		else:
			print "ERROR: must specify dest as either regmap or sram"
			return 0
		byte1 = (start_address & 0xFF0000) >> 16
		byte2 = (start_address & 0x00FF00) >> 8
		byte3 = (start_address & 0x0000FF)
		self.spi.xfer2([byte0,byte1,byte2,byte3] + write_byte_list)
		if (self.debug == True):
			print "Called write_bytes"
			address = start_address
			for write_byte in write_byte_list:
				print "Wrote address 0x%06x data 0x%02x" % (address,write_byte)
				address += 1
		return 1


#mem = spi_slave_memory(debug=True)
#print "Write single address in regmap"
#mem.write_bytes(start_address=0x000003,write_byte_list=[0xe1],dest="regmap")
#print "Read single address in regmap"
#mem.read_bytes(start_address=0x000003,num_bytes=1,dest="regmap")
#print "Write multiple addresses in regmap"
#mem.write_bytes(start_address=0x000001,write_byte_list=[0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef],dest="regmap")
#print "Read multiple addresses in regmap"
#mem.read_bytes(start_address=0x000000,num_bytes=16,dest="regmap")
#print ""
#print "Write single address in ext SRAM"
#mem.write_bytes(start_address=0x000003,write_byte_list=[0xe1],dest="sram")
#print "Read single address in ext SRAM"
#mem.read_bytes(start_address=0x000003,num_bytes=1,dest="sram")
#print "Write multiple addresses in ext SRAM"
#mem.write_bytes(start_address=0x000001,write_byte_list=[0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef],dest="sram")
#print "Read multiple addresses in ext SRAM"
#mem.read_bytes(start_address=0x000000,num_bytes=16,dest="sram")
#print "Fill all of ext sram"
#for block in range(0x00,0x100):
#	start_address = block << 11
#	byte_list = [block] * 2048
#	mem.write_bytes(start_address=block<<11,write_byte_list=[block] * 2048,dest="sram")
