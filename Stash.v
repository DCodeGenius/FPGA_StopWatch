`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:         Tel Aviv University
// Engineer:        Leo Segre
// 
// Create Date:     05/05/2019 00:19 AM
// Design Name:     EE3 lab1
// Module Name:     Stash
// Project Name:    Electrical Lab 3, FPGA Experiment #1
// Target Devices:  Xilinx BASYS3 Board, FPGA model XC7A35T-lcpg236C
// Tool versions:   Vivado 2016.4
// Description:     a Stash that stores all the samples in order upon sample_in and sample_in_valid.
//                  It exposes the chosen sample by sample_out and the exposed sample can be changed by next_sample. 
// Dependencies:    Lim_Inc
//
// Revision         1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Stash(clk, reset, sample_in, sample_in_valid, next_sample, sample_out);

   parameter DEPTH = 5;
   
   input clk, reset, sample_in_valid, next_sample;
   input [7:0] sample_in;
   output [7:0] sample_out;
  
      
   localparam PTR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH);  
   
      // Storage
   reg [7:0] mem [0:DEPTH-1]; //each place at MEM will be a different 7:0 state we are able to display

   // Pointers
   wire [PTR_W-1:0] wr_ptr_next;
   wire [PTR_W-1:0] vis_ptr_next;
   wire wr_co, vis_co;
   reg [PTR_W-1:0] wr_ptr; //pointer to next write location
   reg [PTR_W-1:0] vis_ptr; // pointer to the currently displayed reg in memory
   
   integer k;
   
   // Combinational read of the currently visible sample
   assign sample_out = mem[vis_ptr];
   
   //lim_inc utilization to compute pointer locations when need to increment
   Lim_Inc #(.L(DEPTH)) u_wr_inc (
      .a   (wr_ptr),
      .ci  (1'b1),
      .sum (wr_ptr_next),
      .co  (wr_co)
   );

   Lim_Inc #(.L(DEPTH)) u_vis_inc (
      .a   (vis_ptr),
      .ci  (1'b1),
      .sum (vis_ptr_next),
      .co  (vis_co)
   );
   
      always @(posedge clk) begin
      if (reset) begin //block to clean memory if reset
         wr_ptr  <= {PTR_W{1'b0}};
         vis_ptr <= {PTR_W{1'b0}};
         for (k = 0; k < DEPTH; k = k + 1)
            mem[k] <= 8'b0;
      end
      else begin 
               // Highest priority: incoming new sample
         if (sample_in_valid) begin
            mem[wr_ptr] <= sample_in;

            // Jump-to-new-sample: show the newly written entry
            vis_ptr <= wr_ptr;

            // Advance write pointer 
            wr_ptr <= wr_ptr_next;

         end
else if (next_sample) begin
            // Browse next visible sample (TODO dshamia temporary logic; replace with Lim_Inc later)
            vis_ptr <= vis_ptr_next;

         end
         // else: nothing happens, hold all pointers
      end
   end
endmodule
