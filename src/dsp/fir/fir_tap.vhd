----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-20
-- Design Name:    fir_tap
-- Module Name:    
-- Project Name:   
-- Target Devices: Xilinx DSP48E2
-- Tool Versions:  GHDL 4.0.0-dev
-- Description:    
-- Dependencies:   
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_tap is
  generic (
    DATA_WIDTH  : natural := 16;
    COEFF_WIDTH : natural := 16
  );
  port (
    clk   : in  std_logic;
    xn    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    xnp   : out std_logic_vector((DATA_WIDTH-1) downto 0);
    yn    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    ynp   : out std_logic_vector((DATA_WIDTH-1) downto 0);
    coeff : in  std_logic_vector((COEFF_WIDTH-1) downto 0)
  );
end fir_tap;

architecture arch_imp of fir_tap is

  signal s_delay  : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_mult   : std_logic_vector((COEFF_WIDTH+DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_mult_r : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_acc    : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');

begin

  p_delay : process(clk)
  begin
    if rising_edge(clk) then
      s_delay <= xn;
    end if;
  end process;

  xnp <= s_delay;
  --s_mult <= std_logic_vector( resize( signed(coeff)*signed(s_delay) , s_mult'length) );
  s_mult <= std_logic_vector( signed(coeff)*signed(s_delay) );
  s_mult_r <= s_mult((COEFF_WIDTH+DATA_WIDTH-1) downto (DATA_WIDTH));
  s_acc  <= std_logic_vector( signed(yn) + signed(s_mult_r) );
  ynp <= s_acc;

end arch_imp;
