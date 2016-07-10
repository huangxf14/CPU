`timescale 1ns/1ns

module EXtoMEM(clk,reset,PCadd4_in,PCadd4_out,
               MemRead_in,MemWrite_in,                               //MEM
               MemtoReg_in,RegWrite_in,                              //WB
               ALUout_in,EX2MEM_rd_in,EX2MEM_regB_in,
               MemRead_out,MemWrite_out,                               //MEM
               MemtoReg_out,RegWrite_out,                              //WB
               ALUout_out,EX2MEM_rd_out,EX2MEM_regB_out);
input clk,reset;
input MemRead_in,MemWrite_in,RegWrite_in;
input [1:0] MemtoReg_in;
input [4:0] EX2MEM_rd_in;
input [31:0] ALUout_in,EX2MEM_regB_in,PCadd4_in;
output reg MemRead_out,MemWrite_out,RegWrite_out;
output reg [1:0] MemtoReg_out;
output reg [4:0] EX2MEM_rd_out;
output reg [31:0] ALUout_out,EX2MEM_regB_out,PCadd4_out;

always @(posedge clk or negedge reset)
begin
  if(~reset)
  begin
    MemRead_out<=1'b0;
    MemWrite_out<=1'b0;
    RegWrite_out<=1'b0;
    MemtoReg_out<=2'b0;
    EX2MEM_rd_out<=5'b00000;
    ALUout_out<=32'h00000000;
    EX2MEM_regB_out<=32'h00000000;
    PCadd4_out<=32'h00000000;
  end
  else
  begin
    MemRead_out<=MemRead_in;
    MemWrite_out<=MemWrite_in;
    RegWrite_out<=RegWrite_in;
    MemtoReg_out<=MemtoReg_in;
    EX2MEM_rd_out<=EX2MEM_rd_in;
    ALUout_out<=ALUout_in;
    EX2MEM_regB_out<=EX2MEM_regB_in;
    PCadd4_out<=PCadd4_in;   
  end
end

endmodule
                              