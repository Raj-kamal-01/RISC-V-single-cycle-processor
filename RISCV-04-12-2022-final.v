module toplayer(clk,result);
input clk;
output reg [15:0]result;
wire [31:0] dataout; 

riscV tp01(.clk(clk),.dataread(dataout));
always@(*) result <= dataout[15:0];

endmodule


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

module Registerfile(clk, RegWrite,R1,R2,W1,WD1,RD1,RD2);
input clk,RegWrite;
input [4:0] R1;
input [4:0] R2;
input [4:0] W1;
input [31:0] WD1;
output [31:0] RD1;
output [31:0] RD2;
reg [31:0] Register [31:0];

initial
begin
Register[0] = 32'h00000000;
Register[1] = 32'h00000000;
Register[2] = 32'h00000000;
Register[3] = 32'h00000000;
Register[4] = 32'h00000000;
Register[5] = 32'h00000000;
Register[6] = 32'h00000000;
Register[7] = 32'h00000000;
Register[8] = 32'h00000000;
Register[9] = 32'h00000000;
Register[17] = 32'h00000001;
end
always @(posedge clk)
begin
if(RegWrite)
Register[W1] <= WD1;
end
assign RD1 = (R1 != 0) ? Register[R1] : 0;
assign RD2 = (R2 != 0) ? Register[R2] : 0;
endmodule


module DataMemory(clk,RD,WD,address,MemWrite);
input clk, MemWrite;
input [31:0] address;
input [31:0] WD;
output [31:0] RD;
reg [31:0] mem1[511:0];
initial
begin
mem1[0] = 32'h00000000;
mem1[1] = 32'h00000000;
mem1[2] = 32'h00000000;
mem1[3] = 32'h00000000;
mem1[4] = 32'h00000000;
mem1[5] = 32'h00000000;
mem1[6] = 32'h00000000;
mem1[7] = 32'h00000000;
end
always @(posedge clk)
begin
if(MemWrite)
mem1[address] <= WD;
end
assign RD = mem1[address];
endmodule

module PCadder (PC,PCPlus4);
input [31:0]PC;
output [31:0]PCPlus4;
assign PCPlus4 = PC + 1;
endmodule

module PCCounter (clk,PC1,PC);
input clk;
input [31:0]PC1;
output reg [31:0]PC;
always@(posedge clk)
begin
PC <= PC1;
end
initial begin PC=32'b0; end
endmodule

module MUX2 (a,b,c,s,out);
input [31:0]a;
input [31:0]b;
input [31:0]c;
input [1:0]s;
output reg [31:0]out;
always @(*)
begin
case(s)
2'b00: out=a;
2'b01: out=b;
2'b10: out=c;
default: out=a;
endcase
end
endmodule

module maindec(op,Resultsrc, memwrite,branch, alusrc,regwrite,jump,aluop,immsrc);
input [6:0] op;
output [1:0]Resultsrc;
output memwrite,branch, alusrc, jump,regwrite;
output [1:0]aluop;
output [1:0]immsrc;
reg [10:0] controls;
assign {regwrite, immsrc, alusrc, branch, memwrite,Resultsrc, jump, aluop}= controls;
always @(*)
case(op)
// RegWrite_ImmSrc_ALUsrc_Branch_MemWrite_ResultSrc_Jump_Aluop
7'b0110011: controls <= 11'b1_xx_0_0_0_00_0_10; // R-type data
7'b0010011: controls <= 11'b1_00_1_0_0_00_0_11; // I-type data
7'b0000011: controls <= 11'b1_00_1_0_0_01_0_00; // LW
7'b0100011: controls <= 11'b0_01_1_0_1_xx_0_00; // SW
7'b1100011: controls <= 11'b0_10_0_1_0_xx_0_01; // BEQ
7'b1101111: controls <= 11'b1_11_0_0_0_10_1_00; // JAL
default: controls <= 11'bxxxxxxxxxxx; // ???
endcase
endmodule

module instructionmemory(address, RD);
	input [31:0]address;
	output [31:0] RD;

reg [31:0] mem1[511:0];
initial
begin
mem1[0] = 32'h0;
mem1[1] = 32'h00000113; //addi x2 0(x0)
mem1[2] = 32'h00400093; //addi x1 4(x0)
mem1[3] = 32'h00100193; //addi x3 1(x0)
mem1[4] = 32'hFE20AF23; //sw x2 -2(x1)
mem1[5] = 32'hFE30AFA3; //sw x3 -1(x1)
mem1[6] = 32'h00310233; //add x4 x2 x3
mem1[7] = 32'h0040A023; //sw x4 0 (x1)
mem1[8] = 32'h00108093; //addi x1 1 (x1) 
mem1[9] = 32'h00018113; //addi x2 0 (x3)
mem1[10] = 32'h00020193; //addi x3 0 (x4)
mem1[11] = 32'h00310233; //add x4 x2 x3
mem1[12] = 32'h0040A023; //sw x4 0 (x1)
mem1[13] = 32'h00108093; //addi x1 1 (x1) 
mem1[14] = 32'h00018113; //addi x2 0 (x3)
mem1[15] = 32'h00020193; //addi x3 0 (x4)
mem1[16] = 32'h00310233; //add x4 x2 (x3)
mem1[17] = 32'h0040A023; //sw x4 0(x1)
mem1[18] = 32'h00108093; //addi x1 1 x1 
mem1[19] = 32'h00018113; //addi x2 0 x3
mem1[20] = 32'h00020193; //addi x3 0 x4
mem1[21] = 32'h00310233; //add x4 x2 x3
mem1[22] = 32'h0040A023; //sw x4 0 x1
mem1[23] = 32'h00108093; //addi x1 1 x1 
mem1[24] = 32'h00018113; //addi x2 0 x3
mem1[25] = 32'h00020193; //addi x3 0 x4
mem1[26] = 32'h00310233; //add x4 x2 x3
mem1[27] = 32'h0040A023; //sw x4 0 x1
mem1[28] = 32'h00108093; //addi x1 1 x1 
mem1[29] = 32'h00018113; //addi x2 0 x3
mem1[30] = 32'h00020193; //addi x3 0 x4
mem1[31] = 32'h00310233; //add x4 x2 x3
mem1[32] = 32'h0040A023; //sw x4 0 x1
mem1[33] = 32'h00108093; //addi x1 1 x1 
mem1[34] = 32'h00018113; //addi x2 0 x3
mem1[35] = 32'h00020193; //addi x3 0 x4
mem1[36] = 32'h00310233; //add x4 x2 x3
mem1[37] = 32'h0040A023; //sw x4 0 x1
mem1[38] = 32'h00108093; //addi x1 1 x1 
mem1[39] = 32'h00018113; //addi x2 0 x3
mem1[40] = 32'h00020193; //addi x3 0 x4
mem1[41] = 32'h00310233; //add x4 x2 x3
mem1[42] = 32'h0040A023; //sw x4 0 x1
mem1[43] = 32'h00108093; //addi x1 1 x1 
mem1[44] = 32'h00018113; //addi x2 0 x3
mem1[45] = 32'h00020193; //addi x3 0 x4
mem1[46] = 32'h00310233; //add x4 x2 x3
mem1[47] = 32'h0040A023; //sw x4 0 x1
mem1[48] = 32'h00108093; //addi x1 1 x1 
mem1[49] = 32'h00018113; //addi x2 0 x3
mem1[50] = 32'h00020193; //addi x3 0 x4
mem1[51] = 32'h00310233; //add x4 x2 x3
mem1[52] = 32'h0040A023; //sw x4 0 x1
mem1[53] = 32'h00108093; //addi x1 1 x1 
mem1[54] = 32'h00018113; //addi x2 0 x3
mem1[55] = 32'h00020193; //addi x3 0 x4
mem1[56] = 32'h00310233; //add x4 x2 x3
mem1[57] = 32'h0040A023; //sw x4 0 x1
mem1[58] = 32'h00108093; //addi x1 1 x1 
mem1[59] = 32'h00018113; //addi x2 0 x3
mem1[60] = 32'h00020193; //addi x3 0 x4

mem1[61] = 32'h00310233; //add x4 x2 x3
mem1[62] = 32'h0040A023; //sw x4 0 x1
mem1[63] = 32'h00108093; //addi x1 1 x1 
mem1[64] = 32'h00018113; //addi x2 0 x3
mem1[65] = 32'h00020193; //addi x3 0 x4
mem1[66] = 32'h00310233; //add x4 x2 x3
mem1[67] = 32'h0040A023; //sw x4 0 x1
mem1[68] = 32'h00108093; //addi x1 1 x1 
mem1[69] = 32'h00018113; //addi x2 0 x3
mem1[70] = 32'h00020193; //addi x3 0 x4
mem1[71] = 32'h00310233; //add x4 x2 x3
mem1[72] = 32'h0040A023; //sw x4 0 x1
mem1[73] = 32'h00108093; //addi x1 1 x1 
mem1[74] = 32'h00018113; //addi x2 0 x3
mem1[75] = 32'h00020193; //addi x3 0 x4
mem1[76] = 32'h00310233; //add x4 x2 x3
mem1[77] = 32'h0040A023; //sw x4 0 x1
mem1[78] = 32'h00108093; //addi x1 1 x1 
mem1[79] = 32'h00018113; //addi x2 0 x3
mem1[80] = 32'h00020193; //addi x3 0 x4
mem1[81] = 32'h00310233; //add x4 x2 x3
mem1[82] = 32'h0040A023; //sw x4 0 x1
mem1[83] = 32'h00108093; //addi x1 1 x1 
mem1[84] = 32'h00018113; //addi x2 0 x3
mem1[85] = 32'h00020193; //addi x3 0 x4

mem1[86] = 32'h00008093; //addi x1 0 x1


//loading
mem1[87] = 32'h00202303; //lw x7 2( x0)
mem1[88] = 32'h00302303; //lw x7 3( x0)
mem1[89] = 32'hFF00A483; //lw x7 -16( x1)
mem1[90] = 32'hFF10A483; //lw x7 -15( x1)
mem1[91] = 32'hFF20A483; //lw x7 -14( x1)
mem1[92] = 32'hFF30A483; //lw x7 -13( x1)
mem1[93] = 32'hFF40A483; //lw x7 -12( x1)
mem1[94] = 32'hFF50A483; //lw x7 -11( x1)
mem1[95] = 32'hFF60A483; //lw x7 -10( x1)
mem1[96] = 32'hFF70A483; //lw x7 -9( x1)
mem1[97] = 32'hFF80A483; //lw x7 -8( x1)
mem1[98] = 32'hFF90A483; //lw x7 -7( x1)
mem1[99] = 32'hFFA0A483; //lw x7 -6( x1)
mem1[100] = 32'hFFB0A483; //lw x7 -5( x1)
mem1[101] = 32'hFFC0A483; //lw x7 -4( x1)
mem1[102] = 32'hFFD0A483; //lw x7 -3( x1)
mem1[103] = 32'hFFE0A483; //lw x7 -2( x1)
mem1[104] = 32'hFFF0A483; //lw x7 -1( x1)

mem1[105] = 32'hFE4187E3; //beq x3 x4 mem1[87]

end
assign RD = mem1[address];
endmodule


module ALU(aluresult,zero,SrcA,SrcB,ALUcontrol);
input [31:0]SrcA;
input [31:0]SrcB;
input [2:0]ALUcontrol;
output reg [31:0]aluresult;
output reg zero;
always @(*)
begin
case(ALUcontrol)
3'b000 : aluresult = SrcA + SrcB; //add
3'b001 : aluresult = SrcA - SrcB; //sub
3'b010 : aluresult = SrcA & SrcB; //and
3'b011 : aluresult = SrcA | SrcB; //or
3'b100 : aluresult = SrcA ^ SrcB; //xor
default : aluresult = 32'bx;
endcase

if(aluresult == 0)
zero=1;
else
zero=0;
end
endmodule

module ALUDec(ALUcontrol,Aluop,funct3,funct7b5,op5);
input [2:0]funct3;
input funct7b5,op5;
input [1:0]Aluop;
output reg [2:0]ALUcontrol;

always @(*)
begin
case (Aluop)
2'b00 : ALUcontrol <= 3'b000; //add
2'b01 : ALUcontrol <= 3'b001; //sub
2'b10 : case(funct3)
3'b000: begin if({op5,funct7b5}== 2'b11) ALUcontrol <= 3'b001; //sub
       else ALUcontrol <= 3'b000; end //add
3'b111: ALUcontrol <= 3'b010; //and
3'b110: ALUcontrol <= 3'b011; //or
3'b100: ALUcontrol <= 3'b100; //xor

endcase
2'b11 : case(funct3)
3'b000: ALUcontrol <= 3'b000; //addi
3'b110: ALUcontrol <= 3'b011; //ori
3'b111: ALUcontrol <= 3'b010; //andi
endcase
default: ALUcontrol <= 3'bxxx;
endcase
end 
endmodule


module add (A1,A2,Y);
input [31:0]A1;
input [31:0]A2;
output [31:0]Y;
assign Y = A1 + A2;
endmodule

module MUX1 (a,b,s,out);
input [31:0]a;
input [31:0]b;
input s;
output reg [31:0]out;
always @(*) begin 
case(s)
1'b0: out=a;
1'b1: out=b;
default out=a;
endcase
end
endmodule

module immext(instr,immsrc,extimm);
input [31:7] instr;
input [1:0]immsrc;
output reg [31:0]extimm;
always @(*)
begin
case(immsrc)
// I-type (Data processing with immediate and loads)
2'b00: extimm = {{20{instr[31]}}, instr[31:20]};
// S-type (Stores)
2'b01: extimm = {{20{instr[31]}}, instr[31:25] , instr[11:7]};
// B-type (Branches)
2'b10: extimm = {{20{instr[31]}}, instr[7] , instr[30:25], instr[11:8] , 1'b0};
// U-type (Jumps)
2'b11: extimm = {{12{instr[31]}}, instr[19:12] , instr[20] , instr[30:21], 1'b0};
default: extimm = 32'bx; // undefined
endcase
end
endmodule