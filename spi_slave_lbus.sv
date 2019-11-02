
// CPOL == 1'b0, CPHA = 1'b0, why would anyone do anything else?

module spi_slave_lbus
  ( input  logic        sclk,          // SPI
    input  logic        mosi,          // SPI
    output logic        miso,          // SPI
    input  logic        reset_spi,     // ASYNC_RESET
    input  logic  [7:0] rdata,         // LBUS
    output logic        rd_en_regmap,  // LBUS regmap
    output logic        wr_en_regmap,  // LBUS regmap
    output logic        rd_en_sram,    // LBUS regmap
    output logic        wr_en_sram,    // LBUS regmap
    output logic  [7:0] wdata,         // LBUS
    output logic [23:0] address        // LBUS
    );

   logic [6:0] mosi_buffer;
   logic [5:0] bit_count;
   logic       read_cycle_regmap;
   logic       write_cycle_regmap;
   logic       read_cycle_sram;
   logic       write_cycle_sram;
   logic       read_cycle;
   logic       write_cycle;
   
   assign read_cycle  = read_cycle_regmap  || read_cycle_sram;
   assign write_cycle = write_cycle_regmap || write_cycle_sram;

   always_ff @(posedge sclk, posedge reset_spi)
     if (reset_spi) mosi_buffer <= 7'd0;
     else           mosi_buffer <= {mosi_buffer[5:0],mosi};

   always_ff @(posedge sclk, posedge reset_spi)
     if (reset_spi)                                bit_count <= 6'd0;
     else if (read_cycle  && (bit_count == 6'd39)) bit_count <= 6'd32;
     else if (write_cycle && (bit_count == 6'd40)) bit_count <= 6'd33;
     else                                          bit_count <= bit_count + 1;

   always_ff @(negedge sclk, posedge reset_spi)
     if (reset_spi)              miso <= 1'b0;
     else if (bit_count < 6'd32) miso <= 1'b0;
     else if (read_cycle)        miso <= rdata[6'd39 - bit_count];
     else                        miso <= 1'b0;

   // regmap   read command is 8'b0000_0010, write command is 8'b0000_0001
   // ext sram read command is 8'b0000_1000, write command is 8'b0000_0100

   always_ff @(posedge sclk, posedge reset_spi)
     if (reset_spi)                                                            read_cycle_regmap <= 1'b0;
     else if ((bit_count == 6'd7) && (mosi_buffer == 7'h01) && (mosi == 1'b0)) read_cycle_regmap <= 1'b1;

    always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                      rd_en_regmap <= 1'b0;
      else if (read_cycle_regmap && (bit_count >= 6'd31)) rd_en_regmap <= 1'b1;
      else                                                rd_en_regmap <= 1'b0;

    always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                                            read_cycle_sram <= 1'b0;
      else if ((bit_count == 6'd7) && (mosi_buffer == 7'h04) && (mosi == 1'b0)) read_cycle_sram <= 1'b1;
      
    always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                    rd_en_sram <= 1'b0;
      else if (read_cycle_sram && (bit_count >= 6'd31)) rd_en_sram <= 1'b1;
      else                                              rd_en_sram <= 1'b0;

   always_ff @(posedge sclk, posedge reset_spi)
     if (reset_spi)                                                            write_cycle_regmap <= 1'b0;
     else if ((bit_count == 6'd7) && (mosi_buffer == 7'h00) && (mosi == 1'b1)) write_cycle_regmap <= 1'b1;

   always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                       wr_en_regmap <= 1'b0;
      else if (write_cycle_regmap && (bit_count == 6'd39)) wr_en_regmap <= 1'b1;
      else                                                 wr_en_regmap <= 1'b0;

   always_ff @(posedge sclk, posedge reset_spi)
     if (reset_spi)                                                            write_cycle_sram <= 1'b0;
     else if ((bit_count == 6'd7) && (mosi_buffer == 7'h02) && (mosi == 1'b0)) write_cycle_sram <= 1'b1;

   always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                      wr_en_sram <= 1'b0;
      else if (write_cycle_sram  && (bit_count == 6'd39)) wr_en_sram <= 1'b1;
      else                                                wr_en_sram <= 1'b0;

    always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                                address[23:0]  <= 24'h000000;
      else if ((read_cycle || write_cycle) && (bit_count == 6'd15)) address[23:16] <= {mosi_buffer[6:0],mosi};
      else if ((read_cycle || write_cycle) && (bit_count == 6'd23)) address[15:8]  <= {mosi_buffer[6:0],mosi};
      else if ((read_cycle || write_cycle) && (bit_count == 6'd31)) address[7:0]   <= {mosi_buffer[6:0],mosi};
      else if ( read_cycle                 && (bit_count == 6'd39)) address[23:0]  <= address[23:0] + 1;
      else if (               write_cycle  && (bit_count == 6'd40)) address[23:0]  <= address[23:0] + 1;

    always_ff @(posedge sclk, posedge reset_spi)
      if (reset_spi)                                wdata <= 8'h00;
      else if (write_cycle && (bit_count == 6'd39)) wdata <= {mosi_buffer[6:0],mosi};

endmodule