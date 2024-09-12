// Processing element lab file for TSEA84
// Cheolyong Bae, Oscar Gustafsson 2019
// oscar.gustafsson@liu.se
  
module PE_bin(inputa, inputb, sat, clk, shift_val, op, result, overflow);

  parameter wordlength = 12;
  parameter shift_wordlength = 3;
  parameter OP_length = 4;

  input signed [wordlength-1:0] inputa, inputb;
  input sat;
  input clk;
  input [shift_wordlength-1:0] shift_val;
  input [OP_length-1:0] op;
  output [wordlength-1:0] result;
  output reg overflow;

  reg signed [wordlength:0] before_shift;
  wire signed [wordlength:0] before_saturation;
  reg signed [wordlength-1:0] signedout;
  integer i;


  always @(inputa, inputb, op) begin
    case(op)
      0 : before_shift = 0; 					//noop
      1 : before_shift = inputa + inputb; 			//add
      2 : before_shift = inputa - inputb; 			//sub
      3 : before_shift = (3/4)*inputa; 				//mul3over4a
      6 : before_shift = inputa; 				//shifta
      7 : before_shift = -inputa; 		                //nega
      8 : before_shift = (inputa >= 0)? inputa : -inputa; 	//absa
    endcase
  end

  assign before_saturation = before_shift >> shift_val;

  always @(before_saturation, sat) begin
    signedout = before_saturation[wordlength-1:0];
    overflow = 1'b0;
  end
  assign result = signedout[wordlength-1:0];
   

endmodule
