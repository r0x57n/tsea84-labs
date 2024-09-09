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
    shift_wordlength : integer := 3     -- Shift word length
  );

  port (
    inputa, inputb : in  std_logic_vector(wordlength-1 downto 0);       -- Inputs
    sat            : in  std_logic;                                     -- Saturate output
    clk            : in  std_logic;                                     -- Clock
    shift_val      : in  std_logic_vector(shift_wordlength-1 downto 0); -- Output shift
    op             : in  op_type;                                       -- Operation
    result         : out std_logic_vector(wordlength-1 downto 0);       -- Output
    overflow       : out std_logic                                      -- Overflow
   );
end entity PE;

architecture start of PE is
  signal signeda, signedb                   : signed(wordlength downto 0);              -- signed inputs
  signal signedoutput                       : signed(wordlength-1 downto 0);            -- signed output
  signal before_shift, before_saturation    : signed(wordlength downto 0);              -- Result before shift / saturation
  signal unsigned_shift                     : unsigned(shift_wordlength-1 downto 0);    -- unsigned shift_val
  signal V                                  : std_logic := '0';                         -- Overflow flag
begin
  unsigned_shift <= unsigned(shift_val);

  -- sign extend
  signeda <= resize(signed(inputa), signeda'length);
  signedb <= resize(signed(inputb), signedb'length);

  operations: process (signeda, signedb, op) is
    variable mul_tmp : signed(2*wordlength-1 downto 0);
  begin  -- process operations
  -- type op_type is (noop, add, sub, mul3over4a, mul7over8a, mul, shifta, nega, absa);
    case op is
      when noop => null;
      when add =>
        before_shift <= signeda + signedb;

        if (signeda(wordlength) = signedb(wordlength)) then
            if (signeda(wordlength) /= before_shift(wordlength)) then
                V <= '1';
            else
                V <= '0';
            end if;
        else
            V <= '0';
        end if;
      when sub =>
        before_shift <= signeda - signedb;

         if (signeda(wordlength-1) /= signedb(wordlength-1)) and
            (signeda(wordlength-1) /= before_shift(wordlength)) then
            V <= '1';
        else
            V <= '0';
        end if;
      when absa =>
        if signeda >= 0 then
            before_shift <= signeda;
        else
            before_shift <= -signeda;
        end if;

        V <= '0';
      when nega =>
        before_shift <= -signeda;
        V <= '0';
      when mul3over4a => 
        mul_tmp := 3*signeda;
        before_shift <= resize(shift_right(mul_tmp, 2), before_shift);

        V <= '0';
        for i in wordlength to 2*wordlength-2 loop
            if mul_tmp(i) /= mul_tmp(2*wordlength-1) then
                V <= '1';
            end if;
        end loop;
      when mul7over8a =>
        mul_tmp := 7*signeda;
        before_shift <= resize(shift_right(mul_tmp, 3), before_shift);

        V <= '0';
        for i in wordlength to 2*wordlength-2 loop
            if mul_tmp(i) /= mul_tmp(2*wordlength-1) then
                V <= '1';
            end if;
        end loop;
      when mul =>
        mul_tmp := signeda * signedb;

        V <= '0';
        for i in wordlength to 2*wordlength-2 loop
            if mul_tmp(i) /= mul_tmp(2*wordlength-1) then
                V <= '1';
            end if;
        end loop;
      when shifta =>
        before_shift <= signeda;
        V <= '0';
      when others => null;
    end case;
  end process;

  shifting: process (before_shift, unsigned_shift) is
  begin
    before_saturation <= shift_right(before_shift, to_integer(unsigned_shift));
  end process shifting;

  signedoutput <= before_saturation(wordlength-1 downto 0);
  overflow     <= V;

  result <= std_logic_vector(signedoutput);
end architecture start;
