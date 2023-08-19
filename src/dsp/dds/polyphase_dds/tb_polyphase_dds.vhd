----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-13
-- Design Name:    tb_polyphase_dds
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

entity tb_polyphase_dds is
  generic
  (
    DATA_WIDTH        : integer := 16;
    ACCUMULATOR_WIDTH : integer := 32;
    PARALLELIZATION   : natural := 4
  );
end tb_polyphase_dds;

architecture bh of tb_polyphase_dds is

  component polyphase_dds is
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
  end component;

  constant CLK_PERIOD    : TIME := 5 ns;
  constant TX_CLK_PERIOD : TIME := 1.25 ns;

  signal clk        : std_logic;
  signal tx_clk     : std_logic;
  signal rst_n      : std_logic;
  signal ftw        : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal phase      : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal dds_en     : std_logic;
  signal poff_1     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
  signal poff_2     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);

  signal s_imag : std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0) := (others => '0');
  signal s_real : std_logic_vector(((PARALLELIZATION*DATA_WIDTH)-1) downto 0) := (others => '0');

  signal s_tx_imag : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal s_tx_real : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal s_tx_select : std_logic_vector(1 downto 0) := (others => '0');

  signal clk_count    : std_logic_vector(31 downto 0) := (others => '0');
  signal tx_clk_count : std_logic_vector(31 downto 0) := (others => '0');
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

  p_tx_clk_gen : process
  begin
   tx_clk <= '1';
   wait for (TX_CLK_PERIOD / 2);
   tx_clk <= '0';
   wait for (TX_CLK_PERIOD / 2);
  end process;

  p_tx_serializer : process(tx_clk)
  begin
    if rising_edge(tx_clk) then
      if unsigned(tx_clk_count) = 3 then
        tx_clk_count <= (others => '0');
      else
        tx_clk_count <= std_logic_vector(unsigned(tx_clk_count) + 1);
      end if;
      s_tx_select <= tx_clk_count(1 downto 0);
    end if;
  end process;
  s_tx_imag <= s_imag( 63 downto 48) when s_tx_select = "10" else
               s_imag( 47 downto 32) when s_tx_select = "01" else
               s_imag( 31 downto 16) when s_tx_select = "00" else
               s_imag( 15 downto  0) when s_tx_select = "11";
  
  s_tx_real <= s_real( 63 downto 48) when s_tx_select = "10" else
               s_real( 47 downto 32) when s_tx_select = "01" else
               s_real( 31 downto 16) when s_tx_select = "00" else
               s_real( 15 downto  0) when s_tx_select = "11";

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
    ftw     <= x"1100_0000";
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
    ftw     <= x"0200_0000";
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

  pinc_inst : polyphase_dds 
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ACCUMULATOR_WIDTH => ACCUMULATOR_WIDTH,
      LUT_WIDTH         => 11,
      PARALLELIZATION   => PARALLELIZATION
    )
    port map (
      clk      => clk,
      rst_n    => rst_n,
      ftw      => ftw,
      dds_en   => dds_en,
      poff     => poff_1,
      out_real => s_real,
      out_imag => s_imag
    );

end bh;
