//`include "PLL.v"
// running 1280x768 disp at 60Hz, with reduced blanking
// clock is aprox 68.25 Mhz(PLL on screen with match to this)

module First (input wire clk, input wire rst, output reg vga_hs, output reg vga_vs, output wire vga_r, output wire vga_g, output wire vga_b);

wire clk_pixel;
wire locked;
pll_68 OuPLL(clk,clk_pixel,locked);
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

always @(posedge clk_pixel) begin
    if (!rst)
        h_count <= 11'd0;
    else if (h_count == H_TOTAL - 1)
        h_count <= 11'd0;
    else
        h_count <= h_count + 11'd1;
end

always @(posedge clk_pixel) begin
    if (!rst)
        v_count <= 10'd0;
    else if (h_count == H_TOTAL - 1) begin
        if (v_count == V_TOTAL - 1)
            v_count <= 10'd0;
        else
            v_count <= v_count + 10'd1;
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

// create black and white tilling pattern
assign vga_r = active ? h_count[6]^v_count[6] : 1'b0;
assign vga_g = active ?  h_count[6]^v_count[6] : 1'b0;
assign vga_b = active ?  h_count[6]^v_count[6] : 1'b0;

endmodule