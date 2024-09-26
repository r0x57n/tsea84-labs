-- Test bench for labs in TSEA84


library vunit_lib;
use vunit_lib.run_pkg.all;
use vunit_lib.string_ops.all;
context vunit_lib.vunit_context;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

use work.pe_types.all;

entity tb_pe is
  generic (
    runner_cfg       : string;
    wordlength       : integer := 12;
    shift_wordlength : integer := 3;
    pipeline         : integer := 0;
    logic_op         : boolean := false;
    file_name        : string;
    clk_period       : time
    );
end entity;

architecture tb of tb_pe is

  --Custom type for storing test data in testbench
  type PE_data is record
    inputa    : std_logic_vector(wordlength-1 downto 0);
    inputb    : std_logic_vector(wordlength-1 downto 0);
    sat       : std_logic;
    shift_val : std_logic_vector(shift_wordlength-1 downto 0);
    op        : op_type;
    result    : std_logic_vector(wordlength-1 downto 0);
    overflow  : std_logic;
  end record PE_data;

  signal data1, ref_data      : PE_data;
  signal result, result_d     : std_logic_vector(wordlength-1 downto 0);
  signal done, delayeddone    : std_logic := '0';
  signal clk                  : std_logic := '0';
  signal data_count           : integer   := 0;
  signal overflow,overflow_d  : std_logic;
  file intext                 : text open read_mode is file_name;

  type pipeddata is array(integer range <>) of PE_data;
  signal pipedout  : pipeddata(0 to pipeline);
  signal pipeddone : std_logic_vector(0 to pipeline);

begin
  -- Show information about passing tests as well
  show(get_logger(default_checker), display_handler, pass);

  -- Do not stop on failing tests. Useful here as we test many different inputs.
  disable_stop(get_logger(default_checker), error);

  -- Read inputs, operation, and expected outputs from file
  read_inputs : process
    variable Iline                                          : line;
    variable file_inputa, file_inputb, file_ref, file_shift : integer;
    variable file_sat, file_overflow                        : std_logic;
    variable chk_line                                       : lines_t;
  begin
    wait until rising_edge(clk);
    if not(endfile(intext)) then
      readline(intext, Iline);
      chk_line        := split(strip(Iline.all), ",");
      read(chk_line(0), file_inputa);
      read(chk_line(1), file_inputb);
      read(chk_line(2), file_shift);
      read(chk_line(3), file_sat);
      read(chk_line(5), file_ref);
      read(chk_line(6), file_overflow);
      data1.inputa    <= std_logic_vector(to_signed(file_inputa, wordlength));
      data1.inputb    <= std_logic_vector(to_signed(file_inputb, wordlength));
      data1.shift_val <= std_logic_vector(to_signed(file_shift, shift_wordlength));
      data1.sat       <= file_sat;
      data1.op        <= op_type'value(strip(chk_line(4).all));
      data1.result    <= std_logic_vector(to_signed(file_ref, wordlength));
      data1.overflow  <= file_overflow;
      data_count      <= data_count + 1;
    else
      done <= '1';
    end if;
  end process;


  delayblock : process(clk)
    variable i : integer;
  begin
    if rising_edge(clk) then
      pipedout(0)  <= data1;
      pipeddone(0) <= done;
      if pipeline >= 1 then

        for i in 1 to pipeline loop
          pipedout(i)  <= pipedout(i-1);
          pipeddone(i) <= pipeddone(i-1);
        end loop;
      end if;
    end if;
  end process;

  delayeddone <= pipeddone(pipeline);
  ref_data    <= pipedout(pipeline);

  storeoutput : process(clk)
  begin
    if rising_edge(clk) then
      result_d <= result;
      overflow_d <= overflow;
    end if;
  end process;

  clk_gen : process
  begin
    clk <= not(clk);
    wait for clk_period;
  end process clk_gen;

  instantiate_pe :
  if logic_op generate
    PE1 : entity work.PE_bin
      port map(
        inputa    => data1.inputa,
        inputb    => data1.inputb,
        sat       => data1.sat,
        clk       => clk,
        shift_val => data1.shift_val,
        op        => data1.op,
        result  => result,
        overflow  => overflow
        );
  else
    generate
      PE1 : entity work.PE_bin
        port map(
          inputa    => data1.inputa,
          inputb    => data1.inputb,
          sat       => data1.sat,
          clk       => clk,
          shift_val => data1.shift_val,
          op        => data1.op,
          result    => result,
          overflow  => overflow
          );
    end generate instantiate_pe;
    main : process
    begin
      test_runner_setup(runner, runner_cfg);  --Vunit test simulation starts
      while delayeddone /= '1' loop
        wait until rising_edge(clk);
        if data_count >= pipeline + 1 and delayeddone = '0' then
          wait for 0.1 ns;
          check_equal(signed(result_d), signed(ref_data.result), "Inputs: " & to_integer_string(signed(ref_data.inputa)) & ", " & to_integer_string(signed(ref_data.inputb)) & ". Op: " & op_type'image(ref_data.op));
          check_equal(overflow_d, ref_data.overflow, "Overflow: " & std_logic'image(ref_data.overflow));
        end if;
      end loop;

      test_runner_cleanup(runner);      -- Simulation ends here
    end process;
  end architecture;
