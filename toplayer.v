module toplayer(clk,result);
input clk;
output reg [15:0]result;
wire [31:0] dataout; 

riscV tp01(.clk(clk),.dataread(dataout));
always@(*) result <= dataout[15:0];

endmodule