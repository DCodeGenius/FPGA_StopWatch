`timescale 1 ns / 1 ns
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Module Name:     Counter_tb
// Description:     test bench for Counter module
//////////////////////////////////////////////////////////////////////////////////
module Counter_tb();

    reg  clk, init_regs, count_enabled, correct, loop_was_skipped;
    wire [7:0] time_reading;
    wire [3:0] tens_seconds_wire;
    wire [3:0] ones_seconds_wire;

    integer ts, os;
    integer sync;

    // Instantiate the UUT (Unit Under Test)
    // 100MHz clock => CLK_FREQ must be 100,000,000
    Counter #(.CLK_FREQ(100000000)) uut (
        .clk          (clk),
        .init_regs    (init_regs),
        .count_enabled(count_enabled),
        .time_reading (time_reading)
    );

    assign tens_seconds_wire = time_reading[7:4];
    assign ones_seconds_wire = time_reading[3:0];

    // 100MHz clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        #1;
        sync = 0;
        correct = 1;
        loop_was_skipped = 1;

        // init
        clk = 1'b0;
        init_regs = 1'b1;
        count_enabled = 1'b0;

        // hold init for a couple cycles
        #50;
        init_regs = 1'b0;

        // enable counting
        count_enabled = 1'b1;
       
        // Check after 1 second we got 01
        #(1000000000 + sync);
        sync = sync | 1;                 
        loop_was_skipped = 0;
        correct = correct & (time_reading == 8'h01);

        // Check after another 1 second we got 02
        #(1000000000 + sync);
        correct = correct & (time_reading == 8'h02);

        // Optional small pause test
        count_enabled = 1'b0;
        #200;
        correct = correct & (time_reading == 8'h02);
        count_enabled = 1'b1;

        #5;
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");

        $finish;
    end

endmodule
