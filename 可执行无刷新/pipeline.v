`timescale 1ns/1ns

module pipeline(clk, reset, switch, led, digi_out1, digi_out2, digi_out3,digi_out4, uart_rx, uart_tx);
	input reset, clk;
	input [7:0] switch;
	input uart_rx;	
	output [7:0] led;
	output [6:0] digi_out1;
	output [6:0] digi_out2;
	output [6:0] digi_out3;
	output [6:0] digi_out4;
	output uart_tx;
	wire [11:0] digi;

	
	parameter ILLOP = 32'h80000004;
	parameter XADR = 32'h80000008;
	
	// ---IF---
	// PCIF
	wire PCwrite;
	wire [31:0] PC;
	wire [31:0] PC_next;
	PC_IF PCIF(.clk(clk),.reset(reset),.PCwrite(PCwrite),.PC_in(PC_next),.PC_out(PC));
	// Instruction Memory
	wire [31:0] Instruction;
	ROM rom1(.addr({1'b0,PC[30:0]}), .data(Instruction));
	// PC+4
	wire [31:0] PC_plus_4;
	assign PC_plus_4[30:0] = PC[30:0] + 4;  
	assign PC_plus_4[31] = PC[31];
	
	// ---ID---
	// IFtoID
	wire IFDWrite,IFD_Flush;
  wire [31:0] PC_plus_4_out;
  wire [31:0] Instruction_out;
  IFtoID IF2ID(.clk(clk),.reset(reset),
              .IFDWrite(IFDWrite),.IFD_Flush(IFD_Flush),
              .PCadd4_in(PC_plus_4),.PCadd4_out(PC_plus_4_out),
              .instruction_in(Instruction),.instruction_out(Instruction_out));
  // control
	wire [1:0] RegDst;
	wire [2:0] PCSrc;
	wire MemRead;
	wire [1:0] MemtoReg;
	wire [5:0] ALUFun;
	wire ExtOp;
	wire LuOp;
	wire MemWrite;
	wire ALUSrc1;
	wire ALUSrc2;
	wire RegWrite;
	wire Sign;
	wire IRQ;
	Control control1(
		.OpCode(Instruction_out[31:26]), .Funct(Instruction_out[5:0]), .IRQ(IRQ), .PC_31(PC_plus_4_out[31]),
		.PCSrc(PCSrc), .RegWrite(RegWrite), .RegDst(RegDst), .Sign(Sign),
		.MemRead(MemRead),	.MemWrite(MemWrite), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp), .ALUFun(ALUFun));	
	
	// Register File
	wire [31:0] DatabusA, DatabusB, DatabusC;
	wire [4:0] Write_addr;  //decided later in EX site
	wire RegWrite_MEMWB;   //MEMtoWB
	RegFile RegFile1(.reset(reset), .clk(clk), .wr(RegWrite_MEMWB), 
		.addr1(Instruction_out[25:21]), .addr2(Instruction_out[20:16]), .addr3(Write_addr),
		.data3(DatabusC), .data1(DatabusA), .data2(DatabusB));
  // Extension 16-32	
	wire [31:0] Ext_out;
	assign Ext_out = {ExtOp? {16{Instruction_out[15]}}: 16'h0000, Instruction_out[15:0]};
	// lui
	wire [31:0] LU_out;
	assign LU_out = LuOp? {Instruction_out[15:0], 16'h0000}: Ext_out;
	// J_target
	wire [31:0] Jump_target;
	assign Jump_target = {PC_plus_4_out[31:28], Instruction_out[25:0], 2'b00};
	// compare
	wire compareAB;
	compare compare1(.DatabusA(DatabusA),.DatabusB(DatabusB),.Inst3126(Instruction_out[31:26]),.compareAB(compareAB));	
  // branch-ComBA
	wire [31:0] Branch_target;
	assign Branch_target = (compareAB)? PC_plus_4_out + {Ext_out[29:0], 2'b00}: PC_plus_4_out;
	
	// PC Source	
	// should it run at ID round?
	assign PC_next = 
		(PCSrc == 3'b000)? PC_plus_4:
		(PCSrc == 3'b001)? Branch_target: 
		(PCSrc == 3'b010)? Jump_target:
		(PCSrc == 3'b011)? DatabusA:
		(PCSrc == 3'b100)? ILLOP:
		(PCSrc == 3'b101)? XADR: 32'h80000000;
	
	// ---EX---
	// IDtoEX
	wire IDEX_Flush;
	wire [1:0] RegDst_IDEX;
	wire MemRead_IDEX;
	wire [1:0] MemtoReg_IDEX;
	wire [5:0] ALUFun_IDEX;
	wire MemWrite_IDEX;
	wire ALUSrc1_IDEX;
	wire ALUSrc2_IDEX;
	wire RegWrite_IDEX;
	wire Sign_IDEX;
	wire [31:0] DatabusA_IDEXout,DatabusB_IDEXout,LU_IDEX_out,PC_plus_4_IDEX;
	wire [4:0] ID2EX_rs_out,ID2EX_rt_out,ID2EX_rd_out,Shamt;
	IDtoEX ID2EX(.clk(clk),.reset(reset),.IDEX_Flush(IDEX_Flush),.PCadd4_in(PC_plus_4_out),.PCadd4_out(PC_plus_4_IDEX),
              .RegDst_in(RegDst),.ALUSrc1_in(ALUSrc1),.ALUSrc2_in(ALUSrc2),.Sign_in(Sign),.ALUFun_in(ALUFun),    //EX
              .MemRead_in(MemRead),.MemWrite_in(MemWrite),                               //MEM
              .MemtoReg_in(MemtoReg),.RegWrite_in(RegWrite),                              //WB
              .ID2EX_rsContent_in(DatabusA),.ID2EX_rtContent_in(DatabusB),
              .ID2EX_rs_in(Instruction_out[25:21]),.ID2EX_rt_in(Instruction_out[20:16]),.ID2EX_rd_in(Instruction_out[15:11]),.Shamt_in(Instruction_out[10:6]),.imm32_in(LU_out),
              .RegDst_out(RegDst_IDEX),.ALUSrc1_out(ALUSrc1_IDEX),.ALUSrc2_out(ALUSrc2_IDEX),.Sign_out(Sign_IDEX),.ALUFun_out(ALUFun_IDEX),    //EX
              .MemRead_out(MemRead_IDEX),.MemWrite_out(MemWrite_IDEX),                               //MEM
              .MemtoReg_out(MemtoReg_IDEX),.RegWrite_out(RegWrite_IDEX),                              //WB 
              .ID2EX_rsContent_out(DatabusA_IDEXout),.ID2EX_rtContent_out(DatabusB_IDEXout),
              .ID2EX_rs_out(ID2EX_rs_out),.ID2EX_rt_out(ID2EX_rt_out),.ID2EX_rd_out(ID2EX_rd_out),.Shamt_out(Shamt),.imm32_out(LU_IDEX_out));
  // Write Addr-->EXtoMEM and MEMtoWB 's rd
  wire [4:0] Write_addr_EX;
  assign Write_addr_EX = (RegDst_IDEX == 2'b00)? ID2EX_rd_out: (RegDst_IDEX == 2'b01)? ID2EX_rt_out: (RegDst_IDEX == 2'b10)? 5'd31: 5'd26;
	
	// hazard(ID)
	hazard hazard_unit(.IDtoEX_RegRt(ID2EX_rt_out),.IDtoEX_MemRead(MemRead_IDEX),.IFtoID_RegRs(Instruction_out[25:21]),.IFtoID_RegRt(Instruction_out[20:16]),
         .PCWrite(PCwrite),.IFDWrite(IFDWrite),.IFD_Flush(IFD_Flush),.IDEX_Flush(IDEX_Flush),.PCSrc(PCSrc));
         
  // ALU 
  wire [31:0] ALU_in1,ALU_in11;
	wire [31:0] ALU_in2,ALU_in22;
	wire [31:0] ALU_out;
	wire [31:0] ALU_out_EXMEM;     //EXtoMEM
	wire [1:0] ForwardA,ForwardB;   //forwarding unit
  assign ALU_in11 = (ForwardA==2'b00)? DatabusA_IDEXout:
                    (ForwardA==2'b01)? DatabusC:
                    (ForwardA==2'b10)? ALU_out_EXMEM: DatabusA_IDEXout;   //2'b11=?  take it same as 2'b00...?
	assign ALU_in22 = (ForwardB==2'b00)? DatabusB_IDEXout:
	                  (ForwardB==2'b01)? DatabusC:
	                  (ForwardB==2'b10)? ALU_out_EXMEM: DatabusB_IDEXout;   //2'b11=?
	assign ALU_in1 = ALUSrc1_IDEX? {27'h00000, Shamt}: ALU_in11;
	assign ALU_in2 = ALUSrc2_IDEX? LU_IDEX_out: ALU_in22;
	ALU alu1(.A(ALU_in1), .B(ALU_in2), .ALUFun(ALUFun_IDEX), .Sign(Sign_IDEX), .Z(ALU_out));
	
	// ---MEM---
	// EXtoMEM
	wire MemRead_EXMEM,MemWrite_EXMEM,RegWrite_EXMEM;
	wire [1:0] MemtoReg_EXMEM;
	wire [31:0] ALU_in22_EXMEM,PC_plus_4_EXMEM;
	wire [4:0] EX2MEM_rd_out,Write_addr_EXMEM;
  EXtoMEM EX2MEM(.clk(clk),.reset(reset),.PCadd4_in(PC_plus_4_IDEX),.PCadd4_out(PC_plus_4_EXMEM),
               .MemRead_in(MemRead_IDEX),.MemWrite_in(MemWrite_IDEX),                               //MEM
               .MemtoReg_in(MemtoReg_IDEX),.RegWrite_in(RegWrite_IDEX),                              //WB
               .ALUout_in(ALU_out),.EX2MEM_rd_in(Write_addr_EX),.EX2MEM_regB_in(ALU_in22),
               .MemRead_out(MemRead_EXMEM),.MemWrite_out(MemWrite_EXMEM),                               //MEM
               .MemtoReg_out(MemtoReg_EXMEM),.RegWrite_out(RegWrite_EXMEM),                              //WB
               .ALUout_out(ALU_out_EXMEM),.EX2MEM_rd_out(EX2MEM_rd_out),.EX2MEM_regB_out(ALU_in22_EXMEM));
  
  // Data Memory
  wire [31:0] Read_data;
	wire [31:0] Read_data1;
	wire DataMemWr; 
	wire DataMemRd;
	assign DataMemWr = (~ALU_out_EXMEM[30]) & MemWrite_EXMEM;    //less than 32'h40000000
	assign DataMemRd = (~ALU_out_EXMEM[30]) & MemRead_EXMEM;     //
	DataMem data_memory1(.reset(reset), .clk(clk), .addr(ALU_out_EXMEM), .wdata(ALU_in22_EXMEM), .rdata(Read_data1), .rd(DataMemRd), .wr(DataMemWr));
	
	// led, switch, digi,IRQ (MEM)(O.E)
	wire [31:0] Read_data2;
	wire [7:0] tx_data;
	wire tx_en;
	wire tx_status;
	wire [7:0] rx_data;
	wire rx_status;
	Peripheral Peripheral1(.reset(reset), .clk(clk), .rd(MemRead_EXMEM), .wr(MemWrite_EXMEM), .addr(ALU_out_EXMEM), .wdata(ALU_in22_EXMEM), 
	                       .rdata(Read_data2), .led(led), .switch(switch), .digi(digi), .irqout(IRQ), 
	                       .tx_en(tx_en), .tx_status(tx_status), .rx_status(rx_status), .rx_data(rx_data), .tx_data(tx_data));
	assign Read_data = (ALU_out[30])? Read_data2: Read_data1;
  
  // ---WB---
  // MEMtoWB
  wire [1:0] MemtoReg_MEMWB;
  wire [31:0] ALU_out_MEMWB,Read_data_MEMWB,PC_plus_4_MEMWB;
  wire [4:0] MEM2WB_rd_out;
  MEMtoWB MEM2WB(.clk(clk),.reset(reset),.PCadd4_in(PC_plus_4_EXMEM),.PCadd4_out(PC_plus_4_MEMWB),
               .MemtoReg_in(MemtoReg_EXMEM),.RegWrite_in(RegWrite_EXMEM),           //WB
               .ALUout_in(ALU_out_EXMEM),.MEMData_in(Read_data),.MEM2WB_rd_in(EX2MEM_rd_out),
               .MemtoReg_out(MemtoReg_MEMWB),.RegWrite_out(RegWrite_MEMWB),           //WB
               .ALUout_out(ALU_out_MEMWB),.MEMData_out(Read_data_MEMWB),.MEM2WB_rd_out(MEM2WB_rd_out));
  assign DatabusC = (MemtoReg_MEMWB == 2'b00)? ALU_out_MEMWB: (MemtoReg == 2'b01)? Read_data_MEMWB: PC_plus_4_MEMWB;
  assign Write_addr = MEM2WB_rd_out;
  
  // Forwarding unit(EX)
  Forwarding_unit forwardingunit1(.EXtoMEM_RegWrite(RegWrite_EXMEM),.MEMtoWB_RegWrite(RegWrite_MEMWB),
                                  .EXtoMEM_RegRd(EX2MEM_rd_out),.MEMtoWB_RegRd(MEM2WB_rd_out),
                                  .IDtoEX_RegRs(ID2EX_rs_out),.IDtoEX_RegRt(ID2EX_rt_out),
                                  .ForwardA(ForwardA),.ForwardB(ForwardB));	  
  //outer equipment                                
  //UART
	wire baudclk;
	timebaudclk timebaudclk1(.sysclk(clk), .reset(reset), .baudclk(baudclk));
	uart_receiver uart_receiver1(.uart_rx(uart_rx), .reset(reset), .baudclk(baudclk), .rx_data(rx_data), .rx_status(rx_status),.clk(clk));
	uart_sender uart_sender1(.uart_tx(uart_tx), .baudclk(baudclk), .reset(reset), .tx_data(tx_data), .tx_en(tx_en), .tx_status(tx_status));                                 
  // led
	digitube_scan digitube_scan1(.digi_in(digi), .digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3), .digi_out4(digi_out4));	
	
endmodule