
module tb_spi_slave_lbus ();

   parameter EXT_CLK_PERIOD_NS = 83;
   parameter SCLK_PERIOD_NS = 10000;

   wire [18:0] sram_addr;
   wire [7:0]  sram_data;
   wire        sram_cen;
   wire        sram_wen;
   wire        sram_oen;
   reg         clk;
   reg         reset;
   reg         sclk;
   reg         ss_n;
   reg         mosi;
   wire        miso;

   initial begin
      clk = 1'b0;
      forever
        #(EXT_CLK_PERIOD_NS/2) clk = ~clk;
   end

   task send_byte (input [7:0] byte_val);
      begin
         $display("Called send_byte task: given byte_val is %h",byte_val);
         sclk  = 1'b0;
         for (int i=7; i >= 0; i=i-1) begin
            $display("Inside send_byte for loop, index is %d",i);
            mosi = byte_val[i];
            #(SCLK_PERIOD_NS/2);
            sclk  = 1'b1;
            #(SCLK_PERIOD_NS/2);
            sclk  = 1'b0;
         end
      end
   endtask

   initial begin
      reset = 1'b1;
      sclk  = 1'b0;
      ss_n  = 1'b1;
      mosi  = 1'b0;
      #SCLK_PERIOD_NS;
      reset = 1'b0;
      #SCLK_PERIOD_NS;    
      $display("Write 3 bytes byte to SRAM address 0x000000");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h04);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h5A);
      send_byte(8'hA5);
      send_byte(8'hF0);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      $display("Write 3 bytes byte to address 0x000002");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h02);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h01);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      $display("Write a single byte to address 0x000001");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h01);
      send_byte(8'h00);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      $display("Write a single byte to address 0x000000");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h01);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      #10ms;
      $display("Write a single byte to address 0x000000");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h00);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      #10us;
      $finish;
   end

   // dump waveforms
   initial begin
      $shm_open("waves.shm");
      $shm_probe("MAS");
   end


   spi_regmap_top u_spi_regmap_top
     ( .clk,
       .reset,
       .sclk,
       .ss_n,
       .mosi,
       .miso,
       .sram_addr,
       .sram_data,
       .sram_oen,
       .sram_wen,
       .sram_cen,
       .gpio_pat_gen_out (),
       .pattern_done     ()
       );

   ram_model u_ram_model
     ( .sram_addr,
       .sram_data,
       .sram_cen,
       .sram_wen,
       .sram_oen
       );

endmodule
