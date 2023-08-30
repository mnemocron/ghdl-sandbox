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
entity tb_transaction_flow_control is
  generic
  (
      ACCUMULATOR_WIDTH  : natural := 8
  );
end tb_transaction_flow_control;

architecture bh of tb_transaction_flow_control is

  component transaction_flow_control is
    generic (
      ACCUMULATOR_WIDTH  : natural := 48
    );
    port (
      clk_gt      : in std_logic;
      clk_axis    : in std_logic;
      en_cnt_up   : in std_logic;
      en_cnt_dn   : in std_logic;
      pause_level : in std_logic_vector(7 downto 0);
      pause_request : out std_logic
    );
  end component;

  constant GT_CLK_PERIOD: TIME := 3.103 ns; -- 322.265625
  constant RX_CLK_PERIOD: TIME := 8 ns;     -- 125

  signal gt_clk     : std_logic;
  signal rx_clk     : std_logic;

  signal gt_clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  signal rx_clk_count  : std_logic_vector(31 downto 0) := (others => '0');

  signal pause_level  : std_logic_vector(7 downto 0) := (others => '0');
  signal xoff : std_logic;
  signal en_tx : std_logic;
  signal en_rx : std_logic;
  signal ctrl_tx : std_logic;

  signal pause_d1 : std_logic := '0';
  signal pause_d2 : std_logic := '0';
  signal pause_d3 : std_logic := '0';
  signal pause_d4 : std_logic := '0';
  signal pause_d5 : std_logic := '0';
  signal pause_d6 : std_logic := '0';
  signal pause_d7 : std_logic := '0';

begin
  -- generate clk signal
  p_gt_clk_gen : process
  begin
   gt_clk <= '1';
   wait for (GT_CLK_PERIOD / 2);
   gt_clk <= '0';
   wait for (GT_CLK_PERIOD / 2);
   gt_clk_count <= std_logic_vector(unsigned(gt_clk_count) + 1);
  end process;

  p_rx_clk_gen : process
  begin
   rx_clk <= '1';
   wait for (RX_CLK_PERIOD / 2);
   rx_clk <= '0';
   wait for (RX_CLK_PERIOD / 2);
   rx_clk_count <= std_logic_vector(unsigned(rx_clk_count) + 1);
  end process;

  p_test : process(rx_clk)
  begin
    if unsigned(rx_clk_count) = 2 then
      pause_level <= x"30";
      ctrl_tx <= '1';
      en_rx <= '1';
    end if;
    if unsigned(rx_clk_count) = 72 then
      pause_level <= x"08";
    end if;
  end process;

  p_pause : process(rx_clk)
  begin
    if rising_edge(rx_clk) then
      pause_d1 <= xoff;
      pause_d2 <= pause_d1;
      pause_d3 <= pause_d2;
      pause_d4 <= pause_d3;
      pause_d5 <= pause_d4;
      pause_d6 <= pause_d5;
      pause_d7 <= pause_d6;
    end if;
  end process;

  en_tx <= ctrl_tx and (not pause_d7);

  pinc_inst : transaction_flow_control 
    generic map (
      ACCUMULATOR_WIDTH  => ACCUMULATOR_WIDTH
    )
    port map (
      clk_gt        => gt_clk,
      clk_axis      => rx_clk,
      en_cnt_up     => en_tx,
      en_cnt_dn     => en_rx,
      pause_level   => pause_level,
      pause_request => xoff
    );

end bh;
