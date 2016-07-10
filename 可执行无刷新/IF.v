`timescale 1ns/1ns

module PC_IF(clk,reset,PCwrite,PC_in,PC_out);  
input clk,reset,PCwrite;
input [31:0] PC_in;
output reg [31:0] PC_out;

always @(posedge clk or negedge reset)
begin
  if(~reset)
    PC_out<=32'h80000000;
  else
  begin
    if(PCwrite)
      PC_out<=PC_in;
    else
      PC_out<=PC_out;
  end
end

endmodule
    