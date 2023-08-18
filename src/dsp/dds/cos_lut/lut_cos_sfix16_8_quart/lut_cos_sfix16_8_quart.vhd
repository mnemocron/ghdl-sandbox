----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    lut_cos_sfix16_8_quart
-- Module Name:    lut_cos_sfix16_8_quart
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  
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
--use ieee.std_logic_arith.all;

entity lut_cos_sfix16_8_quart is
  generic (
      OPT_OUTREG_2  : boolean := false;
      PHASE_WIDTH : natural := 5;
      DATA_WIDTH  : natural := 16
  );
  port (
    clk   : in std_logic;
    -- rst_n : in std_logic; 
    phase : in  std_logic_vector((PHASE_WIDTH-1) downto 0);
    wave  : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end lut_cos_sfix16_8_quart;

architecture arch_imp of lut_cos_sfix16_8_quart is

  component mem_cos_sfix16_8_quart is
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
  signal wave_raw   : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal wave_raw_reg : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal wave_flip  : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal wave_reg   : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal wave_reg_2 : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');

  signal phase_quandrant : std_logic_vector(1 downto 0)         := (others => '0');
  signal phase_address   : std_logic_vector((PHASE_WIDTH-2-1) downto 0) := (others => '0');
  signal phase_address_d1 : std_logic_vector((PHASE_WIDTH-2-1) downto 0) := (others => '0');
  signal phase_address_d2 : std_logic_vector((PHASE_WIDTH-2-1) downto 0) := (others => '0');
  signal phase_address_d3 : std_logic_vector((PHASE_WIDTH-2-1) downto 0) := (others => '0');
  signal invert_signal : std_logic := '0';
  signal invert_phase  : std_logic := '0';

  signal phase_quandrant_reg : std_logic_vector(1 downto 0)         := (others => '0');
  signal phase_address_reg   : std_logic_vector((PHASE_WIDTH-2-1) downto 0) := (others => '0');
  signal invert_signal_reg   : std_logic := '0';
  signal invert_phase_reg    : std_logic := '0';
  signal phase_max : signed((PHASE_WIDTH-2-1) downto 0);

begin

  phase_address <= phase((PHASE_WIDTH-2-1) downto 0);
  phase_quandrant <= phase((PHASE_WIDTH-1) downto (PHASE_WIDTH-2));
  
  phase_max(PHASE_WIDTH-2-1) <= '0';
  phase_max((PHASE_WIDTH-2-2) downto 0) <= (others => '0');

  p_reg_control : process(clk)
  begin
    if rising_edge(clk) then
      phase_quandrant_reg <= phase_quandrant; 
      invert_signal_reg   <= invert_signal; 
      invert_phase_reg    <= invert_phase; 
      wave_raw_reg <= wave_raw;
      invert_signal <= phase_quandrant(0) xor phase_quandrant(1);
      invert_phase  <= phase_quandrant(0);
      phase_address_d1 <= phase_address;
      phase_address_d2 <= phase_address_d1;
      phase_address_d3 <= phase_address_d2;
    end if;
  end process;

  p_out_invert : process(clk)
  begin
    if rising_edge(clk) then
      if invert_signal_reg = '1' then
        wave <= std_logic_vector(-signed(wave_reg));
      else
        wave <= wave_reg;
      end if;

      if invert_phase_reg = '1' then
        phase_address_reg <= std_logic_vector(phase_max - signed(phase_address_d2));
      else
        phase_address_reg <= phase_address_d2;
      end if; 
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
  
  lut_mem_inst : mem_cos_sfix16_8_quart 
    generic map (
      ADDR_WIDTH => 3,
      DATA_WIDTH => 16
    )
    port map (
      a => phase_address_reg, 
      o => wave_unreg
    );

end arch_imp;
