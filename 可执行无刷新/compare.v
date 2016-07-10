`timescale 1ns/1ns

module compare(DatabusA,DatabusB,Inst3126,compareAB);
input [31:0] DatabusA,DatabusB;
input [5:0] Inst3126;
output reg compareAB;

always @(*)
begin
  case(Inst3126)
    6'h1:compareAB=(DatabusA[31]==1)?1'b1:1'b0;    //bltz
    6'h4:compareAB=(DatabusA==DatabusB)?1'b1:1'b0;  //beq
    6'h5:compareAB=(DatabusA!=DatabusB)?1'b1:1'b0;  //bne
    6'h6:compareAB=(DatabusA[31]==1 || DatabusA==0)?1'b1:1'b0; //blez
    6'h7:compareAB=(DatabusA>0 || DatabusA==0)?1'b1:1'b0;   //bgtz
    default:compareAB=1'b0;
  endcase
end

endmodule