`timescale 1ns/1ns

module IDtoEX(clk,reset,IDEX_Flush,PCadd4_in,PCadd4_out,
              RegDst_in,ALUSrc1_in,ALUSrc2_in,Sign_in,ALUFun_in,    //EX
              MemRead_in,MemWrite_in,                               //MEM
              MemtoReg_in,RegWrite_in,                              //WB
              ID2EX_rsContent_in,ID2EX_rtContent_in,ID2EX_rs_in,ID2EX_rt_in,ID2EX_rd_in,Shamt_in,imm32_in,
              RegDst_out,ALUSrc1_out,ALUSrc2_out,Sign_out,ALUFun_out,    //EX
              MemRead_out,MemWrite_out,                               //MEM
              MemtoReg_out,RegWrite_out,                              //WB 
              ID2EX_rsContent_out,ID2EX_rtContent_out,ID2EX_rs_out,ID2EX_rt_out,ID2EX_rd_out,Shamt_out,imm32_out);
input clk,reset,IDEX_Flush;
input ALUSrc1_in,ALUSrc2_in,Sign_in,MemRead_in,MemWrite_in,RegWrite_in;
input [1:0] RegDst_in,MemtoReg_in;
input [5:0] ALUFun_in;
input [31:0] ID2EX_rsContent_in,ID2EX_rtContent_in,imm32_in,PCadd4_in;
input [4:0] ID2EX_rs_in,ID2EX_rt_in,ID2EX_rd_in,Shamt_in;

output reg ALUSrc1_out,ALUSrc2_out,Sign_out,MemRead_out,MemWrite_out,RegWrite_out;
output reg [1:0] RegDst_out,MemtoReg_out;
output reg [4:0] ID2EX_rs_out,ID2EX_rt_out,ID2EX_rd_out,Shamt_out;
output reg [5:0] ALUFun_out;
output reg [31:0] ID2EX_rsContent_out,ID2EX_rtContent_out,imm32_out,PCadd4_out;

always @(posedge clk or negedge reset)
begin
  if(~reset)
  begin
    ALUSrc1_out<=1'b0;
    ALUSrc2_out<=1'b0;
    Sign_out<=1'b0;
    MemRead_out<=1'b0;
    MemWrite_out<=1'b0;
    RegWrite_out<=1'b0;
    RegDst_out<=2'b00;
    MemtoReg_out<=2'b00;
    ID2EX_rs_out<=5'b00000;
    ID2EX_rt_out<=5'b00000;
    ID2EX_rd_out<=5'b00000;
    ALUFun_out<=6'b000000;
    Shamt_out<=5'b00000;
    ID2EX_rsContent_out<=32'h00000000;
    ID2EX_rtContent_out<=32'h00000000;
    imm32_out<=32'h00000000;
    PCadd4_out<=32'h00000000;
  end
  else if(IDEX_Flush)
  begin
    ALUSrc1_out<=1'b0;
    ALUSrc2_out<=1'b0;
    Sign_out<=1'b0;
    MemRead_out<=1'b0;
    MemWrite_out<=1'b0;
    RegWrite_out<=1'b0;
    RegDst_out<=2'b00;
    MemtoReg_out<=2'b00;
    ID2EX_rs_out<=5'b00000;
    ID2EX_rt_out<=5'b00000;
    ID2EX_rd_out<=5'b00000;
    Shamt_out<=5'b00000;
    ALUFun_out<=6'b000000;
    ID2EX_rsContent_out<=32'h00000000;
    ID2EX_rtContent_out<=32'h00000000;
    imm32_out<=32'h00000000;
    PCadd4_out<=32'h00000000;    
  end
  else
  begin
    ALUSrc1_out<=ALUSrc1_in;
    ALUSrc2_out<=ALUSrc2_in;
    Sign_out<=Sign_in;
    MemRead_out<=MemRead_in;
    MemWrite_out<=MemWrite_in;
    RegWrite_out<=RegWrite_in;
    RegDst_out<=RegDst_in;
    MemtoReg_out<=MemtoReg_in;
    ID2EX_rs_out<=ID2EX_rs_in;
    ID2EX_rt_out<=ID2EX_rt_in;
    ID2EX_rd_out<=ID2EX_rd_in;
    Shamt_out<=Shamt_in;
    ALUFun_out<=ALUFun_in;
    ID2EX_rsContent_out<=ID2EX_rsContent_in;
    ID2EX_rtContent_out<=ID2EX_rtContent_in;
    imm32_out<=imm32_in;
    PCadd4_out<=PCadd4_in;
  end
end

endmodule             
              
              