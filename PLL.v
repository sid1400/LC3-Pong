module pll_68 (
    input  wire inclk0,   
    output wire clk_68,   
    output wire locked
);

wire [5:0] clk_bus;


altpll #(
    .operation_mode("NORMAL"),
    .inclk0_input_frequency(20000),
    .clk0_multiply_by(34),
    .clk0_divide_by(25),
    .clk0_duty_cycle(50),
    .clk0_phase_shift("0"),
    .compensate_clock("CLK0"),
    .pll_type("AUTO")
)
altpll_inst (
    .inclk   ({1'b0, inclk0}),
    .clk     (clk_bus),
    .locked  (locked),
    .areset  (1'b0),
    .clkena  (6'b111111)
);

assign clk_68 = clk_bus[0];

endmodule