
module memory(input CLK, input [15:0]M1, input [15:0]M2, input [15:0] word, input WE, input rst,output [15:0] MO1, output [15:0] MO2);

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