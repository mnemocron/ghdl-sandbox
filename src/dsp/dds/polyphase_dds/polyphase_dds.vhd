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

entity polyphase_dds is
  generic (
    DATA_WIDTH        : natural := 16;
    ACCUMULATOR_WIDTH : natural := 32;
    LUT_WIDTH         : natural := 11;
    PARALLELIZATION   : natural := 4
  );
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    ftw        : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    dds_en     : in  std_logic;
    poff       : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    out_real   : out std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0);
    out_imag   : out std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0)
  );
end polyphase_dds;

architecture arch_imp of polyphase_dds is
  component dds is
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
  end component;

  signal ftw_adjust   : std_logic_vector(((PARALLELIZATION*ACCUMULATOR_WIDTH)-1) downto 0) := (others => '0');
  signal phase_adjust : std_logic_vector(((PARALLELIZATION*ACCUMULATOR_WIDTH)-1) downto 0) := (others => '0');
  signal s_real       : std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0)        := (others => '0');
  signal s_imag       : std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0)        := (others => '0');

begin

  out_real <= s_real;
  out_imag <= s_imag;

  gen_dds_inst :
  for J in 0 to (PARALLELIZATION-1) generate

    ftw_adjust  ((((J+1)*ACCUMULATOR_WIDTH)-1) downto (J*ACCUMULATOR_WIDTH)) <= std_logic_vector(resize(PARALLELIZATION*unsigned(ftw),ftw'length));
    phase_adjust((((J+1)*ACCUMULATOR_WIDTH)-1) downto (J*ACCUMULATOR_WIDTH)) <= std_logic_vector(resize(J*unsigned(ftw),ftw'length));
    
    dds_inst : dds
      generic map (
        DATA_WIDTH         => DATA_WIDTH,
        ACCUMULATOR_WIDTH  => ACCUMULATOR_WIDTH,
        OPT_PHASE_OFFSET_1 => true,
        OPT_PHASE_OFFSET_2 => true, 
        OPT_OUTREG_2       => true
      )
      port map (
        clk        => clk,
        rst_n      => rst_n,
        ftw        => ftw_adjust  ((((J+1)*ACCUMULATOR_WIDTH)-1) downto (J*ACCUMULATOR_WIDTH)),
        phase      => open,
        dds_en     => dds_en,
        poff_1     => poff,
        poff_2     => phase_adjust((((J+1)*ACCUMULATOR_WIDTH)-1) downto (J*ACCUMULATOR_WIDTH)),
        out_real   => s_real((((J+1)*DATA_WIDTH)-1) downto (J*DATA_WIDTH)),
        out_imag   => s_imag((((J+1)*DATA_WIDTH)-1) downto (J*DATA_WIDTH))
      );
  end generate;

end arch_imp;
