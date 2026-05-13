
module register_set(input CLK, input [2:0]A1, input [2:0]A2, input [2:0]A3, input [15:0] word, input WE, input rst ,output [15:0] O1, output [15:0] O2);

	reg [15:0]memory[0:7];
	integer i;
	
	assign O1 = memory[A1];
	assign O2 = memory[A2];

    wire [15:0]R0,R1,R2,R3,R4,R5,R6,R7;
    assign R0 = memory[0];
    assign R1 = memory[1];
    assign R2 = memory[2];
    assign R3 = memory[3];
    assign R4 = memory[4];
    assign R5 = memory[5];
    assign R6 = memory[6];
    assign R7 = memory[7];

	wire [7:0]X = R1[7:0];
	wire [7:0]Y = R1[15:8];
	wire DX = R2[0];
	wire DY = R2[8];
	wire [6:0]L = R2[7:1];
	wire [6:0]R = R2[15:9];


	always @(posedge CLK) begin
		if (rst) begin
			if (WE) begin
                memory[A3] <= word;
			end
		end
		else begin
			for (i =0;i<8;i=i+1) begin
				memory[i] <= 0;
			end
		end
	end

endmodule

module NZPer(input CLK, input[15:0] word, input trigger, input rst,output wire N, output wire Z, output wire P);
	reg n;
	reg z;
	reg p;
	assign N = n;
	assign Z = z;
	assign P = p;
	wire zer;
	zero_checker Zer(word,zer);
	always @(posedge CLK) begin
		if (rst) begin
			if (trigger) begin
				n <= word[15];
				z <= ~zer;
				p <= (~word[15]) && zer;
			end
		end
		else begin
			n <= 0;
			z <= 1;
			p <= 0;
		end
	end
endmodule

module zero_checker(input[15:0] word,output wire out);
	assign out = word[0] || word[1] || word[2] || word[3] || word[4] || word[5] || word[6] || word[7] || word[8]
	|| word[9] || word[10] || word[11] || word[12] || word[13] || word[14] || word[15];

endmodule