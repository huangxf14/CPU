`timescale 1ns/1ns

module IFtoID(clk,reset,
              IFDWrite,IFD_Flush,
              PCadd4_in,PCadd4_out,instruction_in,instruction_out);
input clk,reset,IFDWrite,IFD_Flush;
input [31:0] PCadd4_in;
input [31:0] instruction_in;
output reg [31:0] PCadd4_out;
output reg [31:0] instruction_out;

always @(posedge clk or negedge reset)
begin
  if(~reset)
  begin
    PCadd4_out<=32'h00000000;
    instruction_out<=32'h00000000;
  end
  else if(IFD_Flush)
  begin
    PCadd4_out<=32'h00000000;
    instruction_out<=32'h00000000;
  end
  else
  begin
    if(IFDWrite)
    begin
      PCadd4_out<=PCadd4_in;
      instruction_out<=instruction_in;
    end
    else
    begin
      PCadd4_out<=PCadd4_out;
      instruction_out<=instruction_out;   
    end
  end
end

endmodule   
    