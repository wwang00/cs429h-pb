
//2^10 = 1024
//motor outputs between 0 and 1024
module pid(input clk, input signed[15:0] p, input signed[15:0] i, input signed [15:0] d, input signed [15:0] diff, output signed[15:0] net);

    parameter decVals = 12;//the number of vals to the right of the decimal
    //need to do floating point. sensval and target can both be signed, or both unsigned
    //p is in terms of 500 * dps
    wire signed [63:0] sum = pterm;

    //cap val to 16 bits
    assign net = sum < $signed(1 << 16) ? 16'hFFFF : sum > (-1 >> 48) ? 16'h7FFF : sum[15:0];

    wire pterm = (diff * p) >>> decVals;
    wire iterm = (accumulator * i) >>> decVals;
    wire dterm = ((diff - prevValues[lastPtr+1]) * d) >>> decVals;

    reg[63:0] accumulator = 0;
    reg[15:0] prevValues [3:0] = 0;
    reg [1:0] lastPtr = 0;
    
    //1 2 3 4

    always @(posedge clk) begin
        //I stuff
        accumulator <= accumulator + diff;

        //D stuff
        prevValues[lastPtr] = diff;

        lastPtr <= lastPtr + 1;
    end


endmodule
