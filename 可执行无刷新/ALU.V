module ALU(A,B,ALUFun,Sign,Z);
	input [31:0] A;
	input [31:0] B;
	input [5:0] ALUFun;
	input Sign;
	output reg [31:0] Z;
	reg Z0,V,N;
	wire Co;
	reg [32:0] S00;
	wire [31:0] S01, S10, S11;
	reg [31:0] neg;
	reg [31:0] cmp;
	reg [31:0] log;
	wire [31:0] shamt8;
	wire [31:0] shamt4;
	wire [31:0] shamt2;
	wire [31:0] shamt1;

	always @ (*) 
	begin
	  if(~ALUFun[0])  
	  begin 
		  S00 <= A + B;
	  end
	  else       
	  begin
		  neg <= ~B + 1;
		  S00 <= A + neg;
	  end
	  if(Sign)  
	  begin
		  if(S00[31])  
		  begin
		    if(A[31]==1'b0&&neg[31]==1'b0)
		    begin V<=1; N<=0; end            
		    else
		    begin V<=0; N<=1; end
		  end
		  else       
		  begin
		    if(A[31]==1'b1&&neg[31]==1'b1)
		    begin V<=1; N<=1; end             
		    else
		    begin V<=0; N<=0; end
		  end
	  end
	  else   
	  begin
		  if(~ALUFun[0])   
		  begin
		    if(S00[32]) V<=1;    
		    else V<=0;
		    N<=0;          
		  end
		  else         
		  begin
		    if(~S00[32]) 
		    begin V<=1;N<=1; end 
		    else
		    begin V<=0;N<=0; end 
		  end
	  end 
	  Z0<=~(|S00[31:0]);    
	end
	//compare
	always @(*)
		case(ALUFun[3:1])
			3'b000:cmp <= {31'h0000000,~Z0};   //NEQ
			3'b001:cmp <= {31'h0000000,Z0};   //EQ
			3'b010:cmp <= {31'h0000000,N};    //LT
			3'b110:cmp <= {31'h0000000,N|Z0}; //LEZ
			3'b101:cmp <= {31'h0000000,N};    //LTZ
			3'b111:cmp <= {31'h0000000,~(N|Z0)}; //GTZ
			default:cmp <= 32'h0000000;
		endcase
	assign S11=cmp;
	//shift
	assign shamt1 = (A[0])?(ALUFun[0]?{(ALUFun[1]?B[31]:1'b0),B[31:1]}:{B[30:0],1'b0}):B;
	assign shamt2 = (A[1])?(ALUFun[0]?{ALUFun[1]?{2{shamt1[31]}}:2'b0,shamt1[31:2]}:{shamt1[29:0],2'b0}):shamt1;
	assign shamt4 = (A[2])?(ALUFun[0]?{ALUFun[1]?{4{shamt2[31]}}:4'b0,shamt2[31:4]}:{shamt2[27:0],4'b0}):shamt2;
	assign shamt8 = (A[3])?(ALUFun[0]?{ALUFun[1]?{8{shamt4[31]}}:8'b0,shamt4[31:8]}:{shamt4[23:0],8'b0}):shamt4;
	assign S10 = (A[4])?(ALUFun[0]?{ALUFun[1]?{16{shamt8[31]}}:16'b0,shamt8[31:16]}:{shamt8[15:0],16'b0}):shamt8;
	//logic
	always @(*) begin
		case(ALUFun[3:0])
			4'b1000: log<=A&B;
			4'b1110: log<=A|B;
			4'b0110: log<=A^B;
			4'b0001: log<=~(A|B);
			4'b1010: log<=A;
		endcase
	end
	assign S01=log;
	
	always@ (*)
	begin
	  case(ALUFun[5:4])
		2'b00:Z=S00[31:0];
		2'b01:Z=S01;
		2'b10:Z=S10;
		2'b11:Z=S11;
	  endcase
	end
endmodule