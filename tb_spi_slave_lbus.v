
module tb_spi_slave_lbus ();

   parameter EXT_CLK_PERIOD_NS = 83;
   parameter SCLK_PERIOD_NS = 10000;

   reg clk;
   reg reset;
   reg sclk;
   reg ss_n;
   reg mosi;
   wire miso;

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
      $display("Write a single byte to address 0x0000 and then read it back");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'hE1);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h02);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h00);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      $display("Write a single byte to address 0x0001 and then read it back");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h01);
      send_byte(8'h35);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h02);
      send_byte(8'h00);
      send_byte(8'h01);
      send_byte(8'h00);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      $display("Write 3 bytes byte to address 0x0002 and then read them back");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01);
      send_byte(8'h00);
      send_byte(8'h02);
      send_byte(8'h12);
      send_byte(8'h34);
      send_byte(8'h56);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h02);
      send_byte(8'h00);
      send_byte(8'h02);
      send_byte(8'h00);
      send_byte(8'h00);
      send_byte(8'h00);
      ss_n  = 1'b1;
      #SCLK_PERIOD_NS;
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
       .miso
       );

endmodule
