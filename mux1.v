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