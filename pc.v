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
