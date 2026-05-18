
module top(
	input clk,
	input rst,

	input ILU,
	input ILD,
	input IRU,
	input IRD,
	
	output vga_hs,
	output vga_vs,
	output vga_r,
	output vga_g,
	output vga_b
);
	
	wire [15:0] addr_b;
	wire [15:0] data_b;
	wire [15:0] out_b;
	wire web;
	wire clkb;
	computer machine(clk,rst,clk,addr_b,data_b,web,out_b);
	
	IOProcess IO (clk,rst,clkb,addr_b,data_b,web,out_b,vga_hs,vga_vs,vga_r,vga_g,vga_b,ILU,ILD,IRU,IRD);

endmodule