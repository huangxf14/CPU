`timescale 1ns/1ns

module MEMtoWB(clk,reset,PCadd4_in,PCadd4_out,
               MemtoReg_in,RegWrite_in,           //WB
               ALUout_in,MEMData_in,MEM2WB_rd_in,
               MemtoReg_out,RegWrite_out,           //WB
               ALUout_out,MEMData_out,MEM2WB_rd_out);
input clk,reset;
input RegWrite_in;
input [1:0] MemtoReg_in;
input [4:0] MEM2WB_rd_in;
input [31:0] ALUout_in,MEMData_in,PCadd4_in;
output reg RegWrite_out;
output reg [1:0] MemtoReg_out;
output reg [4:0] MEM2WB_rd_out;
output reg [31:0] ALUout_out,MEMData_out,PCadd4_out;

always @(posedge clk or negedge reset)
begin
  if(~reset)
  begin
    RegWrite_out<=1'b0;
    MemtoReg_out<=2'b00;
    MEM2WB_rd_out<=5'b00000;
    ALUout_out<=32'h00000000;
    MEMData_out<=32'h00000000;
    PCadd4_out<=32'h00000000;
  end
  else
  begin
    RegWrite_out<=RegWrite_in;
    MemtoReg_out<=MemtoReg_in;
    MEM2WB_rd_out<=MEM2WB_rd_in;
    ALUout_out<=ALUout_in;
    MEMData_out<=MEMData_in;
    PCadd4_out<=PCadd4_in;   
  end
end

endmodule