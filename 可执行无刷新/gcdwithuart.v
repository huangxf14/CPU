`timescale 1ns/1ns

module ROM (addr,data);
input [31:0] addr;
output [31:0] data;
reg [31:0] data;
localparam ROM_SIZE = 256;
reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
	case(addr[9:2])	//Address Must Be Word Aligned.
8'd0: data <= 32'h03e00008 ;
8'd1: data <= 32'h08100041 ;
8'd2: data <= 32'h03400008 ;
8'd3: data <= 32'h3c114000 ;
8'd4: data <= 32'h3c104000 ;
8'd5: data <= 32'h22100018 ;
8'd6: data <= 32'h8e090008 ;
8'd7: data <= 32'h31290001 ;
8'd8: data <= 32'h1120fffd ;
8'd9: data <= 32'h8e040004 ;
8'd10: data <= 32'h8e090008 ;
8'd11: data <= 32'h31290002 ;
8'd12: data <= 32'h1120fffd ;
8'd13: data <= 32'h8e050004 ;
8'd14: data <= 32'h3088000f ;
8'd15: data <= 32'h21060100 ;
8'd16: data <= 32'h0c10006d ;
8'd17: data <= 32'h00c0a020 ;
8'd18: data <= 32'h00044102 ;
8'd19: data <= 32'h3108000f ;
8'd20: data <= 32'h21060200 ;
8'd21: data <= 32'h0c10006d ;
8'd22: data <= 32'h00c0a820 ;
8'd23: data <= 32'h30a8000f ;
8'd24: data <= 32'h21060400 ;
8'd25: data <= 32'h0c10006d ;
8'd26: data <= 32'h00c0b020 ;
8'd27: data <= 32'h00054102 ;
8'd28: data <= 32'h3108000f ;
8'd29: data <= 32'h21060800 ;
8'd30: data <= 32'h0c10006d ;
8'd31: data <= 32'h00c0b820 ;
8'd32: data <= 32'h0085602a ;
8'd33: data <= 32'h11800003 ;
8'd34: data <= 32'h00a06020 ;
8'd35: data <= 32'h00a46822 ;
8'd36: data <= 32'h08100027 ;
8'd37: data <= 32'h00806020 ;
8'd38: data <= 32'h00856822 ;
8'd39: data <= 32'h11a00009 ;
8'd40: data <= 32'h018d7022 ;
8'd41: data <= 32'h01ae782a ;
8'd42: data <= 32'h11e00003 ;
8'd43: data <= 32'h01c06020 ;
8'd44: data <= 32'h01a06820 ;
8'd45: data <= 32'h08100027 ;
8'd46: data <= 32'h01a06020 ;
8'd47: data <= 32'h01c06820 ;
8'd48: data <= 32'h08100027 ;
8'd49: data <= 32'h01801020 ;
8'd50: data <= 32'hae22000c ;
8'd51: data <= 32'hae020000 ;
8'd52: data <= 32'hae000008 ;
8'd53: data <= 32'h00009020 ;
8'd54: data <= 32'h20130004 ;
8'd55: data <= 32'hae200008 ;
8'd56: data <= 32'h3c08ffff ;
8'd57: data <= 32'h00084383 ;
8'd58: data <= 32'hae280000 ;
8'd59: data <= 32'h3c09ffff ;
8'd60: data <= 32'h00094c03 ;
8'd61: data <= 32'h200a0003 ;
8'd62: data <= 32'hae290004 ;
8'd63: data <= 32'hae2a0008 ;
8'd64: data <= 32'h0c100040 ;
8'd65: data <= 32'h8e2a0008 ;
8'd66: data <= 32'h216a0009 ;
8'd67: data <= 32'h016a6024 ;
8'd68: data <= 32'h23bdfffc ;
8'd69: data <= 32'hae2c0008 ;
8'd70: data <= 32'hafba0000 ;
8'd71: data <= 32'h22520001 ;
8'd72: data <= 32'h16530001 ;
8'd73: data <= 32'h00009020 ;
8'd74: data <= 32'h12400006 ;
8'd75: data <= 32'h20190001 ;
8'd76: data <= 32'h1259000b ;
8'd77: data <= 32'h20190002 ;
8'd78: data <= 32'h12590010 ;
8'd79: data <= 32'h20190003 ;
8'd80: data <= 32'h12590015 ;
8'd81: data <= 32'hae340014 ;
8'd82: data <= 32'h8fba0000 ;
8'd83: data <= 32'h8e2c0008 ;
8'd84: data <= 32'h20180002 ;
8'd85: data <= 32'h23bd0004 ;
8'd86: data <= 32'h01986025 ;
8'd87: data <= 32'h03400008 ;
8'd88: data <= 32'hae350014 ;
8'd89: data <= 32'h8fba0000 ;
8'd90: data <= 32'h8e2c0008 ;
8'd91: data <= 32'h20180002 ;
8'd92: data <= 32'h23bd0004 ;
8'd93: data <= 32'h01986025 ;
8'd94: data <= 32'h03400008 ;
8'd95: data <= 32'hae360014 ;
8'd96: data <= 32'h8fba0000 ;
8'd97: data <= 32'h8e2c0008 ;
8'd98: data <= 32'h20180002 ;
8'd99: data <= 32'h23bd0004 ;
8'd100: data <= 32'h01986025 ;
8'd101: data <= 32'h03400008 ;
8'd102: data <= 32'hae370014 ;
8'd103: data <= 32'h8fba0000 ;
8'd104: data <= 32'h8e2c0008 ;
8'd105: data <= 32'h20180002 ;
8'd106: data <= 32'h23bd0004 ;
8'd107: data <= 32'h01986025 ;
8'd108: data <= 32'h03400008 ;
8'd109: data <= 32'h30d8000f ;
8'd110: data <= 32'h20190000 ;
8'd111: data <= 32'h1319001e ;
8'd112: data <= 32'h20190001 ;
8'd113: data <= 32'h1319001e ;
8'd114: data <= 32'h20190002 ;
8'd115: data <= 32'h1319001e ;
8'd116: data <= 32'h20190003 ;
8'd117: data <= 32'h1319001e ;
8'd118: data <= 32'h20190004 ;
8'd119: data <= 32'h1319001e ;
8'd120: data <= 32'h20190005 ;
8'd121: data <= 32'h1319001e ;
8'd122: data <= 32'h20190006 ;
8'd123: data <= 32'h1319001e ;
8'd124: data <= 32'h20190007 ;
8'd125: data <= 32'h1319001e ;
8'd126: data <= 32'h20190008 ;
8'd127: data <= 32'h1319001e ;
8'd128: data <= 32'h20190009 ;
8'd129: data <= 32'h1319001e ;
8'd130: data <= 32'h2019000a ;
8'd131: data <= 32'h1319001e ;
8'd132: data <= 32'h2019000b ;
8'd133: data <= 32'h1319001e ;
8'd134: data <= 32'h2019000c ;
8'd135: data <= 32'h1319001e ;
8'd136: data <= 32'h2019000d ;
8'd137: data <= 32'h1319001e ;
8'd138: data <= 32'h2019000e ;
8'd139: data <= 32'h1319001e ;
8'd140: data <= 32'h2019000f ;
8'd141: data <= 32'h1319001e ;
8'd142: data <= 32'h20c60040 ;
8'd143: data <= 32'h03e00008 ;
8'd144: data <= 32'h20c60078 ;
8'd145: data <= 32'h03e00008 ;
8'd146: data <= 32'h20c60022 ;
8'd147: data <= 32'h03e00008 ;
8'd148: data <= 32'h20c6002d ;
8'd149: data <= 32'h03e00008 ;
8'd150: data <= 32'h20c60015 ;
8'd151: data <= 32'h03e00008 ;
8'd152: data <= 32'h20c6000d ;
8'd153: data <= 32'h03e00008 ;
8'd154: data <= 32'h20c6fffc ;
8'd155: data <= 32'h03e00008 ;
8'd156: data <= 32'h20c60071 ;
8'd157: data <= 32'h03e00008 ;
8'd158: data <= 32'h20c6fff8 ;
8'd159: data <= 32'h03e00008 ;
8'd160: data <= 32'h20c60007 ;
8'd161: data <= 32'h03e00008 ;
8'd162: data <= 32'h20c6fffe ;
8'd163: data <= 32'h03e00008 ;
8'd164: data <= 32'h20c6fff8 ;
8'd165: data <= 32'h03e00008 ;
8'd166: data <= 32'h20c6003a ;
8'd167: data <= 32'h03e00008 ;
8'd168: data <= 32'h20c60014 ;
8'd169: data <= 32'h03e00008 ;
8'd170: data <= 32'h20c6fff8 ;
8'd171: data <= 32'h03e00008 ;
8'd172: data <= 32'h20c6ffff ;
8'd173: data <= 32'h03e00008 ;


	  default:	data <= 32'h0800_0000;
	endcase
endmodule