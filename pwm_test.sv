module pwm_test(RAW_CLK, RST, KEY1, ESC, LED_PWM);

input logic RAW_CLK;
input logic RST;
input logic KEY1;
output logic ESC = 0;
output logic LED_PWM = 0;

logic clk = 0;
logic [31:0] clk_ctr = 31'b0;

logic [63:0] micros = 63'b0;
logic [63:0] t0 = 63'b0;
wire [63:0] dt = micros - t0;

always @(posedge clk) begin
	if(~RST) begin
		ESC <= 0;
		micros <= 63'b0;
		t0 <= 63'b0;
	end else begin
		if(dt > 2083) begin
			t0 <= micros;
			ESC <= 1;
			LED_PWM <= 1;
		end else begin
			if(dt > 1000 + 1000 * KEY1) begin
				ESC <= 0;
				LED_PWM <= 0;
			end
		end
		micros <= micros + 1;
	end
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