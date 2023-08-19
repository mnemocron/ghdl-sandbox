----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-13
-- Design Name:    tb_lut_cos_sfix16_2048_full
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

entity tb_lut_cos_sfix16_2048_full is
  generic
  (
    PHASE_WIDTH : natural := 11;
    DATA_WIDTH : natural := 16
  );
end tb_lut_cos_sfix16_2048_full;

architecture bh of tb_lut_cos_sfix16_2048_full is

  component lut_cos_sfix16_2048_full is
    generic (
        OPT_OUTREG_2 : boolean := false;
        PHASE_WIDTH  : natural := 11;
        DATA_WIDTH   : natural := 16
    );
    port (
      clk   : in std_logic;
      phase : in  std_logic_vector((PHASE_WIDTH-1) downto 0);
      wave  : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
  end component;

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk        : std_logic;
  signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  signal phase      : std_logic_vector((PHASE_WIDTH-1) downto 0) := (others => '0');
  signal amplitude  : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
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

  phase <= clk_count((PHASE_WIDTH-1) downto 0);

  inst_lut : lut_cos_sfix16_2048_full 
    generic map (
        OPT_OUTREG_2 => false,
        PHASE_WIDTH  => PHASE_WIDTH,
        DATA_WIDTH   => DATA_WIDTH
    )
    port map (
      clk   => clk,
      phase => phase,
      wave  => amplitude 
    );


end bh;
