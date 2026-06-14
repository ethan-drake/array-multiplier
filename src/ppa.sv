// Code your design here
module ppa #(parameter WIDTH=4) (
  	input logic [WIDTH-1:0] srca,
    input logic [WIDTH-1:0] srcb,
    input logic cin,
    input logic is_signed,
    output logic [WIDTH-1:0] result,
    output logic cout,
    output logic zero_f,
    output logic ov_f
);
  localparam LEVELS = $clog2(WIDTH);
  logic [LEVELS:0][WIDTH-1:0] g, p;
  logic [WIDTH:0] c;

  
  assign g[0][0] = (srca[0] & srcb[0]) | (p[0][0] & cin);
  assign g[0][WIDTH-1:1] = srca[WIDTH-1:1] & srcb[WIDTH-1:1];          
  assign p[0] = srca ^ srcb;          
  // generate
  // propagate
  assign c[0] = cin;
  
  genvar i,j;
  generate
    for (i=1; i <= LEVELS; i++) begin: level
		// S is the shift amount for this specific level (1, 2, 4, 8...)
      localparam S = 1 << (i-1); 
      
      // Calculate the upper bits
      assign p[i][WIDTH-1:S] = p[i-1][WIDTH-1:S] & p[i-1][WIDTH-1-S:0];
      assign g[i][WIDTH-1:S] = g[i-1][WIDTH-1:S] | (p[i-1][WIDTH-1:S] & g[i-1][WIDTH-1-S:0]);
      
      // Pass through the lower bits
      assign p[i][S-1:0]     = p[i-1][S-1:0];
      assign g[i][S-1:0]     = g[i-1][S-1:0];
    end
  endgenerate
  

  assign c[WIDTH:1]=g[LEVELS][WIDTH-1:0];
  assign result[0]  = p[0][0] ^ c[0];
  assign result[WIDTH-1:1] = p[0][WIDTH-1:1]^g[LEVELS][WIDTH-2:0];
  assign cout = c[WIDTH];

  assign zero_f = (result==0);
  assign ov_f = is_signed ? ((c[WIDTH-1]) ^ (c[WIDTH])) : c[WIDTH];
  
endmodule
