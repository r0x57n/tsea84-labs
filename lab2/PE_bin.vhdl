-- Processing element lab file for TSEA84
-- Oscar Gustafsson, Cheolyong Bae, 2019
-- oscar.gustafsson@liu.se

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pe_types.all;

entity PE_bin_2 is
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
end entity PE_bin_2;

architecture start of PE_bin_2 is
  constant SIGN                             : integer := wordlength-1;
  constant MUL_SIGN                         : integer := 2*wordlength-1;
  signal mul_bits                           : signed(MUL_SIGN downto 0); -- temporary mul higher bits res
  signal mul_bits_1                         : signed(MUL_SIGN downto 0);
  signal before_shift, before_saturation    : signed(wordlength downto 0);      -- Result before shift / saturation
  signal before_saturation_1                : signed(wordlength downto 0);
  signal V                                  : std_logic;                        -- Overflow flag
  signal signedoutput                       : signed(wordlength-1 downto 0);    -- signed output

   -- Register signals for inputs
  signal reg_inputa, reg_inputa_1           : signed(wordlength downto 0);
  signal reg_inputb, reg_inputb_1           : signed(wordlength downto 0);
  signal reg_sat, reg_sat_1                 : std_logic;
  signal reg_shift_val                      : unsigned(shift_wordlength-1 downto 0);
  signal reg_op, reg_op_1                   : op_type;

  -- Register signals for outputs
  signal reg_result                         : std_logic_vector(wordlength-1 downto 0);
  signal reg_overflow                       : std_logic;
begin
  pipeline_inputs: process(clk)
  begin
    if rising_edge(clk) then
      reg_inputa    <= resize(signed(inputa), reg_inputa'length);
      reg_inputa_1  <= reg_inputa;
      reg_inputb    <= resize(signed(inputb), reg_inputb'length);
      reg_inputb_1  <= reg_inputb;
      reg_sat       <= sat;
      reg_sat_1     <= reg_sat;
      reg_shift_val <= unsigned(shift_val);
      reg_op        <= op;
      reg_op_1      <= reg_op;
      before_saturation_1 <= before_saturation;
      mul_bits_1   <= mul_bits;
    end if;
  end process;

  operations: process (reg_op, reg_inputa, reg_inputb, mul_bits) is
      variable mul_tmp : signed(MUL_SIGN downto 0);
      variable tmp_inputa : signed(wordlength downto 0);
      variable tmp_inputb : signed(wordlength downto 0);
  begin
    before_shift <= (others => '0');
    mul_bits <= (others => '0');

    if reg_op = sub then
        tmp_inputa := reg_inputa;
        tmp_inputb := -reg_inputb;
    elsif reg_op = mul3over4a then
        tmp_inputa := shift_right(reg_inputa, 1);
        tmp_inputb := shift_right(reg_inputa, 2);
    elsif reg_op = mul7over8a then
        tmp_inputa := reg_inputa;
        tmp_inputb := -(shift_right(reg_inputa, 3));
    else
        tmp_inputa := reg_inputa;
        tmp_inputb := reg_inputb;
    end if;

    case reg_op is
      when add | sub | mul3over4a | mul7over8a =>
        before_shift <= tmp_inputa + tmp_inputb;
      when mul =>
        mul_tmp := resize(reg_inputa*tmp_inputb, mul_tmp'length);
        mul_bits <= shift_right(mul_tmp, 11);
        before_shift <= resize(mul_bits, before_shift'length);
      when shifta =>
        before_shift <= reg_inputa;
      when nega =>
        before_shift <= -reg_inputa;
      when absa =>
        if reg_inputa(SIGN) = '0' then
            before_shift <= reg_inputa;
        else
            before_shift <= -reg_inputa;
        end if;
      when others => null;
    end case;
  end process;

  before_saturation <= shift_right(before_shift, to_integer(reg_shift_val));

  overflow_check: process (reg_op_1, reg_inputa_1, reg_inputb_1, before_saturation_1, mul_bits_1) is
    constant sign_check_pos : signed(2*wordlength+1 downto wordlength) := (others => '0');
    constant sign_check_neg : signed(2*wordlength+1 downto wordlength) := (others => '1');
  begin
    V <= '0';

    case reg_op_1 is
      when add =>
        if ((reg_inputa_1(SIGN) = reg_inputb_1(SIGN)) and
            (reg_inputa_1(SIGN) /= before_saturation_1(SIGN))) then
            V <= '1';
        end if;
      when sub =>
        if ((reg_inputa_1(SIGN)='0' and reg_inputb_1(SIGN)='1' and before_saturation_1(SIGN)='1') or
            (reg_inputa_1(SIGN)='1' and reg_inputb_1(SIGN)='0' and before_saturation_1(SIGN)='0')) then
            V <= '1';
        end if;
      when mul =>
        if ((mul_bits_1(SIGN) = '0' and (mul_bits_1(MUL_SIGN downto wordlength) /= sign_check_pos)) or
            (mul_bits_1(SIGN) = '1' and (mul_bits_1(MUL_SIGN downto wordlength) /= sign_check_neg))) then
            V <= '1';
        end if;
      when nega | absa =>
        if (before_saturation_1 = -2048 or before_saturation_1 = 2048) then
            V <= '1';
        end if;
      when others => null;
    end case;
  end process overflow_check;

  saturation: process (before_saturation_1, reg_sat_1, reg_op_1, V, mul_bits_1) is
    constant MAX_VALUE : signed(wordlength downto 0) := to_signed(2047, before_saturation'length);
    constant MIN_VALUE : signed(wordlength downto 0) := to_signed(-2048, before_saturation'length);
  begin
      signedoutput <= before_saturation_1(wordlength-1 downto 0);

      if reg_sat_1 = '1' and V = '1' then
        if reg_op_1 /= mul then
            if before_saturation_1(SIGN) = '1' then
              signedoutput <= resize(MAX_VALUE, signedoutput'length);
            else
              signedoutput <= resize(MIN_VALUE, signedoutput'length);
            end if;
        else
            if mul_bits_1 > MAX_VALUE then
              signedoutput <= resize(MAX_VALUE, signedoutput'length);
            else
              signedoutput <= resize(MIN_VALUE, signedoutput'length);
            end if;
        end if;
      end if;
  end process saturation;

  pipeline_outputs: process(clk)
  begin
    if rising_edge(clk) then
      reg_overflow  <= V;
      reg_result    <= std_logic_vector(signedoutput);
    end if;
  end process;

  overflow <= reg_overflow;
  result <= reg_result;
end architecture start;
