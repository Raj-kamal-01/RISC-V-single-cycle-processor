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