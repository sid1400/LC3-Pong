
// to keep this a mutlicycle/singlecyclisk comp, while trying to keep timing working, we have to drop ldi and sti
// also have to drop memory load from register written adresses
module memory(
	input clka,
	input [15:0] addr_a,
	input [15:0] data_a,
	input wea,
	output reg [15:0] out_a,
	output [15:0] dup_a,
	input clkb,
	input [15:0] addr_b,
	input [15:0] data_b,
	input web,
	output reg [15:0] out_b
);
	assign dup_a = out_a;
	reg [15:0]memory[0:511];
	
	initial begin
		memory[0] = 16'b0000000000000101;
	end
	
	always @(posedge clka) begin
		out_a <= memory[addr_a[8:0]];
		if (wea) begin
			memory[addr_a[8:0]] <= data_a;
		end
	end

	always @(posedge clkb) begin
		out_b <= memory[addr_b[8:0]];
		if (web) begin
			memory[addr_b[8:0]] <= data_b;
		end
	end
	
endmodule

/* old module
module memory(input CLK,
	input [15:0]M1,
	input [15:0]M2, 
	input [15:0] word, 
	input WE, 
	input rst,
	output [15:0] MO1, 
	output [15:0] MO2);

	reg [15:0]memory[511:0];
	assign MO1 = memory[M1];
	assign MO2 = memory[M2];
	wire [15:0] MOOOO;
	wire [15:0] MOOONE;
	wire [15:0] MOOSS;
	wire [15:0] MOOSN;
	wire [15:0] MOOOT;
	assign MOOOO = memory[0];
	assign MOOOT = memory[2];
	assign MOOONE = memory[1];
	assign MOOSS = memory[67];
	assign MOOSN = memory[69];
	always @(posedge CLK) begin
		if (rst) begin
			if (WE) begin
                memory[M1] <= word;
			end
		end
		else begin
			memory[0] <= 16'b0000000000000101;
		end
	end

endmodule
*/