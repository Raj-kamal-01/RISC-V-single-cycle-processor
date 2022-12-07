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