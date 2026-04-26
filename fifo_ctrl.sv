/* FIFO controller for asymmetric-width FIFO.
 * Write pointer advances by 2 (one write = two DATA_WIDTH slots).
 * Read pointer advances by 1.
 * Full/empty logic uses slot-level counting.
 */
module fifo_ctrl #(parameter ADDR_WIDTH=4)
                 (clk, reset, rd, wr, empty, full, w_addr, r_addr);

  input  logic clk, reset, rd, wr;
  output logic empty, full;
  output logic [ADDR_WIDTH-1:0] w_addr, r_addr;

  logic [ADDR_WIDTH-1:0] rd_ptr, rd_ptr_next;
  logic [ADDR_WIDTH-1:0] wr_ptr, wr_ptr_next;
  logic empty_next, full_next;

  assign w_addr = wr_ptr;
  assign r_addr = rd_ptr;

  always_ff @(posedge clk) begin
    if (reset) begin
      wr_ptr <= 0;
      rd_ptr <= 0;
      full   <= 0;
      empty  <= 1;
    end else begin
      wr_ptr <= wr_ptr_next;
      rd_ptr <= rd_ptr_next;
      full   <= full_next;
      empty  <= empty_next;
    end
  end

  always_comb begin
    rd_ptr_next = rd_ptr;
    wr_ptr_next = wr_ptr;
    empty_next  = empty;
    full_next   = full;

    case ({rd, wr})
      2'b01: // write only — advances by 2 slots
        if (~full) begin
          wr_ptr_next = wr_ptr + 2'd2;
          empty_next  = 0;
          // full if wr_ptr+2 wraps to rd_ptr
          if ((wr_ptr + 2'd2) == rd_ptr)
            full_next = 1;
        end

      2'b10: // read only — advances by 1 slot
        if (~empty) begin
          rd_ptr_next = rd_ptr + 1'b1;
          full_next   = 0;
          if (rd_ptr_next == wr_ptr)
            empty_next = 1;
        end

      2'b11: // simultaneous read+write
        begin
          rd_ptr_next = rd_ptr + 1'b1;
          if (~full)
            wr_ptr_next = wr_ptr + 2'd2;
          // empty/full unchanged in balanced r/w
        end

      2'b00: ; // no change
    endcase
  end

endmodule
