module uart_sender(uart_tx,baudclk,reset,tx_data,tx_en,tx_status);
  input baudclk;
  input [7:0] tx_data;
  input tx_en;
  input reset;  
  output reg tx_status;
  output reg uart_tx;
  reg [3:0] cnt;
  reg [3:0] num;
  reg [1:0] state;
  
  always @(posedge baudclk or negedge reset) begin
    if(~reset) begin
      tx_status<=1;
      uart_tx<=1;
      cnt<=4'b0;
      num<=4'b0;
      state<=2'b0;
    end
    else begin
      case(state)
        2'b0:begin
          tx_status<=1;
          if(tx_en) begin
            state<=1;
            tx_status<=0;
            cnt<=4'b0;
            num<=4'b0;
          end
        end
        2'b1:begin
          if(cnt==0 && num==0) begin
            uart_tx<=0;
            num<=num+1;
          end
          else if(cnt==0 && num<=8) begin
            uart_tx<=tx_data[num-1];
            num<=num+1;
          end
          else if(cnt==0 && num==9) begin
            state<=2'b10;
            uart_tx<=1;
          end
          cnt<=cnt+1;
        end
        2'b10:begin
          if(cnt==14) begin
            state<=2'b0;
         end
          cnt<=cnt+1;
        end
      endcase
    end
  end
endmodule