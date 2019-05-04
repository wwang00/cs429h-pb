//16 bit

module motorcontroller();
    input logic clk;
    input logic RST;
    input logic PPM;
    input logic [3:0] pwm;

    input logic [15:0] sensRoll; //all are derivatives
    input logic [15:0] sensPitch;
    input logic [15:0] sensYaw; //r p t y
    // output logic [18:0] bl; 
    // output logic [18:0] br; 
    // output logic [18:0] fl; 
    // output logic [18:0] fr; //big so we can have a sign bit and a useless bit

    wire [15:0] ch [0:12];

    ppm_decoder decoder(clk, RST, PPM, ch);

    wire [9:0] lx = ch[3]; 
    wire [9:0] ly = ch[2];
    wire [9:0] rx = ch[0];
    wire [9:0] ry = ch[1];

    //4* 16bit values, max 18 bits
    //sign bit would indicate underflow
    //sign : pad : pad : 16 bit number = 19 bits = [18:0]
    wire[11:0] rollNet;
    wire[11:0] pitchNet;
    wire[11:0] yawNet;

    //extend to 16 bits
    // wire [15:0] lxa = {lx : 6'b000000};
    // wire [15:0] lya = {ly : 6'b000000};
    // wire [15:0] rxa = {rx : 6'b000000};
    // wire [15:0] rya = {ry : 6'b000000};
    parameter YAW_MAX = 250;
    parameter ROLL_MAX = 400;
    parameter PITCH_MAX = 400;

    parameter FS = 1000;

    //are gyro values signed?
    wire signed [63:0] yawDiffBig = 500 * gYaw * FS - $signed(lx - 500) * (1 << 15) * YAW_MAX;
    wire signed [63:0] rollDiffBig = 500 * gRoll * FS - $signed(rx - 500) * (1 << 15) * ROLL_MAX;
    wire signed [63:0] pitchDiffBig = 500 * gPitch * FS - $signed(ry - 500) * (1 << 15) * PITCH_MAX;

    //15 + 9   divide by 2^15, then by 512, to get appx dps
    wire signed [16:0] yawDiff = yawDiffBig >>> 24; 
    wire signed [16:0] rollDiff = rollDiffBig >>> 24;
    wire signed [16:0] pitchDiff = pitchDiffBig >>> 24;


    pid rollCon(clk, 16'h0100, 0, 0, rollDiff, rollNet);
    //  +   -
    //  +   -
    pid pitchCon(clk, 16'h0100, 0, 0, pitchDiff, pitchNet);
    //  -   -
    //  +   +
    pid yawCon(clk, 16'h0100, 0, 0, yawDiff, yawNet); //turns in towards center
    //  -   +
    //  +   -

    //make these boys big so we don't overflow. Negative indicates underflow, so set to 0
    assign fl = lya +rollNet -pitchNet -yawNet;
    assign fr = lya -rollNet -pitchNet +yawNet;
    assign bl = lya +rollNet +pitchNet +yawNet;
    assign br = lya -rollNet +pitchNet -yawNet;

    //  2   1
    //  3   0
    wire[11:0] motorOutput [3:0];
    //cap each thing at 0 and 
    assign motorOutput[0] = br[18] == 1'b1 ? 0 : br[17:16] != 2'b00 ? 16'h03E7 : br[15:0];
    assign motorOutput[1] = fr[18] == 1'b1 ? 0 : fr[17:16] != 2'b00 ? 16'h03E7 : fr[15:0];
    assign motorOutput[2] = fl[18] == 1'b1 ? 0 : fl[17:16] != 2'b00 ? 16'h03E7 : fl[15:0];
    assign motorOutput[3] = bl[18] == 1'b1 ? 0 : bl[17:16] != 2'b00 ? 16'h03E7 : bl[15:0];



    wire pwm; //TODO: route to some shit

    //clk, reset, val, pwm
    pwm_encoder encoder(clk, RST, motorOutput, pwm);



endmodule