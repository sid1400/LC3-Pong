module inputbuffer #(parameter dist = 30) (
	input clk,
	input wire ILU,
	input wire ILD,
	input wire IRU,
	input wire IRD,
	output reg LU,
	output reg LD,
	output reg RU,
	output reg RD
);
	localparam w = $clog2(dist);
	reg[w-1:0] S1 = {w{1'b0}};
	reg[w-1:0] S2 = {w{1'b0}};
	reg[w-1:0] S3 = {w{1'b0}};
	reg[w-1:0] S4 = {w{1'b0}};
	
	reg A1,A2,A3,A4,B1,B2,B3,B4;
	
	always @(posedge clk) begin
		A1 <= ILU;
		A2 <= ILD;
		A3 <= IRU;
		A4 <= IRD;
		B1 <= A1;
		B2 <= A2;
		B3 <= A3;
		B4 <= A4;
		if (B1) begin
			S1 <= S1 + 1;
			if (S1 == dist)LU <= 1'b1;
		end
		else begin
			LU <= 1'b0;
			S1 <= {w{1'b0}};
		end
		
		if (B2) begin
			S2 <= S2 + 1;
			if (S2 == dist)LD <= 1'b1;
		end
		else begin
			LD <= 1'b0;
			S2 <= {w{1'b0}};
		end
		
		if (B3) begin
			S3 <= S3 + 1;
			if (S3 == dist)RU <= 1'b1;
		end
		else begin
			RU <= 1'b0;
			S3 <= {w{1'b0}};
		end
		
		if (B4) begin
			S4 <= S4 + 1;
			if (S4 == dist)RD <= 1'b1;
		end
		else begin
			RD <= 1'b0;
			S4 <= {w{1'b0}};
		end
	end

endmodule