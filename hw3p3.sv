
/* Arbitrary ASM chart implementation to examine output timings */
module hw3p3 (clk, reset, X, Ya, Yb, Yc, Z1, Z2);

  input  logic clk, reset, X;
  output logic Ya, Yb, Yc;   // Moore outputs (registered with state)
  output logic Z1, Z2;        // Mealy outputs (combinational, depend on X)

  // State encoding
  typedef enum logic [1:0] {
    S0 = 2'b00,
    S1 = 2'b01,
    S2 = 2'b10
  } state_t;

  state_t ps, ns;  // present state, next state

  // State register (sequential logic)
  always_ff @(posedge clk) begin
    if (reset)
      ps <= S0;
    else
      ps <= ns;
  end

  // Next-state logic (combinational)
  always_comb begin
    case (ps)
      S0: ns = X ? S1 : S0;
      S1: ns = X ? S2 : S0;
      S2: ns = S0;          // both X=0 and X=1 return to S0
      default: ns = S0;
    endcase
  end

  // Moore output logic (depend only on present state)
  assign Ya = (ps == S0);
  assign Yb = (ps == S1);
  assign Yc = (ps == S2);

  // Mealy output logic (depend on present state AND input X)
  assign Z1 = (ps == S2) & ~X;  // asserted in S2 when X=0
  assign Z2 = (ps == S2) &  X;  // asserted in S2 when X=1

endmodule  // hw3p3
