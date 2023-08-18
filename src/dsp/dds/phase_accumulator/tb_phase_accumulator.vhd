----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL 0.37
-- Description:    
-- 
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

-- simulate both with OPT_DATA_REG = True / False
entity tb_phase_accumulator is
  generic
  (
    DATA_WIDTH  : integer := 32
  );
end tb_phase_accumulator;

architecture bh of tb_phase_accumulator is

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

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk        : std_logic;
  signal rst_n      : std_logic;
  signal ftw        : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal phase      : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal acc_en     : std_logic;
  signal acc_imm    : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal acc_reload : std_logic;
  signal poff_1     : std_logic_vector((DATA_WIDTH-1) downto 0);
  signal poff_2     : std_logic_vector((DATA_WIDTH-1) downto 0);

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
    ftw     <= x"4002_4561";
    poff_1  <= x"0000_0000";
    poff_2  <= x"0000_0000";
    acc_imm <= x"0000_0000";
    acc_en  <= '0';
    acc_reload <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    acc_en <= '1';
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
    ftw     <= x"2002_4561";
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
    ftw     <= x"1002_4561";
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

    -- reload
    ftw     <= x"0000_0000";
    wait until rising_edge(clk);
    acc_reload <= '1';
    wait until rising_edge(clk);
    acc_reload <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    acc_imm <= x"dead_beef";
    acc_reload <= '1';
    wait until rising_edge(clk);
    acc_reload <= '0';
    acc_imm <= x"0000_0000";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    ftw     <= x"0800_0000";
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

    -- disable count
    acc_en <= '0';
    wait until rising_edge(clk);
    wait until rising_edge(clk);

    poff_1  <= x"AAAA_BBBB";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    poff_1  <= x"0000_0000";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    poff_2  <= x"AAAA_BBBB";
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    poff_2  <= x"0000_0000";

    wait;
  end process;

  pinc_inst : phase_accumulator 
    generic map (
      ACCUMULATOR_WIDTH  => DATA_WIDTH,
      OPT_RELOAD_IMMDT   => true,
      OPT_PHASE_OFFSET_1 => true,
      OPT_PHASE_OFFSET_2 => true 
    )
    port map (
      clk        => clk,        -- : in  std_logic;
      rst_n      => rst_n,      -- : in  std_logic;
      ftw        => ftw,        -- : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
      phase      => phase,      -- : out std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
      acc_en     => acc_en,     -- : in  std_logic;
      acc_imm    => acc_imm,    -- : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
      acc_reload => acc_reload, -- : in  std_logic;
      poff_1     => poff_1,     -- : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
      poff_2     => poff_2      -- : in  std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0);
    );

end bh;
