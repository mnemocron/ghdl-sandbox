----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    phase_accumulator
-- Module Name:    phase_accumulator
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

entity phase_accumulator is
  generic (
    ACCUMULATOR_WIDTH  : natural := 16;
    OPT_RELOAD_IMMDT   : boolean := true;
    OPT_PHASE_OFFSET_1 : boolean := true;
    OPT_PHASE_OFFSET_2 : boolean := true
  );
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    ftw        : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    phase      : out std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    acc_en     : in  std_logic;
    acc_imm    : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    acc_reload : in  std_logic;
    poff_1     : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    poff_2     : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0)
  );
end phase_accumulator;

architecture arch_imp of phase_accumulator is

  signal cnt_en_in  : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');
  signal cnt_en_out : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');
  signal cnt_out    : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');
  signal cnt_reg    : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');
  signal poff1_out  : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');
  signal poff2_out  : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');

begin

  -- optional FTW immediate reload
  gen_accumulator_reload : if OPT_RELOAD_IMMDT generate
    cnt_en_in <= acc_imm when acc_reload = '1' else cnt_out;
  end generate;

  gen_no_accumulator_reload : if not OPT_RELOAD_IMMDT generate
    cnt_en_in <= cnt_out;
  end generate;

  -- accumulator enable
  cnt_en_out <= cnt_en_in when acc_en = '1' else cnt_reg;

  cnt_out <= std_logic_vector(signed(cnt_reg) + signed(ftw));
  
  p_accumulator : process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        cnt_reg <= (others => '0');
      else
        cnt_reg <= cnt_en_out;
      end if;
    end if;
  end process;

  -- optional phase offset output
  gen_poff1 : if OPT_PHASE_OFFSET_1 generate
    p_poff1 : process(clk)
    begin
      if rising_edge(clk) then
        if rst_n = '0' then
          poff1_out <= (others => '0');
        else
          poff1_out <= std_logic_vector(signed(cnt_en_out) + signed(poff_1));
        end if;
      end if;
    end process;
  end generate;

  gen_no_poff1 : if not OPT_PHASE_OFFSET_1 generate
    poff1_out <= cnt_reg;
  end generate;

  -- optional phase offset output
  gen_poff2 : if OPT_PHASE_OFFSET_2 generate
    p_poff2 : process(clk)
    begin
      if rising_edge(clk) then
        if rst_n = '0' then
          poff2_out <= (others => '0');
        else
          poff2_out <= std_logic_vector(signed(poff1_out) + signed(poff_2));
        end if;
      end if;
    end process;
  end generate;
  gen_no_poff2 : if not OPT_PHASE_OFFSET_2 generate
    poff2_out <= poff1_out;
  end generate;

  phase <= poff2_out;

end arch_imp;
