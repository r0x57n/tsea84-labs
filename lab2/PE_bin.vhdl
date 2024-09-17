-- Processing element lab file for TSEA84
-- Oscar Gustafsson, Cheolyong Bae, 2019
-- oscar.gustafsson@liu.se

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pe_types.all;

entity PE_bin is
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
end entity PE_bin;

architecture start of PE_bin is
  constant SIGN                             : integer := wordlength-1;
  constant MUL_SIGN                         : integer := 2*wordlength;
  signal signedoutput                       : signed(wordlength-1 downto 0);                    -- signed output
  signal mul_tmp_1                          : signed(2*wordlength+1 downto 0);                  -- temporary mul result
  signal mul_tmp_2                          : signed(2*wordlength+1 downto 0);                  -- temporary mul result
  signal before_shift, before_saturation    : signed(wordlength downto 0);                      -- Result before shift / saturation
  signal V                                  : std_logic;                                        -- Overflow flag

   -- Register signals for inputs
  signal reg_inputa, reg_inputb             : signed(wordlength downto 0);
  signal reg_sat                            : std_logic;
  signal reg_shift_val                      : unsigned(shift_wordlength-1 downto 0);
  signal reg_op                             : op_type;

  -- Register signals for outputs
  signal reg_result                         : std_logic_vector(wordlength-1 downto 0);
  signal reg_overflow                       : std_logic;
begin
  pipeline_inputs: process(clk)
  begin
    if rising_edge(clk) then
      reg_inputa    <= resize(signed(inputa), reg_inputa'length);
      reg_inputb    <= resize(signed(inputb), reg_inputb'length);
      reg_sat       <= sat;
      reg_shift_val <= unsigned(shift_val);
      reg_op        <= op;
    end if;
  end process;

  operations: process (reg_op, reg_inputa, reg_inputb, mul_tmp_1) is
      variable tmp_inputb : signed(wordlength downto 0);
  begin
    before_shift <= (others => '0');
    mul_tmp_1 <= (others => '0');

    if reg_op = sub then
      tmp_inputb := -reg_inputb;
    elsif reg_op = mul3over4a then
      tmp_inputb := to_signed(3, tmp_inputb'length);
    elsif reg_op = mul7over8a then
      tmp_inputb := to_signed(7, tmp_inputb'length);
    else
      tmp_inputb := reg_inputb;
    end if;

    case reg_op is
      when add | sub =>
        before_shift <= reg_inputa + tmp_inputb;
      when mul3over4a | mul7over8a | mul =>
        mul_tmp_1 <= reg_inputa*tmp_inputb;
        before_shift <= (others => '0');
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

  shift: process(reg_op, before_shift, reg_shift_val, mul_tmp_1) is
  begin
      case reg_op is
          when mul3over4a =>
            mul_tmp_2 <= resize(shift_right(mul_tmp_1, 2), mul_tmp_2'length);
            before_saturation <= shift_right(resize(shift_right(mul_tmp_1, 2), before_shift'length), to_integer(reg_shift_val));
          when mul7over8a =>
            mul_tmp_2 <= resize(shift_right(mul_tmp_1, 3), mul_tmp_2'length);
            before_saturation <= shift_right(resize(shift_right(mul_tmp_1, 3), before_shift'length), to_integer(reg_shift_val));
          when mul =>
            mul_tmp_2 <= resize(mul_tmp_1(24 downto 11), mul_tmp_2'length);
            before_saturation <= shift_right(resize(mul_tmp_1(24 downto 11), before_shift'length), to_integer(reg_shift_val));
          when others =>
            before_saturation <= shift_right(before_shift, to_integer(reg_shift_val));
            mul_tmp_2 <= (others => '0');
      end case;
  end process;

  overflow_check: process (reg_op, reg_inputa, reg_inputb, before_saturation, mul_tmp_2) is
    constant sign_check_pos : signed(2*wordlength+1 downto wordlength) := (others => '0');
    constant sign_check_neg : signed(2*wordlength+1 downto wordlength) := (others => '1');
  begin
    V <= '0';

    case reg_op is
      when add =>
        if ((reg_inputa(SIGN) = reg_inputb(SIGN)) and
            (reg_inputa(SIGN) /= before_saturation(SIGN))) then
            V <= '1';
        end if;
      when sub =>
        if ((reg_inputa(SIGN)='0' and reg_inputb(SIGN)='1' and before_saturation(SIGN)='1') or
            (reg_inputa(SIGN)='1' and reg_inputb(SIGN)='0' and before_saturation(SIGN)='0')) then
            V <= '1';
        end if;
      when mul =>
        if mul_tmp_2(SIGN) = '0' then
            if mul_tmp_2(2*wordlength downto wordlength) /= sign_check_pos then
                V <= '1';
            end if;
        else
            if mul_tmp_2(2*wordlength downto wordlength) /= sign_check_neg then
                V <= '1';
            end if;
        end if;
      when nega =>
        if reg_inputa = -2048 then
            V <= '1';
        end if;
      when absa =>
        if (before_saturation = -2048 or before_saturation = 2048) then
            V <= '1';
        end if;
      when others => null;
    end case;
  end process overflow_check;

  saturation: process (before_saturation, reg_sat, reg_op, V, mul_tmp_2) is
    constant MAX_VALUE : signed(wordlength downto 0) := to_signed(2047, before_saturation'length);
    constant MIN_VALUE : signed(wordlength downto 0) := to_signed(-2048, before_saturation'length);
  begin
      signedoutput <= before_saturation(wordlength-1 downto 0);

      if reg_sat = '1' and V = '1' then
        if reg_op /= mul then
            if before_saturation > MAX_VALUE then
              signedoutput <= resize(MAX_VALUE, signedoutput'length);
            else
              signedoutput <= resize(MIN_VALUE, signedoutput'length);
            end if;
        else
            if mul_tmp_2 > MAX_VALUE then
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
