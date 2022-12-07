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