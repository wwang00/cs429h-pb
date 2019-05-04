module ppm_decoder_test(RAW_CLK, RST, PPM, SW, LED, LED_PPM);

input logic RAW_CLK;
input logic RST;
input logic PPM;
input logic [4:0] SW;
output logic [15:0] LED = 16'h0000;
output logic LED_PPM = 1;

logic clk = 0;
logic [31:0] clk_ctr = 31'b0;

logic [15:0] ch [0:12];
logic [3:0] disp_ch = 4'b0;

ppm_decoder decoder(clk, RST, PPM, ch);

always @(posedge clk) begin
	if(SW[4]) begin
		disp_ch <= 5;
	end else if(SW[3]) begin
		disp_ch <= 4;
	end else if(SW[2]) begin
		disp_ch <= 3;
	end else if(SW[1]) begin
		disp_ch <= 2;
	end else if(SW[0]) begin
		disp_ch <= 1;
	end else begin
		disp_ch <= 0;
	end
	LED[0] <= ch[disp_ch] > 0 ? 1 : 0;
	LED[1] <= ch[disp_ch] > 63 ? 1 : 0;
	LED[2] <= ch[disp_ch] > 125 ? 1 : 0;
	LED[3] <= ch[disp_ch] > 188 ? 1 : 0;
	LED[4] <= ch[disp_ch] > 250 ? 1 : 0;
	LED[5] <= ch[disp_ch] > 313 ? 1 : 0;
	LED[6] <= ch[disp_ch] > 375 ? 1 : 0;
	LED[7] <= ch[disp_ch] > 438 ? 1 : 0;
	LED[8] <= ch[disp_ch] > 500 ? 1 : 0;
	LED[9] <= ch[disp_ch] > 563 ? 1 : 0;
	LED[10] <= ch[disp_ch] > 625 ? 1 : 0;
	LED[11] <= ch[disp_ch] > 688 ? 1 : 0;
	LED[12] <= ch[disp_ch] > 750 ? 1 : 0;
	LED[13] <= ch[disp_ch] > 813 ? 1 : 0;
	LED[14] <= ch[disp_ch] > 875 ? 1 : 0;
	LED[15] <= ch[disp_ch] > 938 ? 1 : 0;
end

always @(posedge PPM) begin	
	LED_PPM <= ~LED_PPM;
end

always @(posedge RAW_CLK) begin
	if(clk_ctr >= 24) begin
		clk <= ~clk;
		clk_ctr <= 31'b0;
	end else begin
		clk_ctr <= clk_ctr + 1;
	end
end

endmodule
