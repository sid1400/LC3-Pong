// may have to mess with clock to match timings
//if FSM = 0, send data     if FSM = 1,send lock value   if FSM = 2, ignore
module PM(input CLK, input [15:0]PIN,input [1:0]FSM, input rst, output reg [15:0] PI, output reg[15:0] PC);

	reg [15:0]memory[511:0];
	reg [15:0] lock;

	initial begin
		//$readmemb("output.hex", memory,0,252);
		$readmemb("deloutput.hex", memory,0,265);
		PI <= memory[0];
		PC <= 0;
	end


	always @(posedge CLK) begin
		if (rst) begin
			if (FSM == 1) lock <= PIN;
			if (FSM == 0) begin
				PI <= memory[lock];
				PC <= lock;
			end
		end
	end
	/*
	always @(negedge CLK) begin
		if (rst) begin
			PI <= memory[lock];
			PC <= lock;
		end
	end
	*/

endmodule