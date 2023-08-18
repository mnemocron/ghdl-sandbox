----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL 0.37
-- Description:    
-- 
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

-- simulate both with OPT_DATA_REG = True / False
entity tb_for_dsp is
  generic
  (
    DATA_WIDTH  : integer := 16;
  );
end tb_for_dsp;

architecture bh of tb_for_dsp is

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk : std_logic;
  signal rst_n : std_logic;

  signal wave_input : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
begin

  -- generate clk signal
  p_clk_gen : process
  begin
   clk <= '1';
   wait for (CLK_PERIOD / 2);
   clk <= '0';
   wait for (CLK_PERIOD / 2);
   clk_count <= std_logic_vector(unsigned(clk_count) + 1);
  end process;

  -- generate initial reset
  p_reset_gen : process
  begin 
    rst_n <= '0';
    wait until rising_edge(clk);
    wait for (CLK_PERIOD / 4);
    rst_n <= '1';
    wait;
  end process;

  p_sweep_gen : process(clk)
  begin
  
  end process;


end bh;
