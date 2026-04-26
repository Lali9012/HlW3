module fifo_tb ();
  parameter DW = 8, AW = 4;

  logic clk, reset, rd, wr, empty, full;
  logic [2*DW-1:0] w_data;
  logic [DW-1:0]   r_data;

  fifo #(DW, AW) dut (.*);

  always #5 clk = ~clk;

  task write_word(input logic [2*DW-1:0] data);
    @(negedge clk); wr = 1; rd = 0; w_data = data;
    @(negedge clk); wr = 0;
  endtask

  task read_word;
    @(negedge clk); rd = 1; wr = 0;
    @(negedge clk); rd = 0;
  endtask

  initial begin
    clk=0; reset=1; rd=0; wr=0; w_data=0;
    @(negedge clk); reset = 0;

    // Test 1: Write 16'hABCD — expect upper=AB then lower=CD
    write_word(16'hABCD);
    read_word(); // r_data should be 8'hAB
    read_word(); // r_data should be 8'hCD

    // Test 2: Write multiple words, verify order
    write_word(16'h1234);
    write_word(16'h5678);
    read_word(); // 8'h12
    read_word(); // 8'h34
    read_word(); // 8'h56
    read_word(); // 8'h78

    // Test 3: Fill to full, verify full flag
    repeat(8) write_word(16'hFFFF);  // 8 writes = 16 slots (ADDR_WIDTH=4 → 16 entries)

    // Test 4: Empty check — read until empty
    repeat(16) read_word();

    // Test 5: Simultaneous read+write
    write_word(16'hBEEF);
    @(negedge clk); rd=1; wr=1; w_data=16'hDEAD;
    @(negedge clk); rd=0; wr=0;

    #20 $stop;
  end

  // Monitor outputs
  initial
    $monitor("t=%0t | wr=%b rd=%b | w_data=%h r_data=%h | full=%b empty=%b",
             $time, wr, rd, w_data, r_data, full, empty);

endmodule
