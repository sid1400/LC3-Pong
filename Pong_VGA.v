//`include "PLL.v"
// running 1280x768 disp at 60Hz, with reduced blanking
// clock is aprox 68.25 Mhz(PLL on screen with match to this)

module Pong_VGA (
	input wire clk,
	input wire rst,
	input wire [15:0] ball,
	input wire [15:0] paddle,
	output reg vga_hs,
	output reg vga_vs,
	output reg vga_r,
	output reg vga_g,
	output reg vga_b);

wire clk_pixel;
wire locked;
pll_68 OuPLL(clk,clk_pixel,locked);

reg [15:0] ball_buff1;
reg [15:0] ball_buff2;
reg [15:0] paddle_buff1;
reg [15:0] paddle_buff2;

wire [7:0] XB = ball_buff2[7:0];
wire [7:0] YB = ball_buff2[15:8];
wire [7:0] L = {paddle_buff2[7:1],1'b0};
wire [7:0] R = {paddle_buff2[15:9],1'b0};

//game happens at the middle, with each pizel being represented as 3 pixels.

// Horizontal
localparam H_ACTIVE      = 1280;
localparam H_FP          = 48;
localparam H_SYNC        = 32;
localparam H_BP          = 80;
localparam H_TOTAL       = H_ACTIVE + H_FP + H_SYNC + H_BP; // 1440

localparam H_SYNC_START  = H_ACTIVE + H_FP;            // 1328
localparam H_SYNC_END    = H_ACTIVE + H_FP + H_SYNC;   // 1360

// Vertical
localparam V_ACTIVE      = 768;
localparam V_FP          = 3;
localparam V_SYNC        = 7;
localparam V_BP          = 12;
localparam V_TOTAL       = V_ACTIVE + V_FP + V_SYNC + V_BP; // 790

localparam V_SYNC_START  = V_ACTIVE + V_FP;            // 771
localparam V_SYNC_END    = V_ACTIVE + V_FP + V_SYNC;   // 778


reg [10:0] h_count; 
reg [9:0]  v_count;

wire InGameX = (h_count>=11'd256 && h_count <11'd1024);
wire InGameY = (v_count < 10'd768);

reg [1:0] Xcounter;
reg [1:0] Ycounter;

reg [7:0] X;
reg [7:0] Y;

always @(posedge clk_pixel) begin
	ball_buff1 <= ball;
	ball_buff2 <= ball_buff1;
	paddle_buff1 <= paddle;
	paddle_buff2 <= paddle_buff1;
end

always @(posedge clk_pixel) begin
    if (!rst) begin
        h_count <= 11'd0;
		  X <= 0;
		  Xcounter <= 0;
		  end
    else if (h_count == H_TOTAL - 1) begin
        h_count <= 11'd0;
		  X <= 0;
		  Xcounter <= 0;
		  end
    else begin
        h_count <= h_count + 11'd1;
		  if (InGameX) begin
			Xcounter <= Xcounter + 1;
			if (Xcounter == 2'd2) begin
				Xcounter <= 0;
				X <= X+1;
			end
		  end
	 end
end

always @(posedge clk_pixel) begin
    if (!rst) begin
        v_count <= 10'd0;
		  Y <= 0;
		  Ycounter <= 0;
	 end
    else if (h_count == H_TOTAL - 1) begin
        if (v_count == V_TOTAL - 1) begin
            v_count <= 10'd0;
				Y <= 0;
				Ycounter <= 0;
			end
        else begin
            v_count <= v_count + 10'd1;
				if (InGameY) begin
					Ycounter <= Ycounter + 1;
					if (Ycounter == 2'd2) begin
						Ycounter <= 0;
						Y <= Y+1;
					end
				end
			end
    end
end

always @(posedge clk_pixel) begin
    if (!rst)
        vga_hs <= 1'b1;
    else
        vga_hs <= ~((h_count >= H_SYNC_START) && (h_count < H_SYNC_END));
end

always @(posedge clk_pixel) begin
    if (!rst)
        vga_vs <= 1'b1;
    else
        vga_vs <= ~((v_count >= V_SYNC_START) && (v_count < V_SYNC_END));
end

wire h_active = (h_count < H_ACTIVE);
wire v_active = (v_count < V_ACTIVE);
wire active   = h_active && v_active;
//displaying while not active, leads to weird video artifacts

always @(*) begin
	if (active) begin
		if (InGameX && InGameY) begin
			if (v_count >= 760) begin
				vga_r = 1'b1; vga_b = 1'b0 ; vga_g = 1'b0;
			end			
			else if (v_count <= 8) begin
				vga_r = 1'b1; vga_b = 1'b0 ; vga_g = 1'b0;
			end
			else if (X >= 8 && X < 12) begin//could be bug below?
				if (Y >= L && Y < (L+64)) begin vga_r = 1'b1; vga_b = 1'b1 ; vga_g = 1'b1; end
				else if (X>=(XB-1) && X<=(XB+1) && Y>=(YB-1) && Y<=(YB+1)) begin vga_r = 1'b1; vga_b = 1'b1 ; vga_g = 1'b1; end
				else  begin vga_r = 1'b0; vga_b = 1'b0 ; vga_g = 1'b0; end
			end
			else if (X >= 244 && X < 248) begin//could be bug below?
				if (Y >= R && Y < (R+64)) begin vga_r = 1'b1; vga_b = 1'b1 ; vga_g = 1'b1; end
				else if (X>=(XB-1) && X<=(XB+1) && Y>=(YB-1) && Y<=(YB+1)) begin vga_r = 1'b1; vga_b = 1'b1 ; vga_g = 1'b1; end
				else  begin vga_r = 1'b0; vga_b = 1'b0 ; vga_g = 1'b0; end
			end
			else if (X>=(XB-1) && X<=(XB+1) && Y>=(YB-1) && Y<=(YB+1)) begin vga_r = 1'b1; vga_b = 1'b1 ; vga_g = 1'b1; end	
			else begin vga_r = 1'b0; vga_b = 1'b0 ; vga_g = 1'b0; end
		end
		else begin
			if (h_count >= 250 && h_count < 256) begin
				vga_r = 1'b1; vga_b = 1'b0 ; vga_g = 1'b0;
			end
			else if (h_count >= 1024 && h_count < 1030) begin
				vga_r = 1'b1; vga_b = 1'b0 ; vga_g = 1'b0;
			end
			else begin vga_r = 1'b0; vga_b = 1'b0 ; vga_g = 1'b0; end
		end
	end
	else begin
		vga_r = 1'b0;
		vga_b = 1'b0;
		vga_g = 1'b0;
	end
end

// create black and white tilling pattern
//assign vga_r = active ? h_count[6]^v_count[6] : 1'b0;
//assign vga_g = active ?  h_count[6]^v_count[6] : 1'b0;
//assign vga_b = active ?  h_count[6]^v_count[6] : 1'b0;

endmodule