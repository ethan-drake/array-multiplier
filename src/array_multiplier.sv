// Code your design here
`include "ppa.sv"
module multiplier#(
  parameter int SRC1_WIDTH    = 32,
  parameter int SRC2_WIDTH    =  SRC1_WIDTH,
  localparam int RESULT_WIDTH = (SRC1_WIDTH + SRC2_WIDTH)
) (
  input  logic [SRC1_WIDTH-1:0]       srca,
  input  logic [SRC2_WIDTH-1:0]       srcb,
  input  logic                        is_signed,
  output logic [RESULT_WIDTH-1:0]     result
);
  
  logic [RESULT_WIDTH-1:0]pp[SRC1_WIDTH-1:0];
  logic [RESULT_WIDTH-1:0]c;
  logic [RESULT_WIDTH-1:0]temp_p[SRC1_WIDTH-1:0];

  assign pp[0] = srca & {SRC2_WIDTH{srcb[0]}};
  assign c[0]=0;
  genvar i;
  generate
    for (i = 1; i < SRC2_WIDTH; i = i + 1) begin : pp_gen
      assign temp_p[i] = (srca & ({RESULT_WIDTH{srcb[i]}})) << i;

      ppa #(.WIDTH(RESULT_WIDTH)) adder(
        .srca(pp[i-1]),
        .srcb(temp_p[i]),
        .cin(c[i-1]),
        .is_signed(1'b0),
        .result(pp[i]),
        .cout(c[i])
		);
    end
  endgenerate
  
  assign result=pp[SRC1_WIDTH-1];
  
endmodule
