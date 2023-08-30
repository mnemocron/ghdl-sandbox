----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-21
-- Design Name:    tb_cic_filter
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

entity tb_cic_filter is
  generic
  (
    DATA_WIDTH        : natural := 16;
    CIC_DELAY_LENGTH  : natural := 10;
    ACCUMULATOR_WIDTH : integer := 32
  );
end tb_cic_filter;

architecture bh of tb_cic_filter is

  component cic is
    generic (
      Bin : natural := 24;
      R : natural := 8;
      N : natural := 3;
      M : natural := 1
    );

    port (
      clk : in std_logic;
      rst_n : in std_logic;
      data_i : in signed(Bin - 1 downto 0);
      clk_o : out std_logic;
      data_o : out signed(Bin - 1 downto 0)
    );
  end component;

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

  component lfsr16 is
    generic (
      N : natural := 16
    );
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      dout  : out std_logic_vector((N-1) downto 0)
    );
  end component;

  constant CLK_PERIOD    : TIME := 5 ns;
  constant TX_CLK_PERIOD : TIME := 1.25 ns;

  signal clk        : std_logic;
  signal tx_clk     : std_logic;
  signal rst_n      : std_logic;
  signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  signal tx_clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  
  signal sigin      : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');
  signal sigout     : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');
  signal sigout_s   : signed((DATA_WIDTH -1) downto 0 ) := (others => '0');

  signal ftw        : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal phase      : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal dds_en     : std_logic;
  signal poff_1     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal poff_2     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal s_imag     : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal s_real     : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');

  signal noise        : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal noise_scaled : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal s_imag_noisy : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal s_real_noisy : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');

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
   tx_clk_count <= std_logic_vector(unsigned(tx_clk_count) + 1);
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
    poff_1  <= x"0000_0000";
    poff_2  <= x"0000_0000";
    dds_en  <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    dds_en <= '1';
    wait until rising_edge(clk);

    wait;
  end process;

  p_variable_ftw : process(clk)
  begin
    if rising_edge(clk) then
      if unsigned(clk_count) = 1 then
        ftw <= x"4000_0000";
      end if;
      if unsigned(clk_count) = 50 then
        ftw <= x"2000_0000";
      end if;
      if unsigned(clk_count) = 100 then
        ftw <= x"1000_0000";
      end if;
      if unsigned(clk_count) = 150 then
        ftw <= x"0800_0000";
      end if;
      if unsigned(clk_count) = 200 then
        ftw <= x"0400_0000";
      end if;
      if unsigned(clk_count) = 250 then
        ftw <= x"0200_0000";
      end if;
      if unsigned(clk_count) = 300 then
        ftw <= x"0100_0000";
      end if;
      if unsigned(clk_count) = 400 then
        ftw <= x"0080_0000";
      end if;
      if unsigned(clk_count) = 600 then
        ftw <= x"0080_0000";
      end if;
      if unsigned(clk_count) = 1000 then
        ftw <= x"0040_0000";
      end if;
      if unsigned(clk_count) = 2000 then
        ftw <= x"0020_0000";
      end if;
    end if;
  end process;

  dds_inst : dds 
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

  sigin <= s_real_noisy;
  noise_scaled(8 downto 0) <= noise(8 downto 0);
  s_imag_noisy <= std_logic_vector( signed(s_imag) + signed(noise_scaled) );
  s_real_noisy <= std_logic_vector( signed(s_real) + signed(noise_scaled) );


  cic_inst : cic
    generic map (
      Bin => 16, -- : natural := 24;
      R   => 4, -- : natural := 8;
      N   => 10, -- : natural := 3;
      M   => 1  -- : natural := 1
    )
    port map (
      clk    => clk,
      rst_n  => rst_n,
      data_i => signed(s_imag_noisy),
      clk_o  => tx_clk,
      data_o => sigout_s
    );

    sigout <= std_logic_vector(sigout_s);

  lfsr_inst : lfsr16 
    port map (
      clk   => clk,
      rst_n => rst_n,
      dout  => noise
    );

end bh;
