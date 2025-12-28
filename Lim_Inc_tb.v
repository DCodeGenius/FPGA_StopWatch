`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Module Name:     Lim_Inc_tb
// Description:     Limited incrementor test bench
//////////////////////////////////////////////////////////////////////////////////
module Lim_Inc_tb();

    reg  [3:0] a; 
    reg        ci, correct, loop_was_skipped;
    wire [3:0] sum;
    wire       co;
    
    integer ai, cii;

    // Instantiate the UUT (Unit Under Test)
    // Lim_Inc(7): valid inputs are 0..6.
    // If a >= 7 OR (a+ci) >= 7 => sum=0, co=1
    // Else => sum=a+ci, co=0
    Lim_Inc #(.L(7)) uut (
        .a   (a),
        .ci  (ci),
        .sum (sum),
        .co  (co)
    );
    
    initial begin
        correct = 1;
        loop_was_skipped = 1;
        #1;

        // Stimulate a=0..15 and ci=0,1
        for (ai = 0; ai < 16; ai = ai + 1) begin
            for (cii = 0; cii <= 1; cii = cii + 1) begin
                a  = ai[3:0];
                ci = cii[0];

                #5; // allow combinational propagation

                // Golden model for L=7
                if ((ai >= 7) || ((ai + cii) >= 7)) begin
                    correct = correct & ((sum == 4'd0) && (co == 1'b1));
                end else begin
                    correct = correct & ((sum == (ai + cii)) && (co == 1'b0));
                end

                loop_was_skipped = 0;
            end
        end

        #5;
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
endmodule