module add (A1,A2,Y);
input [31:0]A1;
input [31:0]A2;
output [31:0]Y;
assign Y = A1 + A2;
endmodule