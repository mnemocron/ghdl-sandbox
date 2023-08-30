----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-21
-- Design Name:    lfsr32
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

entity lfsr32 is
  generic (
    N : natural := 32
  );
  port (
    clk   : in  std_logic;
    rst_n : in std_logic;
    dout  : out std_logic_vector((N-1) downto 0)
  );
end lfsr32;

architecture arch_imp of lfsr32 is

  signal lfsr_reg  : std_logic_vector((N-1) downto 0) := (others => '0');
  signal lfsr_next : std_logic_vector((N-1) downto 0) := (others => '0');

begin

  dout <= lfsr_reg;
  lfsr_next((N-1) downto 1) <= lfsr_reg((N-2) downto 0);
  lfsr_next(0) <= lfsr_reg(31) xor lfsr_reg(21) xor lfsr_reg(1) xor lfsr_reg(0);

  p_reg : process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        lfsr_reg(0) <= '1'; -- Any nonzero start state will work.
        lfsr_reg((N-1) downto 1) <= (others => '0');
      else
        lfsr_reg <= lfsr_next;
      end if;
    end if;
  end process;

end arch_imp;
