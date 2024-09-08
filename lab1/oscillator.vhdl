-- A simple numerical oscillator, based on research from Niklas U Andersson.
-- Current implementation produces the 25-sample period sine wave:
--   [465 435 377 295 194  80 -39 -156 -264 -356 -426 -470 -485 -470 -426 -356 -264 -156 -39 80 194 295 377 335 465]
--   This has an SFDR of 35 dB
-- 
-- Math:
--  y1(n) = 2cos(Theta)*y1(n-1) - y2(n-1)
--  y2(n) = y1(n-1)
-- 
--  f_osc = f_clk * Theta/(2*pi)
-- 
-- Let alpha = 2*cos(Theta).
-- Due to quantization, the implementation has exactly Nclk clock cycles
--  per Nrot output periods, where Nclk/Nrot ~ 2pi/Theta.
-- In this implementation, alpha = 31/32, giving 2pi/Theta = 25.067,
--  which, together with initial values y1=y2=465 gives Nrot=1, Nclk=25,
--  i.e., the output frequency is exactly f_clk / 25.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity oscillator is
  port(clk,rstn : in std_logic;
       y : out signed(9 downto 0));
end entity;

architecture sim of oscillator is
  constant WL : integer := 10; -- Word length of y1 and y2
  constant WLa : integer := 6; -- Word length of alpha.
  
  constant alpha : signed(WLa-1 downto 0) := to_signed(31, WLa); -- Defines the oscillation freqency.
  constant y1_init : signed(WL-1 downto 0) := to_signed(465, WL); -- Initial values
  constant y2_init : signed(WL-1 downto 0) := to_signed(465, WL);
  signal y1, y2 : signed(WL-1 downto 0);
begin
  process(clk,rstn) begin
    if rstn = '0' then
      y1 <= y1_init;
      y2 <= y2_init;
    elsif rising_edge(clk) then
      y2 <= y1;
      y1 <= resize(shift_right(y1*alpha, alpha'length-2) - y2, WL);
    end if;
  end process;
  y <= y1;
end architecture;

