`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Stopwatch top module (spec-compliant):
// - LHS 2 digits: stopwatch
// - RHS 2 digits: stash
// Buttons:
//   btnC = reset (entire system)
//   btnU = trig (if stopwatch selected) OR next_sample (if stash selected)
//   btnR = split (freeze snapshot in COUNTING; replace on each press;
//                 entering PAUSED shows real time again and holds)
//   btnL = toggle selection (stopwatch <-> stash)
//   btnD = sample current stopwatch value into stash (always works)
// LEDs: indicate which component selected (stopwatch/stash)
//////////////////////////////////////////////////////////////////////////////////
module Stopwatch(clk, btnC, btnU, btnR, btnL, btnD, seg, an, dp, led_left, led_right);

    input              clk, btnC, btnU, btnR, btnL, btnD;
    output wire [6:0]  seg;
    output wire [3:0]  an;
    output wire        dp;
    output wire [2:0]  led_left;
    output wire [2:0]  led_right;

    // Debounced 1-cycle pulses
    wire reset_p, up_p, split_p, toggle_p, sample_p;

    Debouncer u_db_reset  (.clk(clk), .input_unstable(btnC), .output_stable(reset_p));
    Debouncer u_db_up     (.clk(clk), .input_unstable(btnU), .output_stable(up_p));
    Debouncer u_db_split  (.clk(clk), .input_unstable(btnR), .output_stable(split_p));
    Debouncer u_db_toggle (.clk(clk), .input_unstable(btnL), .output_stable(toggle_p));
    Debouncer u_db_sample (.clk(clk), .input_unstable(btnD), .output_stable(sample_p));

    // Selection: 0 = stopwatch selected, 1 = stash selected
    reg selected_stash;

    always @(posedge clk) begin
        if (reset_p)
            selected_stash <= 1'b0;      // default select stopwatch after reset TODO dshamia make sure
        else if (toggle_p)
            selected_stash <= ~selected_stash;
    end

    // Map btnU depending on selection
    wire trig_p        = up_p & ~selected_stash; // stopwatch selected -> trigger
    wire next_sample_p = up_p &  selected_stash; // stash selected     -> browse next

    // Control FSM for stopwatch
    wire init_regs, count_enabled;

    Ctl u_ctl (
        .clk(clk),
        .reset(reset_p),
        .trig(trig_p),
        .split(split_p),          // NOTE: Ctl will ignore split in COUNTING, but uses it in PAUSED->IDLE
        .init_regs(init_regs),
        .count_enabled(count_enabled)
    );

    // Stopwatch counter (2 digits packed into [7:0])
    wire [7:0] time_now;

    Counter u_cnt (
        .clk(clk),
        .init_regs(init_regs),
        .count_enabled(count_enabled),
        .time_reading(time_now)
    );

    // ============================================================
    // Split snapshot logic (spec):
    // - In COUNTING, split freezes display at snapshot.
    // - Each additional split press replaces snapshot with current time.
    // - Entering PAUSED shows real current time again (and then holds).
    // ============================================================
    reg [7:0] snap;
    reg       snap_valid;

    always @(posedge clk) begin
        if (reset_p) begin
            snap       <= 8'd0;
            snap_valid <= 1'b0;
        end else begin
            if (count_enabled) begin
                // while counting: split captures/replaces snapshot
                if (split_p) begin
                    snap       <= time_now;
                    snap_valid <= 1'b1;
                end
            end else begin
                // not counting (IDLE or PAUSED): show real time again
                snap_valid <= 1'b0;
            end

            // if we reset registers (IDLE), also clear snapshot
            if (init_regs) begin
                snap       <= 8'd0;
                snap_valid <= 1'b0;
            end
        end
    end

    wire [7:0] time_for_display = (count_enabled & snap_valid) ? snap : time_now;

    // ============================================================
    // Stash: stores sampled stopwatch values; browse with next_sample
    // Sampling is allowed regardless of selection.
    // ============================================================
    wire [7:0] stash_out;

    Stash #(.DEPTH(5)) u_stash (
        .clk(clk),
        .reset(reset_p),
        .sample_in(time_now),
        .sample_in_valid(sample_p),   // btnD samples into stash always
        .next_sample(next_sample_p),  // btnU when stash selected
        .sample_out(stash_out)
    );

    // ============================================================
    // Display packing:
    // LHS 2 digits = stopwatch, RHS 2 digits = stash
    // time_reading[15:8] = left two digits
    // time_reading[7:0]  = right two digits
    // ============================================================
    wire [15:0] x_display = {time_for_display, stash_out};

    Seg_7_Display u_7seg (
        .x(x_display),
        .clk(clk),
        .clr(reset_p),      // optional: clears clkdiv, fine to tie to reset
        .a_to_g(seg),
        .an(an),
        .dp(dp)
    );

    // LEDs indicate selection: one side lit = selected
    // (simple, clear indicator)
    assign led_left  = selected_stash ? 3'b000 : 3'b111; // stopwatch selected
    assign led_right = selected_stash ? 3'b111 : 3'b000; // stash selected

endmodule
