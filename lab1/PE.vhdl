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
  constant SIGN                             : integer := wordlength-1;
  signal signeda, signedb                   : signed(wordlength downto 0);                      -- signed inputs
  signal signedoutput                       : signed(wordlength-1 downto 0);                    -- signed output
  signal before_shift, before_saturation    : signed(wordlength downto 0) := (others => '0');   -- Result before shift / saturation
  signal unsigned_shift                     : unsigned(shift_wordlength-1 downto 0);            -- unsigned shift_val
  signal V                                  : std_logic;                                        -- Overflow flag
  signal mulus_tempus                       : signed(2*wordlength+1 downto 0);
begin
  unsigned_shift <= unsigned(shift_val);

  -- sign extend
  signeda <= resize(signed(inputa), signeda'length);
  signedb <= resize(signed(inputb), signedb'length);

  operations: process (signeda, signedb, op, before_shift) is
    variable mul_tmp : signed(2*wordlength+1 downto 0);
    variable sign_check : signed(2*wordlength+1 downto wordlength);
  begin
    V <= '0';

    case op is
      when noop => null;
      when add =>
        before_shift <= signeda + signedb;

        if ((signeda(SIGN) = signedb(SIGN)) and
            (signeda(SIGN) /= before_shift(SIGN))) then
            V <= '1';
        end if;
      when sub =>
        before_shift <= signeda - signedb;

        if ((signeda(SIGN)='0' and signedb(SIGN)='1' and before_shift(SIGN)='1') or
            (signeda(SIGN)='1' and signedb(SIGN)='0' and before_shift(SIGN)='0')) then
            V <= '1';
        end if;
      when mul3over4a =>
        mul_tmp := 3*signeda;
        before_shift <= resize(shift_right(mul_tmp, 2), before_shift'length);
      when mul7over8a =>
        mul_tmp := 7*signeda;
        before_shift <= resize(shift_right(mul_tmp, 3), before_shift'length);
      when mul =>
        mul_tmp := signeda * signedb;
        before_shift <= resize(mul_tmp, before_shift'length);

        if (mul_tmp(SIGN) = '0') then
            sign_check := (others => '0');
            if (mul_tmp(2*wordlength downto wordlength) /= sign_check) then
                V <= '1';
            end if;
        else
            sign_check := (others => '1');
            if (mul_tmp(2*wordlength downto wordlength) /= sign_check) then
                V <= '1';
            end if;
        end if;
      when shifta =>
        before_shift <= signeda;
      when nega =>
        before_shift <= -signeda;
        if (signeda = -2048) then
            V <= '1';
        end if;
      when absa =>
        if signeda >= 0 then
            before_shift <= signeda;
        else
            before_shift <= -signeda;
        end if;

        if (signeda = -2048) then
            V <= '1';
        end if;
      when others => null;
    end case;
  end process;

  shifting: process (before_shift, unsigned_shift) is
  begin
    before_saturation <= shift_right(before_shift, to_integer(unsigned_shift));
  end process shifting;

  saturation: process (before_saturation, sat) is
    constant MAX_VALUE : signed(wordlength downto 0) := to_signed(2047, before_saturation'length);
    constant MIN_VALUE : signed(wordlength downto 0) := to_signed(-2048, before_saturation'length);
  begin
      signedoutput <= before_saturation(wordlength-1 downto 0);

      if sat = '1' then
        if before_saturation > signed(MAX_VALUE) then
          signedoutput <= resize(MAX_VALUE, signedoutput'length);
        elsif before_saturation < signed(MIN_VALUE) then
          signedoutput <= resize(MIN_VALUE, signedoutput'length);
        end if;
      end if;
  end process saturation;

  overflow <= V;
  result <= std_logic_vector(signedoutput);
end architecture start;
