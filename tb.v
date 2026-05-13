`timescale 1ns/1ns
`include "computer.v"

module tb();
    reg rst=0;
    wire clk;
    clock see(clk);
    computer coa(clk,rst);
    initial begin
        rst=0;
        #12;    
        rst = 1;
        #450000;
        $finish;
    end

  initial begin
    $dumpfile("dump.vcd");  
    $dumpvars(0, tb);   
    $dumpvars(0, tb.coa.RL);      
  end
endmodule;

module clock(output reg CLK);
    initial begin
        CLK=0;
        forever #5 CLK = ~CLK;
    end
endmodule