----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-21
-- Design Name:    tb_lfsr16
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

entity tb_lfsr16 is
  generic
  (    
    N : natural := 32
  );
end tb_lfsr16;

architecture bh of tb_lfsr16 is

  component lfsr16 is
    generic (
      N : natural
    );
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      dout  : out std_logic_vector((N-1) downto 0)
    );
  end component;

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk        : std_logic;
  signal rst_n      : std_logic;
  signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  signal ctr_val    : std_logic_vector((N-1) downto 0) := (others => '0');

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

  lfsr_inst : lfsr16 
    generic map (
      N => N
    )
    port map (
      clk   => clk,
      rst_n => rst_n,
      dout  => ctr_val
    );

end bh;
