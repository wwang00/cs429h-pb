//16 bit

module motorcontroller();
    input logic clk;
    input logic RST;
    input logic PPM;
    input logic [3:0] pwm;

    input logic [15:0] sensRoll; //all are derivatives
    input logic [15:0] sensPitch;
    input logic [15:0] sensYaw; //r p t y

    ppm_decoder decoder(clk, RST, PPM, ch);

    wire [11:0] ch [0:3];

    wire [11:0] rx = ch[0];
    wire [11:0] ry = ch[1];
    wire [11:0] ly = ch[2];
    wire [11:0] lx = ch[3];

    wire[15:0] throttle = ly * THROTTLE_WEIGHT;

    parameter THROTTLE_WEIGHT = 1;

    parameter YAW_MAX = 250;
    parameter ROLL_MAX = 400;
    parameter PITCH_MAX = 400;

    parameter FS = 1000;

    wire signed [63:0] yawDiffBig = 500 * gYaw * FS - $signed(lx - 500) * (1 << 15) * YAW_MAX;
    wire signed [63:0] rollDiffBig = 500 * gRoll * FS - $signed(rx - 500) * (1 << 15) * ROLL_MAX;
    wire signed [63:0] pitchDiffBig = 500 * gPitch * FS - $signed(ry - 500) * (1 << 15) * PITCH_MAX;

    //15 + 9   divide by 2^15, then by 512, to get appx dps
    wire signed [15:0] yawDiff = yawDiffBig >>> 24; 
    wire signed [15:0] rollDiff = rollDiffBig >>> 24;
    wire signed [15:0] pitchDiff = pitchDiffBig >>> 24;

    //rotors turn in towards center
    pid rollCon(clk, 16'h0100, 0, 0, rollDiff, rollNet);
    //  +   -
    //  +   -
    pid pitchCon(clk, 16'h0100, 0, 0, pitchDiff, pitchNet);
    //  -   -
    //  +   +
    pid yawCon(clk, 16'h0100, 0, 0, yawDiff, yawNet); 
    //  -   +
    //  +   -

    wire signed [15:0] rollNet;
    wire signed [15:0] pitchNet;
    wire signed [15:0] yawNet;

    //make these boys big so we don't overflow. Negative indicates underflow, so set to 190
    wire signed [15:0] fl = (throttle +rollNet -pitchNet -yawNet);
    wire signed [15:0] fr = (throttle -rollNet -pitchNet +yawNet);
    wire signed [15:0] bl = (throttle +rollNet +pitchNet +yawNet);
    wire signed [15:0] br = (throttle -rollNet +pitchNet -yawNet);

    //  2   1
    //  3   0
    wire[11:0] motorOutput [3:0];

    //cap each thing at 190 and 999
    assign motorOutput[0] = br < 16'd190 ? 12'd190 : br > 16'd400 : br[11:0];
    assign motorOutput[1] = fr < 16'd190 ? 12'd190 : fr > 16'd400 : fr[11:0];
    assign motorOutput[2] = fl < 16'd190 ? 12'd190 : fl > 16'd400 : fl[11:0];
    assign motorOutput[3] = bl < 16'd190 ? 12'd190 : bl > 16'd400 : bl[11:0];

    //clk, reset, val, pwm
    pwm_encoder encoder(clk, RST, motorOutput, pwm);

    wire pwm; //TODO: route to some shit


endmodule