module IOProcess(
	input clk,
	input rst,

	output wire clkb,
	output reg [15:0] addrb,
	output reg [15:0] datab,
	output reg web,
	input  [15:0] value,
	
	output wire vga_hs,
	output wire vga_vs,
	output wire vga_r,
	output wire vga_g,
	output wire vga_b,
	
	input wire ILU,
	input wire ILD,
	input wire IRU,
	input wire IRD
	);
	
	wire LU,LD,RU,RD;
	wire [15:0] dir = {12'd0,LU,LD,RU,RD};
	reg [15:0] ball;// = 16'b0100000001000000;
	reg [15:0] bar;// = 16'b0100000011100000;
	Pong_VGA Display(clk,rst,ball,bar,vga_hs,vga_vs,vga_r,vga_g,vga_b);
	inputbuffer Buff(clk,ILU,ILD,IRU,IRD,LU,LD,RU,RD);
	
	
	reg [3:0]mode = 4'b0000;
	
	assign clkb = clk;
	always @(posedge clk) begin
		if (mode == 9) mode <=0;
		else mode <= mode +1;
		if (mode == 0) begin
			addrb <= 0;
			web <= 1;
			datab <= dir;
		end
		if (mode == 1) begin
			web <= 0;
		end
		if (mode == 3) begin
			addrb <= 1;
			web <= 0;
		end
		if (mode == 6) begin
			addrb <= 2;
			web <= 0;
			ball <= value;
		end
		if (mode == 9) begin
			bar <= value;
		end
	end

endmodule