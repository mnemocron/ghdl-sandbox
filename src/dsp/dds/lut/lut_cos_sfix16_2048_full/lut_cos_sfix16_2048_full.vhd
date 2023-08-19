----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-13
-- Design Name:    lut_cos_sfix16_2048_full
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

entity lut_cos_sfix16_2048_full is
  generic (
      OPT_OUTREG_2 : boolean := false;
      PHASE_WIDTH  : natural := 11;
      DATA_WIDTH   : natural := 16
  );
  port (
    clk   : in  std_logic;
    phase : in  std_logic_vector((PHASE_WIDTH-1) downto 0);
    wave  : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end lut_cos_sfix16_2048_full;

architecture arch_imp of lut_cos_sfix16_2048_full is

  component mem_cos_sfix16_2048_full is
    generic (
      ADDR_WIDTH : natural;
      DATA_WIDTH : natural
    );
    port (
      a : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
      o : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
  end component;

  signal wave_unreg : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal wave_reg   : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal wave_reg_2 : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');

  signal phase_address_reg : std_logic_vector((PHASE_WIDTH-1) downto 0) := (others => '0');

begin

  wave <= wave_reg;
  
  p_in_reg : process(clk)
  begin
    if rising_edge(clk) then
      phase_address_reg <= phase;
    end if;
  end process;

  gen_single_reg : if not OPT_OUTREG_2 generate
    p_reg : process(clk)
    begin
      if rising_edge(clk) then
        wave_reg <= wave_unreg;
      end if;
    end process;
  end generate;

  gen_extra_reg : if OPT_OUTREG_2 generate
    p_reg : process(clk)
    begin
      if rising_edge(clk) then
        wave_reg_2 <= wave_unreg;
        wave_reg   <= wave_reg_2;
      end if;
    end process;
  end generate;
  
  lut_mem_inst : mem_cos_sfix16_2048_full 
    generic map (
      ADDR_WIDTH => 11,
      DATA_WIDTH => 16
    )
    port map (
      a => phase_address_reg, 
      o => wave_unreg
    );

end arch_imp;
