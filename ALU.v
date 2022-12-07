odule ALU(aluresult,zero,SrcA,SrcB,ALUcontrol);
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