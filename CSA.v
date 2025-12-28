`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Design Name:     EE3 lab1
// Module Name:     CSA
// Description:     Variable length binary adder (Conditional Sum Adder).
//                  CSA(1) is a Full Adder. For N>1, split into low K and high N-K,
//                  compute high part twice (ci=0/1) and mux by carry from low part.
//////////////////////////////////////////////////////////////////////////////////
module CSA(a, b, ci, sum, co);

    parameter N = 4;
    parameter K = N >> 1;

    input  [N-1:0] a;
    input  [N-1:0] b;
    input          ci;
    output [N-1:0] sum;
    output         co;

    generate
        // ----- Base case: CSA(1) = Full Adder -----
        if (N == 1) begin : gen_base
            FA fa_inst (
                .a   (a[0]),
                .b   (b[0]),
                .ci  (ci),
                .sum (sum[0]),
                .co  (co)
            );
        end
        // ----- Recursive case: N > 1 -----
        else begin : gen_rec
            // low part width = K, high part width = N-K
            wire [K-1:0]       sum_low;
            wire               c_k;

            wire [N-K-1:0]     sum_hi0, sum_hi1;
            wire               co0, co1;

            wire [N-K-1:0]     sum_hi_sel;

            // Low K bits: CSA(K)
            CSA #( .N(K) ) csa_low (
                .a   (a[K-1:0]),
                .b   (b[K-1:0]),
                .ci  (ci),
                .sum (sum_low),
                .co  (c_k)
            );

            // High (N-K) bits computed twice: assume carry-in = 0 and = 1
            CSA #( .N(N-K) ) csa_hi_ci0 (
                .a   (a[N-1:K]),
                .b   (b[N-1:K]),
                .ci  (1'b0),
                .sum (sum_hi0),
                .co  (co0)
            );

            CSA #( .N(N-K) ) csa_hi_ci1 (
                .a   (a[N-1:K]),
                .b   (b[N-1:K]),
                .ci  (1'b1),
                .sum (sum_hi1),
                .co  (co1)
            );

            // Mux by carry from low part
            assign sum_hi_sel = (c_k) ? sum_hi1 : sum_hi0;
            assign co         = (c_k) ? co1     : co0;

            // Concatenate high and low sums into full sum
            assign sum = {sum_hi_sel, sum_low};
        end
    endgenerate

endmodule
