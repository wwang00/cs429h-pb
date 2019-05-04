
//2^10 = 1024
//motor outputs between 0 and 1024
module pid(input clk, input signed[15:0] p, input signed[15:0] i, input signed [15:0] d, input[15:0] diff, output signed[15:0] net);


    parameter decVals = 10;//the number of vals to the right of the decimal
    //need to do floating point. sensval and target can both be signed, or both unsigned
    //p is in terms of 500 * dps
    assign net = (diff * p) >>> decVals;

    reg[63:0] accumulator;
    reg[]


    always @(posedge clk) begin
        // down
        // up 1
        // down
        // up 2
        // down 
        // up 3



    end

    //hopefully we don't have to do i and d :)

endmodule
