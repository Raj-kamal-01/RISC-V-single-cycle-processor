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