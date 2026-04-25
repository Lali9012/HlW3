/* FIFO buffer where write width is twice read width.
 * DATA_WIDTH = read width.
 * w_data width = 2*DATA_WIDTH.
 * Upper half is read first, then lower half.
 */
module fifo #(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
            (clk, reset, rd, wr, empty, full, w_data, r_data);

  input  logic clk, reset, rd, wr;
  output logic empty, full;
  input  logic [2*DATA_WIDTH-1:0] w_data;
  output logic [DATA_WIDTH-1:0] r_data;
  
  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  logic w_en;
  logic half_sel;

  assign w_en = wr & (~full | rd);
  
  fifo_ctrl #(ADDR_WIDTH) c_unit (
    .clk(clk),
    .reset(reset),
    .rd(rd),
    .wr(wr),
    .empty(empty),
    .full(full),
    .w_addr(w_addr),
    .r_addr(r_addr),
    .half_sel(half_sel)
  );

  reg_file #(DATA_WIDTH, ADDR_WIDTH) r_unit (
    .clk(clk),
    .w_data(w_data),
    .w_en(w_en),
    .w_addr(w_addr),
    .r_addr(r_addr),
    .half_sel(half_sel),
    .r_data(r_data)
  );
  
endmodule
