-- Processing element lab file for TSEA84
-- Oscar Gustafsson, Cheolyong Bae, 2019
-- oscar.gustafsson@liu.se

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pe_types.all;

entity PE is

  generic (
    wordlength       : integer := 12;   -- Data wordlength
    shift_wordlength : integer := 3);   -- Shift word length

  port (
    inputa, inputb : in  std_logic_vector(wordlength-1 downto 0);        -- Inputs
    sat            : in  std_logic;          -- Saturate output
    clk            : in  std_logic;          -- Clock
    shift_val      : in  std_logic_vector(shift_wordlength-1 downto 0);  -- Output shift
    op             : in  op_type;            -- Operation
    result         : out std_logic_vector(wordlength-1 downto 0);        -- Output
    overflow       : out std_logic);         -- Overflow

end entity PE;

architecture start of PE is

  signal signeda, signedb, signedoutput : signed(wordlength-1 downto 0);  -- signed
                                                                          -- inputs
                                                                          -- and outputs
  signal before_shift, before_saturation : signed(wordlength downto 0);  -- Result
                                                                         -- before shift
                                                                         -- and saturation
  signal unsigned_shift : unsigned(shift_wordlength-1 downto 0);  -- unsigned shift_val


begin  -- architecture start

  signeda <= signed(inputa);
  signedb <= signed(inputb);
  unsigned_shift <= unsigned(shift_val);

  -- purpose: Perform correct operation
  -- inputs : signeda, signedb, op
  -- outputs: before_shift
  operations: process (signeda, signedb, op) is
    variable mul_tmp : signed(2*wordlength-1 downto 0);  -- Temporary result from multiplication
  begin  -- process operations
  -- type op_type is (noop, add, sub, mul3over4a, mul7over8a, mul, shifta, nega, absa);  -- Operations
    case op is
      when noop => null;
      when add => before_shift <= resize(signeda, before_shift) + resize(signedb, wordlength+1);
      when sub => before_shift <= resize(signeda, before_shift) - resize(signedb, wordlength+1);
      when absa => if signeda >= 0 then
                    before_shift <= resize(signeda, before_shift'length);
                  else
                    before_shift <= resize(-signeda, before_shift);
                  end if;
      when nega => before_shift <= -resize(signeda, before_shift);
      when mul3over4a => mul_tmp := 3*signeda;
                         before_shift <= resize(shift_right(mul_tmp, 2), before_shift);
      when mul7over8a => mul_tmp := 7*signeda;
                         before_shift <= resize(shift_right(mul_tmp, 3), before_shift);
      when mul => mul_tmp := signeda*signedb;
      when shifta => before_shift <= resize(signeda, before_shift);
      when others => null;
    end case;
  end process;

  -- purpose: Shift intermediate data
  -- type   : combinational
  -- inputs : before_shift, shift_val
  -- outputs: before_saturation
  shifting: process (before_shift, unsigned_shift) is
  begin  -- process shifting
    before_saturation <= shift_right(before_shift, to_integer(unsigned_shift));
  end process shifting;

  -- Saturation and overflow
  signedoutput <= resize(before_saturation, signedoutput);
  overflow     <= '0';
 

  result <= std_logic_vector(signedoutput);

end architecture start;
