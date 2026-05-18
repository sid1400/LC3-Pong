//`include "reges.v"
//`include "memory.v"
//`include "ALU.v"
//`include "PIS.v"

//we include clk interface here to get data to and from VGA, and inputs
module computer(input CLK,input rst,input clkb,input [15:0] addr_b,input [15:0] data_b,input web,output [15:0] out_b);

	// this part will make this system work with block RAM(only posedge clk)
	 reg [1:0]FSM = 2'b0;
	 
	 wire [15:0] new_PIN;
	 
    wire [15:0] PIN;
    wire [15:0] PI;
    wire [15:0] PINPP = PIN + 16'd1;
    PM PC(CLK,new_PIN,FSM, rst,PI,PIN);

    wire [3:0] op = PI[15:12];
    wire [2:0] DR = PI[11:9];
    wire [2:0] SR1 = PI[8:6];
    wire [2:0] SR2 = PI[2:0];

    wire [8:0] UnExtPC9 = PI[8:0];
    wire [10:0] UnExtPC11 = PI[10:0];
    wire [4:0] UnExtImm5 = PI[4:0];
    wire [5:0] UnExtImm6 = PI[5:0];

    wire [15:0] PC9;
    wire [15:0] PC11;
    wire [15:0] Imm5;
    wire [15:0] Imm6;

    Sex #(9) Ext9 (UnExtPC9,PC9);
    Sex #(11) Ext11 (UnExtPC11,PC11);
    Sex #(5) Ext5 (UnExtImm5,Imm5);
    Sex #(6) Ext6 (UnExtImm6,Imm6);
	 

    //regsong
    wire [2:0] A1 = SR1;
    wire A2Control = op[0] & op[1] & ~(op[2] & op[3]);//will be used again in Men
    wire [2:0] A2 = A2Control ? DR : SR2;
    wire A3Control = (~op[0])&(~op[1])&(op[2])&(~op[3]);
    wire [2:0] A3 = A3Control ? 3'b111 : DR;
    wire [15:0] O2;
    wire [15:0] O1;
    wire [15:0] RegWord;

    wire Ren =((op[0] ^ op[1]) &(~op[3] | ~op[2] | op[1] | ~op[0])) | (~op[0] & ~op[1] & op[2] & ~op[3]) ;
    register_set RL(CLK,A1,A2,A3,RegWord,Ren&&(FSM == 2'b10),rst,O1,O2);
	
	 wire [15:0] ALUout;

    //memory control with pointer
    wire [15:0] MemIn = ALUout;
    wire [15:0] MemOut;

    wire [15:0] M2 = MemIn;
    wire [15:0] MO2;
    wire [15:0] M1 = op[3]?MO2:M2;
    wire [15:0] MO1;
    assign MemOut = MO1;
    wire [15:0] MemWord = O2;
    wire Men = A2Control;// things below have been changed to remove ldi and sti
    memory MEM(CLK,M1,MemWord,Men&&(FSM == 2'b01),MO1,MO2, clkb, addr_b,data_b,web,out_b);

    wire I1cond = op[0] & ~op[1] & ~(op[2] & op[3]) | ~(op[3]|~op[2]|~op[1]);
    wire [15:0] I1 = I1cond?O1:PINPP;
    wire [15:0] I2 = op[1] ?
                        ((op[2]&~op[3])?Imm6:PC9)
                        :(PI[5]?Imm5:O2);
    ALU_unit ALU(CLK,I1,I2,op[2]&~op[1],op[3]&~op[1],rst,ALUout);

    //RegWord Control
    wire RegWordCond = op[2] & (op[3] | (~op[0])&(~op[1]));
    assign RegWord =  RegWordCond?(op[1]?ALUout:PINPP)
                                :(op[0]?ALUout:MemOut);
										  
	 wire [15:0]PSR;
    //PIN adder circuit
    wire NZPtrigger = PSR[2]&DR[2] | PSR[1]&DR[1] | PSR[0]&DR[0];
    wire [15:0] BRlength = NZPtrigger?PC9:16'd0;
    wire [15:0] JumpLength = op[2]?PC11:BRlength;
    wire [15:0] Finaljump = (op[0]|op[1]|op[3]) ? 16'd0 : JumpLength;
    wire [15:0] addendumPC = PINPP + Finaljump;

    wire JumpOrIncrement = ~op[0] & ~op[1] & op[2] & (op[3] | ~DR[2]);
    //PIN Connections
    assign new_PIN = JumpOrIncrement?O1:addendumPC;
    
	 
    NZPer Fsine(CLK,RegWord,Ren&&(FSM == 2'b10),rst,PSR[2],PSR[1],PSR[0]);
	
	 always @(posedge CLK) begin
		if (FSM == 2'b10) FSM <= 2'b00;
		else FSM<= FSM + 1;
	 end


endmodule


