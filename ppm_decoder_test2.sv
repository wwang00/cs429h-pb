module ppm_decoder_test2(clk, ppm, ch, LED, LED_PPM, LED_CLK);

input logic clk;
input logic ppm;
output logic [15:0] ch [0:5] = '{default:16'b0};
output logic [15:0] LED = 16'h0000;
output logic LED_PPM = 1;
output logic LED_CLK = 1;

logic [15:0] buffer [0:12] = '{default:16'b0};
logic [15:0] ch_tmp [0:12] = '{default:16'b0};

logic [63:0] micros = 63'b0;
logic [63:0] t1 = 63'b0;
logic [63:0] dt = 63'b0;

logic [31:0] i = 32'b0;

logic [31:0] clk_ctr = 31'b0;

// read PPM into buffer
always @(posedge ppm) begin
	LED_PPM <= ~LED_PPM;
	t1 <= micros;
	dt <= micros - t1;
	// buffer full, transfer to ch_tmp
	if(i >= 13) begin
		LED <= dt[15:0];
		ch_tmp[0] <= buffer[0];
		ch_tmp[1] <= buffer[1];
		ch_tmp[2] <= buffer[2];
		ch_tmp[3] <= buffer[3];
		ch_tmp[4] <= buffer[4];
		ch_tmp[5] <= buffer[5];
		ch_tmp[6] <= buffer[6];
		ch_tmp[7] <= buffer[7];
		ch_tmp[8] <= buffer[8];
		ch_tmp[9] <= buffer[9];
		ch_tmp[10] <= buffer[10];
		ch_tmp[11] <= buffer[11];
		ch_tmp[12] <= buffer[12];
		i <= 32'b0;
	end else begin
		buffer[i] <= dt[15:0];
		i <= i + 1;
	end
end

// interpret ch_tmp as channels
// and pass to output ch
always @(posedge clk) begin
	if(ch_tmp[0] > 4000) begin
		ch[0] <= ch_tmp[0 + 1];
		ch[1] <= ch_tmp[0 + 2];
		ch[2] <= ch_tmp[0 + 3];
		ch[3] <= ch_tmp[0 + 4];
		ch[4] <= ch_tmp[0 + 5];
		ch[5] <= ch_tmp[0 + 6];
	end else if(ch_tmp[1] > 4000) begin
		ch[0] <= ch_tmp[1 + 1];
		ch[1] <= ch_tmp[1 + 2];
		ch[2] <= ch_tmp[1 + 3];
		ch[3] <= ch_tmp[1 + 4];
		ch[4] <= ch_tmp[1 + 5];
		ch[5] <= ch_tmp[1 + 6];
	end else if(ch_tmp[2] > 4000) begin
		ch[0] <= ch_tmp[2 + 1];
		ch[1] <= ch_tmp[2 + 2];
		ch[2] <= ch_tmp[2 + 3];
		ch[3] <= ch_tmp[2 + 4];
		ch[4] <= ch_tmp[2 + 5];
		ch[5] <= ch_tmp[2 + 6];
	end else if(ch_tmp[3] > 4000) begin
		ch[0] <= ch_tmp[3 + 1];
		ch[1] <= ch_tmp[3 + 2];
		ch[2] <= ch_tmp[3 + 3];
		ch[3] <= ch_tmp[3 + 4];
		ch[4] <= ch_tmp[3 + 5];
		ch[5] <= ch_tmp[3 + 6];
	end else if(ch_tmp[4] > 4000) begin
		ch[0] <= ch_tmp[4 + 1];
		ch[1] <= ch_tmp[4 + 2];
		ch[2] <= ch_tmp[4 + 3];
		ch[3] <= ch_tmp[4 + 4];
		ch[4] <= ch_tmp[4 + 5];
		ch[5] <= ch_tmp[4 + 6];
	end else if(ch_tmp[5] > 4000) begin
		ch[0] <= ch_tmp[5 + 1];
		ch[1] <= ch_tmp[5 + 2];
		ch[2] <= ch_tmp[5 + 3];
		ch[3] <= ch_tmp[5 + 4];
		ch[4] <= ch_tmp[5 + 5];
		ch[5] <= ch_tmp[5 + 6];
	end else if(ch_tmp[6] > 4000) begin
		ch[0] <= ch_tmp[6 + 1];
		ch[1] <= ch_tmp[6 + 2];
		ch[2] <= ch_tmp[6 + 3];
		ch[3] <= ch_tmp[6 + 4];
		ch[4] <= ch_tmp[6 + 5];
		ch[5] <= ch_tmp[6 + 6];
	end
end

always @(posedge clk) begin
	LED_CLK <= ~LED_CLK;
	if(clk_ctr >= 49) begin
		micros <= micros + 1;
		clk_ctr <= 31'b0;
	end else begin
		clk_ctr <= clk_ctr + 1;
	end
end

endmodule