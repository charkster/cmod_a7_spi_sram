module ram_model (sram_addr, sram_data, sram_cen, sram_wen, sram_oen);

parameter ADDRESSSIZE = 19;
parameter WORDSIZE = 8;

input [ADDRESSSIZE-1:0] sram_addr;
inout [WORDSIZE-1:0]    sram_data;
input 	                sram_cen;
input 		        sram_wen;
input                   sram_oen;

reg [WORDSIZE-1:0] mem [0:(1<<ADDRESSSIZE)-1];

assign sram_data = (!sram_cen && !sram_oen) ? mem[sram_addr] : {WORDSIZE{1'bz}};

always @(sram_cen or sram_wen)
  if (!sram_cen && !sram_wen)
    mem[sram_addr] = sram_data;

always @(sram_wen or sram_oen)
  if (!sram_wen && !sram_oen)
    $display("Operational error in ram_model: sram_oen and sram_wen both active");

endmodule
