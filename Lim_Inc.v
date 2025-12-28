`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Module Name:     Lim_Inc
// Description:     Incrementor modulo L (valid values 0..L-1).
//                  If a is already >= L, or if a+ci >= L, output sum=0, co=1.
//////////////////////////////////////////////////////////////////////////////////
module Lim_Inc(a, ci, sum, co);
    
    parameter L = 10;
    localparam N = $clog2(L+1);
    
    input  [N-1:0] a;
    input          ci;
    output [N-1:0] sum;
    output         co;

    // Treat L as an N-bit constant for clean comparisons
    localparam [N-1:0] L_VAL = L[N-1:0];

    // raw = a + ci (computed via CSA, not '+')
    wire [N-1:0] raw_sum;
    wire         raw_co;

    // Add 'a' with zero, using carry-in = ci (acts like an incrementer)
    CSA #(N) u_inc (
        .a   (a),
        .b   ({N{1'b0}}),
        .ci  (ci),
        .sum (raw_sum),
        .co  (raw_co)
    );

    // Overflow conditions according to the lab truth table:
    // 1) a is already invalid (>= L)  -> force overflow output
    // 2) raw_sum is >= L              -> overflow due to increment
    wire a_invalid   = (a >= L_VAL);
    wire raw_over    = (raw_sum >= L_VAL);
    wire overflow    = a_invalid | raw_over;

    assign sum = overflow ? {N{1'b0}} : raw_sum;
    assign co  = overflow ? 1'b1      : 1'b0;

endmodule
