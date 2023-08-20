----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-13
-- Design Name:    tb_dds
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

entity tb_dds is
  generic
  (
    DATA_WIDTH  : integer := 16;
    ACCUMULATOR_WIDTH : integer := 32
  );
end tb_dds;

architecture bh of tb_dds is

  component dds is
    generic (
      DATA_WIDTH         : natural;
      ACCUMULATOR_WIDTH  : natural;
      LUT_WIDTH          : natural;
      OPT_PHASE_OFFSET_1 : boolean;
      OPT_PHASE_OFFSET_2 : boolean; 
      OPT_OUTREG_2       : boolean
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

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk        : std_logic;
  signal rst_n      : std_logic;
  signal ftw        : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal phase      : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal dds_en     : std_logic;
  signal poff_1     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal poff_2     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal s_imag     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal s_real     : std_logic_vector((DATA_WIDTH-1) downto 0);

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

  p_test : process
  begin
    ftw     <= x"1000_0000";
    poff_1  <= x"0000_0000";
    poff_2  <= x"0000_0000";
    dds_en  <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    dds_en <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    ftw     <= x"2100_0000";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    ftw     <= x"0400_4321";

    wait;
  end process;

  pinc_inst : dds 
    generic map (
      DATA_WIDTH         => DATA_WIDTH,
      ACCUMULATOR_WIDTH  => ACCUMULATOR_WIDTH,
      LUT_WIDTH          => 11,
      OPT_PHASE_OFFSET_1 => false,
      OPT_PHASE_OFFSET_2 => false, 
      OPT_OUTREG_2       => false
    )
    port map (
      clk        => clk,
      rst_n      => rst_n,
      ftw        => ftw,
      phase      => phase,
      dds_en     => dds_en,
      poff_1     => poff_1,
      poff_2     => poff_2,
      out_real   => s_real,
      out_imag   => s_imag
    );

end bh;
