----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-20
-- Design Name:    tb_fir_unoptimized
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

entity tb_fir_unoptimized is
  generic
  (
    DATA_WIDTH  : natural := 16;
    COEFF_WIDTH : natural := 16;
    ACCUMULATOR_WIDTH : integer := 32
  );
end tb_fir_unoptimized;

architecture bh of tb_fir_unoptimized is

  component fir_unoptimized is
    generic (
      DATA_WIDTH  : natural;
      COEFF_WIDTH : natural
    );
    port (
      clk  : in  std_logic;
      din  : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      dout : out std_logic_vector((DATA_WIDTH-1) downto 0);
      c0   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
      c1   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
      c2   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
      c3   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
      c4   : in  std_logic_vector((COEFF_WIDTH-1) downto 0)
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

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk        : std_logic;
  signal rst_n      : std_logic;

  signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  signal c0,c1,c2,c3,c4 : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');
  signal sigin  : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');
  signal sigout : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');

  signal ftw        : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal phase      : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal dds_en     : std_logic;
  signal poff_1     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal poff_2     : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal s_imag     : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
  signal s_real     : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');

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
  -- 2356 = 
  -- 4712 = 
  -- 5890 = 
  -- 4712 = 
  -- 2356 = 

    c0 <= std_logic_vector( to_signed(2356, DATA_WIDTH) ); -- x"0020";
    c1 <= std_logic_vector( to_signed(4712, DATA_WIDTH) ); -- x"0040";
    c2 <= std_logic_vector( to_signed(5890, DATA_WIDTH) ); -- x"00FF";
    c3 <= std_logic_vector( to_signed(4712, DATA_WIDTH) ); -- x"0040";
    c4 <= std_logic_vector( to_signed(2356, DATA_WIDTH) ); -- x"0020";

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

  sigin <= s_real;

  fir_inst : fir_unoptimized 
    generic map (
      DATA_WIDTH  => DATA_WIDTH,  
      COEFF_WIDTH => COEFF_WIDTH
    )
    port map (
      clk  => clk,
      din  => sigin,
      dout => sigout,
      c0   => c0,
      c1   => c1,
      c2   => c2,
      c3   => c3,
      c4   => c4
    );

end bh;
