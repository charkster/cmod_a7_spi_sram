
module lbus_ext_sram
  ( input  logic        clk,
    input  logic        rst_n,
    input  logic        rd_en_sclk,
    input  logic        wr_en_sclk,
    input  logic [23:0] address_sclk,
    output logic [18:0] sram_addr,
    output logic        sram_oen,
    output logic        sram_wen,
    output logic        sram_cen
    );
    
   logic sync_rd_en_ff1;
   logic sync_rd_en_ff2;
   logic sync_wr_en_ff1;
   logic sync_wr_en_ff2;
   logic hold_sync_wr_en_ff2;
    
    always_ff @(posedge clk, negedge rst_n)
      if (~rst_n)  sync_rd_en_ff1 <= 1'b0;
      else         sync_rd_en_ff1 <= rd_en_sclk;
 
    always_ff @(posedge clk, negedge rst_n)
      if (~rst_n)  sync_rd_en_ff2 <= 1'b0;
      else         sync_rd_en_ff2 <= sync_rd_en_ff1;
 
    always_ff @(posedge clk, negedge rst_n)
      if (~rst_n)  sync_wr_en_ff1 <= 1'b0;
      else         sync_wr_en_ff1 <= wr_en_sclk;
 
    always_ff @(posedge clk, negedge rst_n)
      if (~rst_n)  sync_wr_en_ff2 <= 1'b0;
      else         sync_wr_en_ff2 <= sync_wr_en_ff1;
 
    always_ff @(posedge clk, negedge rst_n)
      if (~rst_n) hold_sync_wr_en_ff2 <= 1'b0;
      else        hold_sync_wr_en_ff2 <= sync_wr_en_ff2;
      
    assign sram_addr = {19{(sync_rd_en_ff2 || sync_wr_en_ff2)}} & address_sclk[18:0];
    assign sram_cen   = !(sync_rd_en_ff2 || sync_wr_en_ff2);
    assign sram_oen   =  !sync_rd_en_ff2;
    assign sram_wen   =  !sync_wr_en_ff2 || hold_sync_wr_en_ff2;
    
endmodule
    