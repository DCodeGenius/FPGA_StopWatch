`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        
// 
// Create Date:     05/05/2019 02:59:38 AM
// Design Name:     EE3 lab1
// Module Name:     Ctl_tb
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     test bennch for the control.
// Dependencies:    None
//
// Revision: 		3.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Ctl_tb();

    reg clk, reset, trig, split, correct, loop_was_skipped;
    wire init_regs, count_enabled;
    //integer ai,cii;
    
    // Instantiate the UUT (Unit Under Test)
    Ctl uut (
        .clk(clk),
        .reset(reset),
        .trig(trig),
        .split(split),
        .init_regs(init_regs),
        .count_enabled(count_enabled)
    );
        // small helper: sample a bit after posedge so signals settle
//    task check; //TODO check if needed, delete if not
//        input exp_init;
//        input exp_count;
//        begin
//            #1; // allow propagation
//            correct = correct & (init_regs === exp_init) & (count_enabled === exp_count);
//        end
//    endtask
    
      // pulse helpers: make sure pulse is seen on a posedge
//    task pulse_trig;
//        begin
//            @(negedge clk);
//            trig = 1'b1;
//            @(negedge clk);
//            trig = 1'b0;
//        end
//    endtask

//    task pulse_split;
//        begin
//            @(negedge clk);
//            split = 1'b1;
//            @(negedge clk);
//            split = 1'b0;
//        end
//    endtask
      
    initial begin
        correct = 1;
        clk = 0; 
        reset = 1; 
        trig = 0;
        split = 0;
        #10
        reset = 0; 
        correct = correct & init_regs & ~count_enabled;
        #20
        
        // FILL HERE - TEST VARIOUS STATE TRANSITION 
        // IDLE -> COUNTING (pulse trig)
        @(negedge clk); trig = 1;
        @(negedge clk); trig = 0;
        @(posedge clk); #1;
        correct = correct & ~init_regs & count_enabled;

        // COUNTING stays COUNTING if split (per your current FSM)
        @(negedge clk); split = 1;
        @(negedge clk); split = 0;
        @(posedge clk); #1;
        correct = correct & ~init_regs & count_enabled;

        // COUNTING -> PAUSED (pulse trig)
        @(negedge clk); trig = 1;
        @(negedge clk); trig = 0;
        @(posedge clk); #1;
        correct = correct & ~init_regs & ~count_enabled;

        // PAUSED -> COUNTING (pulse trig)
        @(negedge clk); trig = 1;
        @(negedge clk); trig = 0;
        @(posedge clk); #1;
        correct = correct & ~init_regs & count_enabled;

        // COUNTING -> PAUSED again (pulse trig)
        @(negedge clk); trig = 1;
        @(negedge clk); trig = 0;
        @(posedge clk); #1;
        correct = correct & ~init_regs & ~count_enabled;

        // PAUSED -> IDLE (pulse split)
        @(negedge clk); split = 1;
        @(negedge clk); split = 0;
        @(posedge clk); #1;
        correct = correct & init_regs & ~count_enabled;

        // Reset from COUNTING: go to IDLE
        // First go IDLE -> COUNTING
        @(negedge clk); trig = 1;
        @(negedge clk); trig = 0;
        @(posedge clk); #1;
        correct = correct & ~init_regs & count_enabled;

        // Now assert reset
        @(negedge clk); reset = 1;
        @(posedge clk); #1;
        correct = correct & init_regs & ~count_enabled;

        // release reset, should still be IDLE
        @(negedge clk); reset = 0;
        @(posedge clk); #1;
        correct = correct & init_regs & ~count_enabled;
        #10        
        
          
        if (correct)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
    
    always #5 clk = ~clk;
    
endmodule
