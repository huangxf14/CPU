`timescale 1ns/1ns

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,tx_en,tx_status,rx_status,rx_data,tx_data);
input reset,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;

reg [31:0] TH,TL;
reg [2:0] TCON;
assign irqout = TCON[2];

input rx_status;
input tx_status;
input [7:0] rx_data;
output wire [7:0] tx_data;
output reg tx_en;
reg [2:0] UART_CON;
reg [7:0] UART_TXD;
reg [7:0] UART_RXD;
reg read;
reg [8:0] cnt;

always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,UART_TXD};
			32'h4000001c: begin
				rdata <= {24'b0,UART_RXD};
			//	read <= 1;
			end
			32'h40000020: rdata <= {29'b0,UART_CON};
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;
		tx_en <= 1'b0;
		led <= 8'b0;
		digi <= 12'b0;
		UART_RXD <= 8'b0;
		UART_TXD <= 8'b0;
		UART_CON <= 3'b0;
		cnt <= 9'b0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
	//	if(read)
	//		UART_CON[2] <= 1;
		if(rx_status) begin           // TO ensure the former data is read by CPU
			UART_RXD <= rx_data;
	//		UART_CON[2] <= 0;
			if(UART_CON[0])
				UART_CON[1] <= 1;
			else
				UART_CON[0] <= 1;
		end
		
		if(tx_en) begin
			if(cnt == 9'd326)
				begin tx_en <= 1'b0; end
			else
				cnt <= cnt+1;
		end
		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
				32'h40000018: 
					begin
						UART_TXD <= wdata[7:0];
						if(tx_status)
							tx_en <= 1'b1;
						else
							tx_en <= 1'b0;
						cnt <= 9'b0;
					end
				32'h40000020: UART_CON <= wdata[2:0];
				default: ;
			endcase
		end
	end
end
assign tx_data = UART_TXD;
endmodule

