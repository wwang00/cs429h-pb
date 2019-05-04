module ppm_decoder(clk, rst, ppm, ch);

input logic clk;
input logic rst;
input logic ppm;
output logic [11:0] ch [0:12] = '{default:12'b0};

logic [11:0] ch1 [0:12] = '{default:12'b0};
logic [11:0] ch2 [0:12] = '{default:12'b0};
logic [11:0] ch3 [0:12] = '{default:12'b0};

logic [63:0] micros = 63'b0;
logic [63:0] t0 = 63'b0;
wire [63:0] dt = micros - t0;

logic last_ppm = 1'b1;
logic [3:0] chi = 4'b0;

always @(posedge clk) begin
	if(~rst) begin
		ch <= '{default:12'b0};
		micros <= 63'b0;
		t0 <= 63'b0;
		last_ppm <= 1'b1;
		chi <= 4'b0;
	end else begin
		last_ppm <= ppm;
		if(ppm & ~last_ppm) begin
			t0 <= micros;
			if(dt > 5000) begin
				chi <= 4'b0;
			end else begin
				ch[chi] <= (
					(ch1[chi] <= ch2[chi]) && (ch2[chi] <= ch3[chi]) ? ch2[chi] :
					(ch1[chi] <= ch3[chi]) && (ch3[chi] <= ch2[chi]) ? ch3[chi] :
					(ch2[chi] <= ch1[chi]) && (ch1[chi] <= ch3[chi]) ? ch1[chi] :
					(ch2[chi] <= ch3[chi]) && (ch3[chi] <= ch1[chi]) ? ch3[chi] :
					(ch3[chi] <= ch1[chi]) && (ch1[chi] <= ch2[chi]) ? ch1[chi] :
					                                                   ch2[chi]
				);
				ch1[chi] <= (
					dt[11:0] < 1000 ? 12'd0 :
					dt[11:0] >= 2000 ? 12'd999 :
					dt[11:0] - 1000
				);
				ch2[chi] <= ch1[chi];
				ch3[chi] <= ch2[chi];
				chi <= chi + 1;
			end
		end
		micros <= micros + 1;
	end
end

endmodule