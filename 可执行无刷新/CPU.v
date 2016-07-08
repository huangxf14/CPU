module CPU(reset, clk, switch, led, digi_out1, digi_out2, digi_out3,digi_out4, uart_rx, uart_tx);
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
// Program Counter	
	reg [31:0] PC;
	wire [31:0] PC_next;
	always @(negedge reset or posedge clk)
		if (~reset)
			PC <= 32'h80000000;
		else
			PC <= PC_next;
	
	wire [31:0] PC_plus_4;
	//PC+4
	assign PC_plus_4[30:0] = PC[30:0] + 4;  
	assign PC_plus_4[31] = PC[31];	
// Instruction memory	
	wire [31:0] Instruction;
	ROM rom1(.addr({1'b0,PC[30:0]}), .data(Instruction));
	
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
	
// Control	
	Control control1(
		.OpCode(Instruction[31:26]), .Funct(Instruction[5:0]), .IRQ(IRQ), .PC_31(PC[31]),
		.PCSrc(PCSrc), .RegWrite(RegWrite), .RegDst(RegDst), .Sign(Sign),
		.MemRead(MemRead),	.MemWrite(MemWrite), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp), .ALUFun(ALUFun));
// Register File	
	wire [31:0] Databus1, Databus2, Databus3;
	wire [4:0] Write_register;
	assign Write_register = (RegDst == 2'b00)? Instruction[15:11]: (RegDst == 2'b01)? Instruction[20:16]: (RegDst == 2'b10)? 5'd31: 5'd26;
	RegFile RegFile1(.reset(reset), .clk(clk), .wr(RegWrite), 
		.addr1(Instruction[25:21]), .addr2(Instruction[20:16]), .addr3(Write_register),
		.data3(Databus3), .data1(Databus1), .data2(Databus2));
// Extension 16-32	
	wire [31:0] Ext_out;
	assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};
// lui
	wire [31:0] LU_out;
	assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;

// ALU	
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [31:0] ALU_out;
	wire Zero;
	assign ALU_in1 = ALUSrc1? {27'h00000, Instruction[10:6]}: Databus1;
	assign ALU_in2 = ALUSrc2? LU_out: Databus2;
	ALU alu1(.A(ALU_in1), .B(ALU_in2), .ALUFun(ALUFun), .Sign(Sign), .Z(ALU_out));
// Data Memory	
  wire [31:0] Read_data;
	wire [31:0] Read_data1;
	wire DataMemWr; 
	wire DataMemRd;
	assign DataMemWr = (~ALU_out[30]) & MemWrite;    //less than 32'h40000000
	assign DataMemRd = (~ALU_out[30]) & MemRead;     //
	DataMem DataMem1(.reset(reset), .clk(clk), .addr(ALU_out), .wdata(Databus2), .rdata(Read_data1), .rd(DataMemRd), .wr(DataMemWr));
	assign Databus3 = (MemtoReg == 2'b00)? ALU_out: (MemtoReg == 2'b01)? Read_data: PC_plus_4;	
//UART
	wire [7:0] tx_data;
	wire tx_en;
	wire tx_status;
	wire [7:0] rx_data;
	wire rx_status;
	wire baudclk;
	timebaudclk timebaudclk1(.sysclk(clk), .reset(reset), .baudclk(baudclk));
	uart_receiver uart_receiver1(.uart_rx(uart_rx), .reset(reset), .baudclk(baudclk), .rx_data(rx_data), .rx_status(rx_status), .clk(clk));
	uart_sender uart_sender1(.uart_tx(uart_tx), .baudclk(baudclk), .reset(reset), .tx_data(tx_data), .tx_en(tx_en), .tx_status(tx_status));
// led, switch, digi,IRQ
	wire PeriWr;
	wire PeriRd;
	wire [31:0] Read_data2;
	assign PeriWr = (ALU_out[30]) & MemWrite;   //the peripheral addr is 32'h4xxxxxxx
	assign PeriRd = (ALU_out[30]) & MemRead;
	Peripheral Peripheral1(.reset(reset), .clk(clk), .rd(MemRead), .wr(MemWrite), .addr(ALU_out), .wdata(Databus2), .rdata(Read_data2), .led(led), .switch(switch), .digi(digi), .irqout(IRQ), .tx_en(tx_en), .tx_status(tx_status), .rx_status(rx_status), .rx_data(rx_data), .tx_data(tx_data));	//
	assign Read_data = (ALU_out[30])? Read_data2: Read_data1;
// led
	digitube_scan digitube_scan1(.digi_in(digi), .digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3), .digi_out4(digi_out4));
	
// J
	wire [31:0] Jump_target;
	assign Jump_target = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
// branch
	wire [31:0] Branch_target;
	assign Branch_target = (ALU_out[0])? PC_plus_4 + {Ext_out[29:0], 2'b00}: PC_plus_4;
// PC Source	
	assign PC_next = 
		(PCSrc == 3'b000)? PC_plus_4:
		(PCSrc == 3'b001)? Branch_target: 
		(PCSrc == 3'b010)? Jump_target:
		(PCSrc == 3'b011)? Databus1:
		(PCSrc == 3'b100)? ILLOP:
		(PCSrc == 3'b101)? XADR: 32'h80000000;

endmodule
	