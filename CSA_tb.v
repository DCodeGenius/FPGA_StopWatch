`timescale 1ns/10ps
`define WIDTH 4
//////////////////////////////////////////////////////////////////////////////////
module CSA_tb();

    reg [`WIDTH-1:0] a; 
    reg [`WIDTH-1:0] b;
    reg ci, correct, loop_was_skipped;
    wire [`WIDTH-1:0] sum;
    wire co;
    
    integer ai,bi,cii;
    
    // Instantiate the UUT (Unit Under Test)
    CSA #(`WIDTH) uut (a, b, ci, sum, co);
    
    initial begin
        correct = 1;
        loop_was_skipped = 1;
        #1
		
        for( ai=0; ai<2**`WIDTH; ai=ai+1 ) begin
            for( bi=0; bi<2**`WIDTH; bi=bi+1 ) begin
                for( cii=0; cii<=1; cii=cii+1 ) begin
                    // Drive inputs for this iteration
                    a  = ai[`WIDTH-1:0];
                    b  = bi[`WIDTH-1:0];
                    ci = cii[0];
		
				    #5;
					// Check result: integer addition vs {co,sum}
					correct = correct & ((ai + bi + cii) == {co, sum});
					
                    loop_was_skipped = 0;
					
                end
            end
        end
    
        if (correct && ~loop_was_skipped)
            $display("Test Passed - %m");
        else
            $display("Test Failed - %m");
        $finish;
    end
endmodule
