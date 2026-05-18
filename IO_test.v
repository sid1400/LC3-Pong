module IO_test
(
	input wire clk,
	input wire rst,

	input wire ILU,
	input wire ILD,
	input wire IRU,
	input wire IRD,

	output wire vga_hs,
	output wire vga_vs,
	output wire vga_r,
	output wire vga_g,
	output wire vga_b
);

	////////////////////////////////////////////////////////////
	// IO bus
	////////////////////////////////////////////////////////////

	wire clkb;
	wire [15:0] addrb;
	wire [15:0] datab;
	wire [15:0] web;

	reg [15:0] value;

	////////////////////////////////////////////////////////////
	// Memory map
	////////////////////////////////////////////////////////////

	reg [15:0] mem [0:2];

	////////////////////////////////////////////////////////////
	// Movement clock divider
	////////////////////////////////////////////////////////////

	parameter MOVE_DIV_BITS = 22;

	reg [MOVE_DIV_BITS-1:0] move_counter;
	wire move_tick = (move_counter == 0);

	always @(posedge clk) begin
		if (!rst)
			move_counter <= 0;
		else
			move_counter <= move_counter + 1'b1;
	end

	////////////////////////////////////////////////////////////
	// TEMP REGISTERS
	////////////////////////////////////////////////////////////

	reg [7:0] bx, by;
	reg [7:0] pl, pr;

	reg pl_dir; // 0 = up, 1 = down
	reg pr_dir; // 0 = up, 1 = down

	////////////////////////////////////////////////////////////
	// IO PROCESS
	////////////////////////////////////////////////////////////

	IOProcess uut (
		.clk(clk),
		.rst(rst),

		.clkb(clkb),
		.addrb(addrb),
		.datab(datab),
		.web(web),
		.value(value),

		.vga_hs(vga_hs),
		.vga_vs(vga_vs),
		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b),

		.ILU(ILU),
		.ILD(ILD),
		.IRU(IRU),
		.IRD(IRD)
	);

	////////////////////////////////////////////////////////////
	// MAIN SYSTEM
	////////////////////////////////////////////////////////////

	always @(posedge clk) begin

		if (!rst) begin

			mem[0] <= 16'd0;
			mem[1] <= {8'd128, 8'd128};
			mem[2] <= {8'd64, 8'd64};

			pl <= 8'd64;
			pr <= 8'd64;

			pl_dir <= 1'b1;
			pr_dir <= 1'b1;

		end
		else begin

			////////////////////////////////////////////////////
			// IO WRITE
			////////////////////////////////////////////////////

			if (web != 16'd0) begin
				case (addrb)
					16'd0: mem[0] <= datab;
					16'd1: mem[1] <= datab;
					16'd2: mem[2] <= datab;
				endcase
			end

			////////////////////////////////////////////////////
			// SLOW GAME UPDATE
			////////////////////////////////////////////////////

			if (move_tick) begin

				////////////////////////////////////////////////
				// BALL (unchanged logic)
				////////////////////////////////////////////////

				bx = mem[1][7:0];
				by = mem[1][15:8];

				if (mem[0][3] && by > 0)   by = by - 1;
				if (mem[0][2] && by < 255) by = by + 1;
				if (mem[0][1] && bx < 255) bx = bx + 1;
				if (mem[0][0] && bx > 0)   bx = bx - 1;

				mem[1] <= {by, bx};

				////////////////////////////////////////////////
				// LEFT PADDLE (0 ↔ 96)
				////////////////////////////////////////////////

				if (pl_dir == 1'b1) begin
					if (pl < 8'd96)
						pl <= pl + 1;
					else
						pl_dir <= 1'b0;
				end
				else begin
					if (pl > 0)
						pl <= pl - 1;
					else
						pl_dir <= 1'b1;
				end

				////////////////////////////////////////////////
				// RIGHT PADDLE (0 ↔ 96)
				////////////////////////////////////////////////

				if (pr_dir == 1'b1) begin
					if (pr < 8'd96)
						pr <= pr + 1;
					else
						pr_dir <= 1'b0;
				end
				else begin
					if (pr > 0)
						pr <= pr - 1;
					else
						pr_dir <= 1'b1;
				end

				mem[2] <= {pr, pl};

			end
		end
	end

	////////////////////////////////////////////////////////////
	// READ BUS
	////////////////////////////////////////////////////////////

	always @(*) begin
		case (addrb)
			16'd0: value = mem[0];
			16'd1: value = mem[1];
			16'd2: value = mem[2];
			default: value = 16'd0;
		endcase
	end

endmodule