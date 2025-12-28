`timescale 1ns/10ps
//////////////////////////////////////////////////////////////////////////////////
module Counter(clk, init_regs, count_enabled, time_reading);

  parameter CLK_FREQ = 100000000; // in Hz
  //parameter CLK_FREQ = 100; // in Hz

   input  clk, init_regs, count_enabled;
   output [7:0] time_reading;

   // Divider counter: counts 0..CLK_FREQ-1
   localparam CNT_W = (CLK_FREQ <= 1) ? 1 : $clog2(CLK_FREQ);
   reg [CNT_W-1:0] clk_cnt;

   // Two BCD digits (0..9 each)
   reg [3:0] ones_seconds;    
   reg [3:0] tens_seconds;

   // --------- Wires for combinational "next" values from Lim_Inc ---------
   wire [3:0] ones_next;
   wire       ones_co;      // carry/overflow from ones digit (9->0)

   wire [3:0] tens_next;
   wire       tens_co;      // carry/overflow from tens digit (99->00)

   // 1Hz tick (single-cycle pulse when divider reaches terminal count)
   wire tick_1hz;

   // Enable for digit increment (tick AND count_enabled)
   wire inc_pulse;

   // ----------------- Combinational assignments (no state) -----------------
   assign time_reading = {tens_seconds, ones_seconds};

   // tick_1hz should be 1 when clk_cnt hits its terminal count (CLK_FREQ-1)
    assign tick_1hz = (clk_cnt == (CLK_FREQ - 1));
    assign inc_pulse = tick_1hz & count_enabled;

   // ----------------- Limited-counter instances -----------------
   // ones digit: increments by 1 when inc_pulse=1, wraps at 10
   Lim_Inc #(.L(10)) u_ones (
      .a   (ones_seconds),
      .ci  (inc_pulse),
      .sum (ones_next),
      .co  (ones_co)
   );

   // tens digit: increments only when ones digit overflows (ones_co)
   Lim_Inc #(.L(10)) u_tens (
      .a   (tens_seconds),
      .ci  (ones_co),
      .sum (tens_next),
      .co  (tens_co)
   );

   //------------- Synchronous ----------------
   always @(posedge clk) begin
         if (init_regs) begin
            clk_cnt <= 0;
            ones_seconds <= 0;
            tens_seconds <= 0;    
             
          end else if(count_enabled==0) begin
              // do nothing: regs hold their value
          end else begin //count_enabled==1
                if (tick_1hz) begin
                    clk_cnt <= 0;                
                    ones_seconds <= ones_next;
                    tens_seconds <= tens_next;
               end else begin
                clk_cnt <= clk_cnt + 1;
               end
         end
    end
endmodule
