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
  
  logic [RESULT_WIDTH-1:0]pp[SRC1_WIDTH:0];
  logic [RESULT_WIDTH-1:0]c;
  logic [RESULT_WIDTH-1:0]temp_p[SRC1_WIDTH:0];
  logic [RESULT_WIDTH-1:0]correction;

  assign pp[0] = {
    (srca[SRC1_WIDTH-1] & srcb[0]) ^ is_signed,	//MSB
    (srca[SRC2_WIDTH-2:0] & {(SRC2_WIDTH-1){srcb[0]}})	//Remaining bits
  };
  assign c[0]=0;
  assign correction={1'b1,{((SRC2_WIDTH)-2){1'b0}},1'b1,{(SRC2_WIDTH){1'b0}}};
  
  genvar i;
  generate
    for (i = 1; i <= SRC2_WIDTH; i = i + 1) begin : pp_gen
      //only one MSB
      if (i < (SRC2_WIDTH-1)) begin
        assign temp_p[i] = {
          (srca[SRC1_WIDTH-1] & srcb[i])^ is_signed,	//MSB
          (srca[SRC2_WIDTH-2:0] & {(SRC2_WIDTH-1){srcb[i]}})	//Remaining bits
        } << i;
        
      end else if (i == (SRC2_WIDTH-1))begin
	  //both MSBs
		assign temp_p[i] = {
          (srca[SRC1_WIDTH-1] & srcb[i]),	//MSB
          (srca[SRC2_WIDTH-2:0] & {(SRC2_WIDTH-1){srcb[i]}}) ^ {(SRC2_WIDTH-1){is_signed}}	//Remaining bits
        } << i;
      end else if (i == (SRC2_WIDTH))begin
      
        assign temp_p[i] = is_signed ? correction : '0;
      end
      
      ppa #(.WIDTH(RESULT_WIDTH)) adder(
        .srca(pp[i-1]),
        .srcb(temp_p[i]),
        .cin(c[i-1]),
        .is_signed(1'b1),
        .result(pp[i]),
        .cout(c[i])
		);
    end
  endgenerate
  
  assign result=pp[SRC1_WIDTH];
  
endmodule
