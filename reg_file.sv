/* Register file module for specified data and address bus widths.
 * Asynchronous read port (r_addr -> r_data) and synchronous write
 * port (w_data -> w_addr if w_en).
 */
module reg_file #(parameter DATA_WIDTH=8, ADDR_WIDTH=2)
                (clk, w_data, w_en, w_addr, r_addr, half_sel, r_data);

  input  logic clk, w_en, half_sel;
  input  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  input  logic [2*DATA_WIDTH-1:0] w_data;
  output logic [DATA_WIDTH-1:0] r_data;
  
  logic [2*DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];
  
  always_ff @(posedge clk)
    if (w_en)
      array_reg[w_addr] <= w_data;
  
  // half_sel = 0: upper half first
  // half_sel = 1: lower half second
  assign r_data = (half_sel == 1'b0) ?
                  array_reg[r_addr][2*DATA_WIDTH-1:DATA_WIDTH] :
                  array_reg[r_addr][DATA_WIDTH-1:0];
  
endmodule
