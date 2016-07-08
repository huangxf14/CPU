module timebaudclk(sysclk,reset,baudclk);
  input sysclk;
  input reset;
  output baudclk;
  reg baudclk;
  reg [7:0] count;
  
  always@(posedge sysclk or negedge reset) begin
    if(~reset) begin
      count<=8'b0;
      baudclk<=1'b0;
    end
    else begin
      if(count==163)
        begin
          baudclk<=~baudclk;
          count<=0;
        end
      else
        count<=count+1'b1;
    end
  end
endmodule