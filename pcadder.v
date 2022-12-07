module PCadder (PC,PCPlus4);
input [31:0]PC;
output [31:0]PCPlus4;
assign PCPlus4 = PC + 1;
endmodule
