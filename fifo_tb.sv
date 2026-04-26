module fifo_tb ();

  logic clk, reset, rd, wr;
  logic empty, full;
  logic [15:0] w_data;
  logic [7:0] r_data;

  fifo #(8, 4) dut (
    .clk(clk),
    .reset(reset),
    .rd(rd),
    .wr(wr),
    .empty(empty),
    .full(full),
    .w_data(w_data),
    .r_data(r_data)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    reset = 1;
    rd = 0;
    wr = 0;
    w_data = 16'h0000;

    #10;
    reset = 0;

    // Write ABCD
    @(negedge clk);
    w_data = 16'hABCD;
    wr = 1;
    rd = 0;

    @(negedge clk);
    wr = 0;

    // Read upper half: AB
    @(negedge clk);
    rd = 1;

    @(negedge clk);
    $display("Expected AB, got %h", r_data);

    // Read lower half: CD
    @(negedge clk);
    $display("Expected CD, got %h", r_data);

    rd = 0;

    // Write multiple values
    @(negedge clk);
    w_data = 16'h1234;
    wr = 1;

    @(negedge clk);
    w_data = 16'hDEAD;

    @(negedge clk);
    wr = 0;

    // Read 12
    @(negedge clk);
    rd = 1;

    @(negedge clk);
    $display("Expected 12, got %h", r_data);

    // Read 34
    @(negedge clk);
    $display("Expected 34, got %h", r_data);

    // Read DE
    @(negedge clk);
    $display("Expected DE, got %h", r_data);

    // Read AD
    @(negedge clk);
    $display("Expected AD, got %h", r_data);

    rd = 0;

    @(negedge clk);
    $display("empty = %b, full = %b", empty, full);

    #20;
    $stop;
  end

endmodule
