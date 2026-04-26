/* Register file with write port width = 2x read port width.
 * Each write stores upper half at w_addr, lower half at w_addr+1.
 * DATA_WIDTH is the READ port width.
 */
module reg_file #(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
                (clk, w_data, w_en, w_addr, r_addr, r_data);

  input  logic clk, w_en;
  input  logic [ADDR_WIDTH-1:0] w_addr, r_addr;
  input  logic [2*DATA_WIDTH-1:0] w_data;   // write port is 2x wide
  output logic [DATA_WIDTH-1:0]   r_data;   // read port is DATA_WIDTH wide

  // Storage sized for DATA_WIDTH-wide words
  logic [DATA_WIDTH-1:0] array_reg [0:2**ADDR_WIDTH-1];

  // Synchronous write: store upper half at w_addr, lower half at w_addr+1
  always_ff @(posedge clk)
    if (w_en) begin
      array_reg[w_addr]         <= w_data[2*DATA_WIDTH-1 : DATA_WIDTH]; // upper
      array_reg[w_addr + 1'b1]  <= w_data[DATA_WIDTH-1   : 0];          // lower
    end

  // Asynchronous read (DATA_WIDTH wide)
  assign r_data = array_reg[r_addr];

endmodule
