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
entity tb_transaction_augmented_flow_control is
  generic
  (
      ACCUMULATOR_WIDTH  : natural := 32;
      THESHOLD_WIDTH     : natural := 16
  );
end tb_transaction_augmented_flow_control;

architecture bh of tb_transaction_augmented_flow_control is

  component dummy_sender is
    port (
      tx_clk         : in  std_logic;
      tvalid         : out std_logic;
      en             : in  std_logic;
      ctl_pause_req  : in  std_logic;
      burst_length   : in  std_logic_vector(7 downto 0);
      burst_pause    : in  std_logic_vector(7 downto 0);
      en_immdt_pause : in  std_logic;
      latency        : in  std_logic_vector(7 downto 0)
    );
  end component;

  component transaction_augmented_flow_control is
    generic (
      ACCUMULATOR_WIDTH  : natural;
      THESHOLD_WIDTH     : natural
    );
    port (
      rx_usrclk2       : in  std_logic;
      tx_usrclk2       : in  std_logic;
      axis_aclk        : in  std_logic;
      rx_tvalid        : in  std_logic;
      tx_tvalid        : in  std_logic;
      thresh_full      : in  std_logic_vector((THESHOLD_WIDTH-1) downto 0);
      thresh_empty     : in  std_logic_vector((THESHOLD_WIDTH-1) downto 0);
      ctl_tx_pause_req : out std_logic
    );
  end component;

  constant TX_USRCLK_PERIOD: TIME := 3.103 ns; -- 322.265625
  constant RX_USRCLK_PERIOD: TIME := 3.102 ns; -- slightly off
  constant AXI_CLK_PERIOD: TIME := 8 ns;     -- 125

  signal tx_usrclk     : std_logic;
  signal rx_usrclk     : std_logic;
  signal axis_aclk     : std_logic;

  signal tx_usrclk_count  : unsigned(31 downto 0) := (others => '0');
  signal rx_usrclk_count  : unsigned(31 downto 0) := (others => '0');
  signal axis_aclk_count  : unsigned(31 downto 0) := (others => '0');

  signal thresh_xoff      : unsigned((THESHOLD_WIDTH-1) downto 0) := (others => '0');
  signal thresh_xon       : unsigned((THESHOLD_WIDTH-1) downto 0) := (others => '0');

  signal tx_valid            : std_logic := '0';
  signal en_tx               : std_logic := '0';
  signal pause_req           : std_logic := '0';

  signal en_rx_delay : std_logic_vector(127 downto 0) := (others => '0');

  signal conf_burst_lengt  : unsigned(7 downto 0) := (others => '0');
  signal conf_burst_reload : unsigned(7 downto 0) := (others => '0');
  signal conf_latency      : unsigned(7 downto 0) := (others => '0');

begin
  -- generate clk signal
  p_tx_usrclk_gen : process
  begin
   tx_usrclk <= '0';
   wait for (TX_USRCLK_PERIOD / 2);
   tx_usrclk <= '1';
   wait for (TX_USRCLK_PERIOD / 2);
   tx_usrclk_count <= tx_usrclk_count + 1;
  end process;

  p_rx_usrclk_gen : process
  begin
   rx_usrclk <= '0';
   wait for (RX_USRCLK_PERIOD / 2);
   rx_usrclk <= '1';
   wait for (RX_USRCLK_PERIOD / 2);
   rx_usrclk_count <= rx_usrclk_count + 1;
  end process;

  p_axis_aclk_gen : process
  begin
   axis_aclk <= '0';
   wait for (AXI_CLK_PERIOD / 2);
   axis_aclk <= '1';
   wait for (AXI_CLK_PERIOD / 2);
   axis_aclk_count <= axis_aclk_count + 1;
  end process;

  p_stimuli : process(rx_usrclk)
  begin
    if rising_edge(rx_usrclk) then
      if rx_usrclk_count = 1 then
        thresh_xoff <= to_unsigned(12, THESHOLD_WIDTH);
        thresh_xon  <= to_unsigned(10, THESHOLD_WIDTH);
      end if;

      if rx_usrclk_count = 2 then
        conf_latency <= to_unsigned(107, 8);
        conf_burst_lengt  <= to_unsigned(64, 8);
        conf_burst_reload <= to_unsigned( 4, 8);
      end if;

      if rx_usrclk_count = 3 then
        en_tx <= '1';
      end if;

      if rx_usrclk_count = 28 then
        en_tx <= '0';
      end if;

    end if;
  end process;

  sender_inst : dummy_sender 
    port map (
      tx_clk         => rx_usrclk,
      tvalid         => tx_valid,
      en             => en_tx,
      ctl_pause_req  => pause_req,
      burst_length   => std_logic_vector(conf_burst_lengt),
      burst_pause    => std_logic_vector(conf_burst_reload),
      en_immdt_pause => '0',
      latency        => std_logic_vector(conf_latency)
    );

  flow_control_inst : transaction_augmented_flow_control 
    generic map (
      ACCUMULATOR_WIDTH  => ACCUMULATOR_WIDTH,
      THESHOLD_WIDTH     => THESHOLD_WIDTH
    )
    port map (
      rx_usrclk2       => rx_usrclk,
      tx_usrclk2       => tx_usrclk,
      axis_aclk        => axis_aclk,
      rx_tvalid        => tx_valid,
      tx_tvalid        => en_rx_delay(7),
      thresh_full      => std_logic_vector(thresh_xoff),
      thresh_empty     => std_logic_vector(thresh_xon),
      ctl_tx_pause_req => pause_req
    );

end bh;
