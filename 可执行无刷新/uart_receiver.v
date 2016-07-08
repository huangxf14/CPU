module uart_receiver(uart_rx,reset,baudclk,rx_data,rx_status,clk);
  input uart_rx;
  input clk;
  input reset;
  input baudclk;
  output reg [7:0] rx_data;
  output reg rx_status;
  reg [7:0] data;
  reg [1:0] state;
  reg [3:0] cnt;
  reg rstatus;
  reg [3:0] num;
  reg [9:0] cnt1;
  
  always @(posedge baudclk or negedge reset) begin
    if(~reset) begin
      state<=2'b0;
      rstatus<=0;
      data<=8'b0;
      cnt<=4'b0;
    end
    else begin
      case(state)
        2'b0:begin
          rstatus<=0;
          if(~uart_rx) begin
            cnt<=4'b0;
            state<=2'b01;
            num<=4'b0;
          end
        end
        2'b1:begin
          if(cnt==8 && num<=8) begin
            if(num!=4'b0) begin
              data[num-1]<=uart_rx;
            end
            cnt<=cnt+1;
            num<=num+1;
          end
          else if(cnt==8 && num==9) begin
            state<=2'b10;
            rstatus<=1;
            rx_data<=data;
          end
          else
            cnt<=cnt+1;
        end
        2'b10:begin
          state<=2'b0;
        end
      endcase
    end
  end
  
  always @(posedge clk or negedge reset) begin
    if(~reset) begin
      rx_status <= 0;
      cnt1 <= 9'd0;
    end
    else begin
      if(rstatus && ~(|cnt1))
       rx_status <= 1;
      else rx_status <= 0;
      if(rstatus)
        cnt1 <= cnt1+1;
      if(~rstatus)
        cnt1 <= 0;
    end
  end
endmodule