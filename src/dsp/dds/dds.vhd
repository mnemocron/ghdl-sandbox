----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-13
-- Design Name:    dds
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

entity dds is
  generic (
    DATA_WIDTH         : natural := 16;
    ACCUMULATOR_WIDTH  : natural := 32;
    LUT_WIDTH          : natural := 11;
    OPT_PHASE_OFFSET_1 : boolean := false;
    OPT_PHASE_OFFSET_2 : boolean := false; 
    OPT_OUTREG_2       : boolean := false
  );
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    ftw        : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    phase      : out std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    dds_en     : in  std_logic;
    poff_1     : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    poff_2     : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    out_real   : out std_logic_vector((DATA_WIDTH-1) downto 0);
    out_imag   : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end dds;

architecture arch_imp of dds is

  component phase_accumulator is
    generic (
      ACCUMULATOR_WIDTH  : natural;
      OPT_RELOAD_IMMDT   : boolean;
      OPT_PHASE_OFFSET_1 : boolean;
      OPT_PHASE_OFFSET_2 : boolean 
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
  end component;

  component lut_cos_sfix16_2048_full is
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
  end component;

  component lut_sin_sfix16_2048_full is
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
  end component;

  signal s_out_real      : std_logic_vector((DATA_WIDTH-1) downto 0 )         := (others => '0');
  signal s_out_imag      : std_logic_vector((DATA_WIDTH-1) downto 0 )         := (others => '0');
  signal s_phase         : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0)   := (others => '0');
  signal phase_trunc     : std_logic_vector((LUT_WIDTH-1) downto 0)           := (others => '0');

begin

  phase_trunc <= s_phase((ACCUMULATOR_WIDTH-1) downto (ACCUMULATOR_WIDTH-LUT_WIDTH));
  phase <= s_phase;
  out_real <= s_out_real;
  out_imag <= s_out_imag;

  pinc_inst : phase_accumulator 
    generic map (
      ACCUMULATOR_WIDTH  => ACCUMULATOR_WIDTH,
      OPT_RELOAD_IMMDT   => false,
      OPT_PHASE_OFFSET_1 => true,
      OPT_PHASE_OFFSET_2 => true 
    )
    port map (
      clk        => clk,
      rst_n      => rst_n,
      ftw        => ftw,
      phase      => s_phase,
      acc_en     => dds_en,
      acc_imm    => (others => '0'),
      acc_reload => '0',
      poff_1     => poff_1,
      poff_2     => poff_2
    );

  lut_cos_inst : lut_cos_sfix16_2048_full 
    generic map (
        OPT_OUTREG_2 => false,
        PHASE_WIDTH  => LUT_WIDTH,
        DATA_WIDTH   => DATA_WIDTH
    )
    port map (
      clk   => clk,
      phase => phase_trunc,
      wave  => s_out_real 
    );

  lut_sin_inst : lut_sin_sfix16_2048_full 
    generic map (
        OPT_OUTREG_2 => false,
        PHASE_WIDTH  => LUT_WIDTH,
        DATA_WIDTH   => DATA_WIDTH
    )
    port map (
      clk   => clk,
      phase => phase_trunc,
      wave  => s_out_imag 
    );


end arch_imp;
