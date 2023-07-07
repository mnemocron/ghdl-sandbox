----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  
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
entity divu10_tb is
  generic
  (
    DATA_WIDTH       : integer := 32
  );
end divu10_tb;

architecture bh of divu10_tb is
  -- DUT component declaration
  component divu10 is
    generic (
      DATA_WIDTH       : integer
    );
    port (
      aclk       : in  std_logic;
      aresetn    : in  std_logic;
      s00_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      s00_tvalid : in  std_logic;
      s00_tready : out std_logic;
      m00_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
      m00_tvalid : out std_logic
    );
  end component;

  constant CLK_0_PERIOD: TIME := 5 ns;
  constant CLK_1_PERIOD: TIME := 3.3 ns;

  signal clk_0 : std_logic;
  signal rst_n : std_logic;

  signal sig_tx : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sig_rx : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_start : std_logic;
  signal s_done  : std_logic;

  signal clk_0_count : std_logic_vector(7 downto 0) := (others => '0');
begin

  -- generate clk signal
  p_clk_0_gen : process
  begin
   clk_0 <= '1';
   wait for (CLK_0_PERIOD / 2);
   clk_0 <= '0';
   wait for (CLK_0_PERIOD / 2);
   clk_0_count <= std_logic_vector(unsigned(clk_0_count) + 1);
  end process;

  -- generate initial reset
  p_reset_gen : process
  begin 
    rst_n <= '0';
    wait until rising_edge(clk_0);
    wait for (CLK_0_PERIOD / 4);
    rst_n <= '1';
    wait;
  end process;

  -- generate signal thingie
  p_tx : process(clk_0)
  begin 
    if rising_edge(clk_0) then
      if unsigned(clk_0_count) = 1 then
        sig_tx <= (others => '0');
        s_start <= '0';
      end if;
      if unsigned(clk_0_count) = 5 then
        sig_tx(7+16 downto 0+16) <= (others => '1');
        --sig_tx(7) <= '1';
        s_start <= '1';
      end if;
      if unsigned(clk_0_count) = 6 then
        sig_tx <= (others => '0');
        s_start <= '0';
      end if;

    end if;
  end process;

  --
  
-- DUT instance and connections
  divu10_inst : divu10
    generic map (
      DATA_WIDTH   => DATA_WIDTH
    )
    port map (
      aclk     => clk_0,
      aresetn  => rst_n,
      s00_tdata  => sig_tx,
      s00_tvalid => s_start,
      s00_tready => open,
      m00_tdata  => sig_rx,
      m00_tvalid => s_done
    );
end bh;
