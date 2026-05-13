module ALU_unit(input CLK, input [15:0] in1, input [15:0] in2, input W2, input W1, input rst, output [15:0] ALUout);
    wire [15:0] ADDRES;
    wire [15:0] ANDRES;
    wire [15:0] NOTRES;
    assign ADDRES = in1 + in2;
    assign ANDRES = in1 & in2;
    assign NOTRES = ~(in1);
    
    wire [15:0] R1;
    assign R1 = W2?ANDRES:ADDRES;
    assign ALUout = W1?NOTRES:R1;
endmodule

module adder(input CLK,input [15:0] in1,input [15:0] in2,input rst, output [15:0] sum);
    assign sum = in1 + in2;
endmodule

module Sex  #(parameter size = 5) (input [size-1:0] in, output [15:0] out);
    assign out = {{(16-size){in[size-1]}},in};
endmodule