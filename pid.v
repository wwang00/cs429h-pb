
//2^10 = 1024
//motor outputs between 0 and 1024
module pid(input clk, input signed[15:0] p, input signed[15:0] i, input signed [15:0] d, input[15:0] diff, output signed[15:0] net);

    parameter lookbackLength = 3
    parameter decVals = 10;//the number of vals to the right of the decimal
    //need to do floating point. sensval and target can both be signed, or both unsigned
    //p is in terms of 500 * dps
    assign net = (diff * p) >>> decVals;

    wire pterm = (diff * p) >>> decVals;
    wire iterm = (accumulator * i) >>> decVals;
    wire dterm = ((diff - prevValues[lastPtr+1]) * d) >>> decVals;

    reg[63:0] accumulator = 0;
    reg[15:0] prevValues [3:0] = 0;
    reg [1:0] lastPtr = 0;
    
    //1 2 3 4

    always @(posedge clk) begin
        // down
        // up 1
        // down
        // up 2
        // down 
        // up 3

        //I stuff
        accumulator <= accumulator + diff;

        //D stuff
        prevValues[lastPtr] = diff;

        lastPtr <= lastPtr + 1;
    end

    //hopefully we don't have to do i and d :)

endmodule
