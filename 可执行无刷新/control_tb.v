`timescale 1ns/1ns
module control_tb;
	reg [5:0] OpCode;
	reg [5:0] Funct;
	reg IRQ;
	reg PC_31;
	wire [2:0] PCSrc;
	wire RegWrite;
	wire [1:0] RegDst;
	wire MemRead;
	wire MemWrite;
	wire [1:0] MemtoReg;
	wire ALUSrc1;
	wire ALUSrc2;
	wire ExtOp;
	wire LuOp;
	wire [5:0] ALUFun;
	wire Sign;
	
	initial begin
		#0 IRQ = 0;
		PC_31 = 0;
		Funct = 6'h0;
		OpCode = 6'h23;    //lw
		#100 OpCode = 6'h2b; //sw
		#100 OpCode = 6'hf;  //lui
		#100 OpCode = 6'h0;  //add
		Funct = 6'h20;
		#100 Funct = 6'h21;
		#100 Funct = 6'h04;
		#100 Funct = 6'h05;
		#100 OpCode = 6'h8; //addi
		#100 OpCode = 6'h9; //addiu
		#100 OpCode = 6'h0;
		Funct = 6'h24;
		#100 Funct = 6'h25;
		#100 Funct = 6'h26;
		#100 Funct = 6'h27;
		#100 OpCode = 6'hc; //andi
		#100 OpCode = 6'h0;
		Funct = 6'h0;      //sll
		#100 Funct = 6'h2;
		#100 Funct = 6'h3;
		#100 Funct = 6'h2a;  //slt
		#100 Funct = 6'h2b;
		#100 OpCode = 6'ha;  //slti
		#100 OpCode = 6'hb;
		#100 OpCode = 6'h4;  //beq
		#100 OpCode = 6'h5;  //bne
		#100 OpCode = 6'h6;
		#100 OpCode = 6'h7;
		#100 OpCode = 6'h1;  //bltz
		#100 OpCode = 6'h2;
		#100 OpCode = 6'h3;
		#100 OpCode = 6'h0;
		Funct = 6'h8;        //jr
		#100 Funct = 6'h9;
		#100 Funct = 6'h30;  //XADR
		#100 Funct = 6'h0;
		IRQ = 1;
	end
		
	Control Control1(.OpCode(OpCode), .Funct(Funct), .IRQ(IRQ), .PC_31(PC_31),
	.PCSrc(PCSrc), .RegWrite(RegWrite), .RegDst(RegDst), .Sign(Sign),
	.MemRead(MemRead), .MemWrite(MemWrite), .MemtoReg(MemtoReg), 
	.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp), .ALUFun(ALUFun));
endmodule
	
	