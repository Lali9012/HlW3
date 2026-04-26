/* Testbench for Homework 3 Problem 3 */
module hw3p3_tb ();

  logic clk, reset, X;
  logic Ya, Yb, Yc, Z1, Z2;

  // Instantiate DUT
  hw3p3 dut (.*);

  // 10ns clock period
  parameter CLK_PERIOD = 10;
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // Task: apply one clock cycle and display state
  task apply_cycle(input logic x_in, input string note);
    X = x_in;
    @(posedge clk); #1;
    $display("t=%0t | X=%b | Ya=%b Yb=%b Yc=%b | Z1=%b Z2=%b | %s",
             $time, X, Ya, Yb, Yc, Z1, Z2, note);
  endtask

  initial begin
    
    // 1. Reset test

    reset = 1; X = 0;
    @(posedge clk); #1;
    $display("--- Reset applied ---");
    $display("t=%0t | X=%b | Ya=%b Yb=%b Yc=%b | Z1=%b Z2=%b | expect: S0 (Ya=1)",
             $time, X, Ya, Yb, Yc, Z1, Z2);
    assert (Ya === 1 && Yb === 0 && Yc === 0)
      else $error("FAIL: should be in S0 after reset");

    reset = 0;

    // 2. Stay in S0: X=0 self-loop

    $display("\n--- S0 self-loop (X=0) ---");
    apply_cycle(0, "expect: stay S0 (Ya=1)");
    assert (Ya === 1 && Yb === 0 && Yc === 0)
      else $error("FAIL: should remain in S0");

  
    // 3. S0 -> S1: X=1
    $display("\n--- S0->S1 (X=1) ---");
    apply_cycle(1, "expect: S1 (Yb=1)");
    assert (Ya === 0 && Yb === 1 && Yc === 0)
      else $error("FAIL: should be in S1");

   
    // 4. S1 -> S0: X=0
    $display("\n--- S1->S0 (X=0) ---");
    apply_cycle(0, "expect: S0 (Ya=1)");
    assert (Ya === 1 && Yb === 0 && Yc === 0)
      else $error("FAIL: should return to S0");

    
    // 5. Drive S0->S1->S2 path (X=1, X=1)
    $display("\n--- S0->S1->S2 (X=1, X=1) ---");
    apply_cycle(1, "expect: S1 (Yb=1)");
    assert (Yb === 1) else $error("FAIL: should be S1");

    apply_cycle(1, "expect: S2 (Yc=1)");
    assert (Ya === 0 && Yb === 0 && Yc === 1)
      else $error("FAIL: should be in S2");
 
    // 6. In S2 with X=0: Z1 asserted (Mealy), next -> S0
    
    $display("\n--- S2, X=0: Z1 Mealy output ---");
    X = 0; #1;  // change X *before* clock edge to observe combinational Mealy output
    $display("t=%0t (combinational) | X=%b | Yc=%b Z1=%b Z2=%b | expect Z1=1,Z2=0",
             $time, X, Yc, Z1, Z2);
    assert (Yc === 1 && Z1 === 1 && Z2 === 0)
      else $error("FAIL: Z1 should be asserted in S2 with X=0");

    @(posedge clk); #1;
    $display("t=%0t (after clk) | Ya=%b Yb=%b Yc=%b Z1=%b Z2=%b | expect: S0",
             $time, Ya, Yb, Yc, Z1, Z2);
    assert (Ya === 1 && Z1 === 0 && Z2 === 0)
      else $error("FAIL: should be back in S0, Z1/Z2 cleared");
    
    // 7. Drive to S2 again, test X=1: Z2 asserted (Mealy)

    $display("\n--- S2, X=1: Z2 Mealy output ---");
    apply_cycle(1, "S0->S1");
    apply_cycle(1, "S1->S2");

    X = 1; #1;
    $display("t=%0t (combinational) | X=%b | Yc=%b Z1=%b Z2=%b | expect Z1=0,Z2=1",
             $time, X, Yc, Z1, Z2);
    assert (Yc === 1 && Z1 === 0 && Z2 === 1)
      else $error("FAIL: Z2 should be asserted in S2 with X=1");

    @(posedge clk); #1;
    $display("t=%0t (after clk) | Ya=%b Z1=%b Z2=%b | expect: S0",
             $time, Ya, Z1, Z2);
    assert (Ya === 1 && Z1 === 0 && Z2 === 0)
      else $error("FAIL: should return to S0");
    
    // 8. Reset mid-sequence
   
    $display("\n--- Reset mid-sequence ---");
    apply_cycle(1, "S0->S1");
    reset = 1;
    @(posedge clk); #1;
    $display("t=%0t | Reset=1 | Ya=%b | expect: S0", $time, Ya);
    assert (Ya === 1) else $error("FAIL: reset did not return to S0");
    reset = 0;

    $display("\n=== All tests passed ===");
    $stop;
  end  // initial

endmodule  // hw3p3_tb
