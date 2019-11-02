
module spi_regmap_top
  ( input  logic        clk,       // 12MHz clock
    input  logic        reset,     // button
    input  logic        sclk,      // SPI CLK
    input  logic        ss_n,      // SPI CS_N
    input  logic        mosi,      // SPI MOSI
    output logic        miso,      // SPI MISO
    output logic [18:0] sram_addr, // ext sram address
    inout  logic  [7:0] sram_data, // ext sram data (bidir)
    output logic        sram_oen,  // ext sram output enable (active low)
    output logic        sram_wen,  // ext sram write enable  (active low)
    output logic        sram_cen   // ext sram chip enable   (active low)
    );

   logic  [7:0] rdata;
   logic  [7:0] rdata_regmap;
   logic  [7:0] wdata;
   logic [23:0] address;
   logic        rd_en_regmap;
   logic        wr_en_regmap;
   logic        rd_en_sram;
   logic        wr_en_sram;
   logic        rst_n;
   logic        reset_spi;

   assign rst_n = ~reset;

   assign reset_spi = reset || ss_n; // clear the SPI when the chip_select is inactive
   
   assign rdata     = (rd_en_sram) ? sram_data : rdata_regmap;
   assign sram_data = (sram_oen)   ? wdata     : 'z; 

   spi_slave_lbus u_spi_slave_lbus
     ( .sclk,         // input
       .mosi,         // input
       .miso,         // output
       .reset_spi,    // input
       .rdata,        // input [7:0]
       .rd_en_regmap, // output
       .wr_en_regmap, // output
       .rd_en_sram,   // output
       .wr_en_sram,   // output
       .wdata,        // output [7:0]
       .address       // output [23:0]
       );

   lbus_regmap u_lbus_regmap
     ( .clk,                         // input
       .rst_n,                       // input
       .rd_en_sclk   (rd_en_regmap), // input
       .wr_en_sclk   (wr_en_regmap), // input
       .address_sclk (address),      // input [23:0]
       .wdata_sclk   (wdata),        // input  [7:0]
       .rdata        (rdata_regmap)  // output [7:0]
       );
       
    lbus_ext_sram u_lbus_ext_sram
      ( .clk,                       // input
        .rst_n,                     // input
        .rd_en_sclk   (rd_en_sram), // input
        .wr_en_sclk   (wr_en_sram), // input
        .address_sclk (address),    // input [23:0]
        .sram_addr,                 // output [18:0]
        .sram_oen,                  // output
        .sram_wen,                  // output
        .sram_cen                   // output
       );

endmodule