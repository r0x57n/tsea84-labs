library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_1164.all;


package pe_types is
  type op_type is (noop, add, sub, mul3over4a, mul7over8a, mul, shifta, nega, absa);  -- Operations
  attribute enum_encoding : string;
  attribute enum_encoding of op_type : type is "sequential";

  constant OP_LENGTH : integer := integer(ceil(log2(real(op_type'pos(op_type'right)+1))));  -- Length of op_type

  function op_vector (i_op : in op_type) return std_logic_vector;
end package pe_types;

package body pe_types is
  function op_vector (i_op : in op_type) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(op_type'pos(i_op), OP_LENGTH));  -- return op_type in vector format according to its position
  end op_vector;
end package body pe_types;

