// may have to mess with clock to match timings
module PM(input CLK, input [15:0]PIN, input rst, output reg [15:0] PI, output reg[15:0] PC);

	reg [15:0]memory[511:0];
	reg [15:0] lock;

	initial begin
		$readmemb("test1of3apr.mem", memory,0,252);
		PI <= memory[0];
		PC <= 0;
	end


	always @(posedge CLK) begin
		if (rst) begin
			lock <= PIN;
		end
	end
	always @(negedge CLK) begin
		if (rst) begin
			PI <= memory[lock];
			PC <= lock;
		end
	end

endmodule