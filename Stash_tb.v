`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Stash_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the stash.
// Dependencies:    None
//
// Revision: 		1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash_tb();

    reg clk, reset, sample_in_valid, next_sample, correct, loop_was_skipped;
    reg [7:0] sample_in;
    wire [7:0] sample_out;
    integer ini;
    
    // Instantiate the UUT (Unit Under Test)
    Stash #(.DEPTH(5)) uut (
        .clk(clk),
        .reset(reset),
        .sample_in(sample_in),
        .sample_in_valid(sample_in_valid),
        .next_sample(next_sample),
        .sample_out(sample_out)
    );
    
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        loop_was_skipped = 1;
        // init inputs
        sample_in = 8'h00;
        sample_in_valid = 0;
        next_sample = 0;
        #6
        reset = 0;
        for( ini=0; ini<7; ini=ini+1 ) begin
            // drive a new sample and assert valid for 1 cycle
            @(negedge clk);
            sample_in = ini[7:0];
            sample_in_valid = 1'b1;

            @(negedge clk);
            sample_in_valid = 1'b0;
            @(posedge clk); #1;
            correct =  correct & (sample_out === ini[7:0]);
            loop_was_skipped = 0;
        end
        
               // Now test browsing: press next_sample DEPTH times and verify we cycle
        // through the last DEPTH stored samples. After 7 writes with DEPTH=5,
        // the buffer contains: {2,3,4,5,6} (in some order), and since we "jump"
        // to the newest on each write, we are currently displaying 6.
        //
        // Next_sample should cycle (with our current design) through indices mod DEPTH,
        // so the displayed sequence should be: 6 -> 2 -> 3 -> 4 -> 5 -> 6 ...
        //
        // We'll check the first 5 next_sample presses.
        @(posedge clk); #1;
        correct = correct & (sample_out === 8'd6);

        // press next_sample 1: expect 2
        @(negedge clk); next_sample = 1'b1;
        @(negedge clk); next_sample = 1'b0;
        @(posedge clk); #1;
        correct = correct & (sample_out === 8'd2);

        // press next_sample 2: expect 3
        @(negedge clk); next_sample = 1'b1;
        @(negedge clk); next_sample = 1'b0;
        @(posedge clk); #1;
        correct = correct & (sample_out === 8'd3);

        // press next_sample 3: expect 4
        @(negedge clk); next_sample = 1'b1;
        @(negedge clk); next_sample = 1'b0;
        @(posedge clk); #1;
        correct = correct & (sample_out === 8'd4);

        // press next_sample 4: expect 5
        @(negedge clk); next_sample = 1'b1;
        @(negedge clk); next_sample = 1'b0;
        @(posedge clk); #1;
        correct = correct & (sample_out === 8'd5);

        // press next_sample 5: expect 6 (wrap)
        @(negedge clk); next_sample = 1'b1;
        @(negedge clk); next_sample = 1'b0;
        @(posedge clk); #1;
        correct = correct & (sample_out === 8'd6);
        #5
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule
