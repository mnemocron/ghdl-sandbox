----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-21
-- Design Name:    cic_tap
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

entity cic_tap is
  generic (
    DATA_WIDTH  : natural := 16;
    OPT_SUM_REG : boolean := false
  );
  port (
    clk   : in  std_logic;
    din   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    dout  : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end cic_tap;

architecture arch_imp of cic_tap is

  signal s_din          : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_sum_comb     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_sum_comb_dly : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_comb         : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_comb_dly     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_sum_intg     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');

begin

  s_din <= din;

  s_sum_comb <= std_logic_vector( signed(s_din) + signed(s_sum_comb_dly) );
  s_sum_intg <= std_logic_vector( signed(s_comb) - signed(s_comb_dly) );

  dout <= s_sum_intg;

  p_delays : process(clk)
  begin
    if rising_edge(clk) then
      s_sum_comb_dly <= s_sum_comb;
      s_comb_dly     <= s_comb;
    end if;
  end process;

  -- optional intermediate register
  gen_reg : if OPT_SUM_REG generate
    p_reg : process(clk)
    begin
      if rising_edge(clk) then
        s_comb <= s_sum_comb;
      end if;
    end process;
  end generate;
  -- no intermediate register to have a 3-input sum that can be handled in a single CLB LUT in Xilinx
  gen_no_reg : if not OPT_SUM_REG generate
    s_comb <= s_sum_comb;
  end generate;

  


end arch_imp;
