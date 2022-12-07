module riscV(clk,Alures,instruction,rslt,dataread);
input clk;
output [31:0] Alures, instruction ,dataread;
output reg[31:0] rslt;

wire zero,alusrc,regwrite,PCsrc,memwrite;
wire [1:0] Resultsrc,immsrc;
wire [2:0] ALUcontrol;
wire [31:0] Instrc,Dataaddr,Writedata,PC,Readdata,PCnext,SrcA,SrcB,RD2,Immextr,ALUresult,PCplus4,Result,PCtarget;

controller r01(PCsrc,Resultsrc,ALUcontrol,memwrite,alusrc,regwrite,immsrc,Instrc,zero);

//datapath
PCCounter m01(clk,PCnext,PC);
PCadder m02(PC,PCplus4);
MUX1 m03(PCplus4,PCtarget,PCsrc,PCnext);
add m08(PC,Immextr,PCtarget);

instructionmemory r04(PC,Instrc);

Registerfile m04(clk,regwrite,Instrc[19:15],Instrc[24:20],Instrc[11:7],Result,SrcA,RD2);
immext m05(Instrc[31:7],immsrc,Immextr);
MUX1 m06(RD2,Immextr,alusrc,SrcB);
ALU m07(ALUresult,zero,SrcA,SrcB,ALUcontrol);

DataMemory r03(clk,Readdata,RD2,ALUresult,memwrite);

MUX2 m09(ALUresult,Readdata,PCplus4,Resultsrc,Result);

assign instruction = Instrc;
assign Dataaddr = ALUresult;
assign Alures=Dataaddr;
assign dataread=Readdata;

always@(*) begin rslt<=Result;end

endmodule