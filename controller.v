module controller(PCsrc,Resultsrc,ALUcontrol,memwrite,alusrc,regwrite,immsrc,Instrc,zero);
input zero;
input [31:0] Instrc;
output alusrc,regwrite,PCsrc,memwrite;
output [1:0] Resultsrc;
output [1:0] immsrc;
output [2:0] ALUcontrol;

wire [1:0]aluop;
wire jump,branch,beq1;

maindec c01(Instrc[6:0],Resultsrc,memwrite,branch,alusrc,regwrite,jump,aluop,immsrc);
ALUDec c02(ALUcontrol,aluop,Instrc[14:12],Instrc[29],Instrc[4]);

and a1(beq1,zero,branch);
or o1(PCsrc,beq1,jump);

endmodule