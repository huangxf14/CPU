`timescale 1ns/1ns

module DataMem(reset,clk,rd,wr,addr,wdata,rdata);
input reset,clk;
input rd,wr;
input [31:0] addr;	//Address Must be Word Aligned
output [31:0] rdata;
input [31:0] wdata;

parameter RAM_SIZE = 256;
parameter RAM_SIZE_BIT = 8;
reg [31:0] RAMDATA [RAM_SIZE-1:0];

assign rdata=(rd && (addr[RAM_SIZE_BIT+1:2] < RAM_SIZE))?RAMDATA[addr[RAM_SIZE_BIT+1:2]]:32'h00000000;

integer i;
always@(posedge clk or negedge reset) begin
  if(~reset) begin
    for(i=0;i<RAM_SIZE;i=i+1)
      RAMDATA[i] <= 32'h00000000;
  end
  else begin
	if(wr && (addr[RAM_SIZE_BIT+1:2] < RAM_SIZE)) RAMDATA[addr[RAM_SIZE_BIT+1:2]]<=wdata;
	end
end

endmodule
