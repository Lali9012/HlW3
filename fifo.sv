/* Asymmetric-width FIFO: write port = 2*DATA_WIDTH, read port = DATA_WIDTH.
 * DATA_WIDTH parameter refers to the READ port width.
 */
module fifo #(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
            (clk, reset, rd, wr, empty, full, w_data, r_data);

  input  logic clk, reset, rd, wr;
  output logic empty, full;
  input  logic [2*DATA_WIDTH-1:0] w_data;  // wide write
  output logic [DATA_WIDTH-1:0]   r_data;  // narrow read

  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  logic w_en;

  assign w_en = wr & (~full | rd);

  fifo_ctrl #(ADDR_WIDTH) c_unit (.*);
  reg_file  #(DATA_WIDTH, ADDR_WIDTH) r_unit (.*);

endmodule
