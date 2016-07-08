`timescale 1ns/1ns
module test_cpu();
	
	reg reset;
	reg clk;
	wire [7:0] switch;
	wire [7:0] led;
	wire [6:0] digi_out1;
	wire [6:0] digi_out2;
	wire [6:0] digi_out3;
	wire [6:0] digi_out4;
	wire uart_rx;
	wire uart_tx;
	reg [3:0] cnt;
	reg [31:0] uart_sx;

	timebaudclk B2(.sysclk(clk),.reset(reset),.baudclk(baudclk));
	CPU cpu1(.reset(reset), .clk(clk), .switch(switch), .led(led), .digi_out1(digi_out1), .digi_out2(digi_out2), .digi_out3(digi_out3), .digi_out4(digi_out4), .uart_rx(uart_rx), .uart_tx(uart_tx));
	
	initial begin
		cnt <= 4'b0;
		reset = 1;
		clk = 1;
		uart_sx<=32'b00000010_10101010_01101010_10000000;
		#5 reset = 0;
		#5 reset = 1;
	end
	always @(posedge baudclk) begin
		cnt<=cnt+1;
		if(cnt==15)
			uart_sx<=uart_sx<<1;
	end
  
	assign uart_rx=~uart_sx[31];
	always #5 clk = ~clk;
		
endmodule
