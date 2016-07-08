module Control(OpCode, Funct, IRQ, PC_31,
	PCSrc, RegWrite, RegDst, Sign,
	MemRead, MemWrite, MemtoReg, 
	ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUFun);
	input [5:0] OpCode;
	input [5:0] Funct;
	input IRQ;
	input PC_31;
	output [2:0] PCSrc;
	output RegWrite;
	output [1:0] RegDst;
	output MemRead;
	output MemWrite;
	output [1:0] MemtoReg;
	output ALUSrc1;
	output ALUSrc2;
	output ExtOp;
	output LuOp;
	output [5:0] ALUFun;
	output Sign;
	wire XADR;
	wire ILLOP;
	wire exception;
	
	assign exception = 
		~(OpCode == 6'h23 || OpCode == 6'h2b || OpCode == 6'h0f || OpCode == 6'h08 || OpCode == 6'h09 || OpCode == 6'h0c || OpCode == 6'h20 ||
		OpCode == 6'h0a || OpCode == 6'h0b || OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01 || OpCode == 6'h02 || OpCode == 6'h03 ||
		(OpCode == 6'h00 && (Funct == 6'h00 || Funct == 6'h02 || Funct == 6'h03 || Funct == 6'h22 || Funct == 6'h23 || Funct == 6'h08 || Funct == 6'h09 || Funct == 6'h20 || 
		Funct == 6'h21 || Funct == 6'h24 || Funct == 6'h25 || Funct == 6'h26 || Funct == 6'h27 || Funct == 6'h2a || Funct == 6'h2b)));
	assign XADR = (~PC_31)&exception;
	assign ILLOP = (~PC_31)&IRQ;
	
	assign PCSrc[2:0] = 
		(ILLOP)? 3'b100:
		(XADR)? 3'b101:
		(OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01)? 3'b001:
		(OpCode == 6'h02 || OpCode == 6'h03)? 3'b010:
		(OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09))? 3'b011:3'b000;        //ILLOP & XADR 
		
	assign RegWrite = 
		(ILLOP)?1:
		(OpCode == 6'h2b || OpCode == 6'h04 || OpCode == 6'h02 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01)? 0:
		(OpCode == 6'h00 && Funct == 6'h08)? 0: 1;
		
	assign RegDst[1:0] =
		(ILLOP || XADR)? 2'b11:                                            //ILLOP: IRQ信号控制？
		(OpCode == 6'h00)? 2'b00:
		(OpCode == 6'h03)? 2'b10: 2'b01;                         //XADR: regdst=2'b11 溢出？未定义指令？
		
	assign MemRead = (OpCode == 6'h23)? 1: 0;
	assign MemWrite = (OpCode == 6'h2b)? 1: 0;	
	assign MemtoReg = 
	  (ILLOP || exception)? 2'b10:
		(OpCode == 6'h23)? 2'b01:
		(OpCode == 6'h03 || OpCode == 6'h20)? 2'b10:
		(OpCode == 6'h00 && Funct == 6'h09)? 2'b10: 2'b00;	
		
	assign ALUSrc1 = (OpCode == 6'h00 && (Funct == 6'h00 || Funct == 6'h02 || Funct == 6'h03))? 1:0;
	assign ALUSrc2 = (OpCode == 6'h00 || OpCode == 6'h04 || OpCode == 6'h05 || OpCode == 6'h06 || OpCode == 6'h07 || OpCode == 6'h01)? 0:1;
	assign ExtOp = (OpCode == 6'h0c)? 0:1;
	assign LuOp = (OpCode == 6'h0f)? 1:0;
	assign Sign = 
		(OpCode == 6'h09 || OpCode == 6'h0b)? 0:
		(OpCode == 6'h00 && (Funct == 6'h2b || Funct == 6'h05 || Funct == 6'h21))? 0:1;
		
	assign ALUFun[5:0] =
		(OpCode == 6'h0f || (OpCode == 6'h00 && Funct == 6'h25))? 6'b011110:                    //lui or
		(OpCode == 6'h00 && (Funct == 6'h22 || Funct == 6'h23))? 6'b000001:                     //sub subu
		(OpCode == 6'h0c || (OpCode == 6'h00 && Funct == 6'h24))? 6'b011000:                    //and andi
		(OpCode == 6'h00 && Funct == 6'h26)? 6'b010110:                                         //xor
		(OpCode == 6'h00 && Funct == 6'h27)? 6'b010001:                                         //nor
		(OpCode == 6'h00 && Funct == 6'h00)? 6'b100000:                                         //sll
		(OpCode == 6'h00 && Funct == 6'h02)? 6'b100001:                                         //srl
		(OpCode == 6'h00 && Funct == 6'h03)? 6'b100011:                                         //sra
		(OpCode == 6'h0a || OpCode == 6'h0b || (OpCode == 6'h00 && (Funct == 6'h2a || Funct == 6'h2b)))? 6'b110101:  //slt slti sltiu sltu
		(OpCode == 6'h04)? 6'b110011:                                                           //beq
		(OpCode == 6'h05)? 6'b110001:                                                           //bne
		(OpCode == 6'h06)? 6'b111101:                                                           //blez
		(OpCode == 6'h07)? 6'b111111:                                                           //bgtz
		(OpCode == 6'h01)? 6'b111011: 6'b000000;                                                //bltz
		
endmodule