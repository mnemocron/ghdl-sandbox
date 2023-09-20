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
entity tb_dummy_sender is

end tb_dummy_sender;

architecture bh of tb_dummy_sender is

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

  constant TX_USRCLK_PERIOD: TIME := 3.103 ns; -- 322.265625

  signal tx_usrclk     : std_logic;

  signal tx_usrclk_count  : unsigned(31 downto 0) := (others => '0');
  signal rx_usrclk_count  : unsigned(31 downto 0) := (others => '0');
  signal axis_aclk_count  : unsigned(31 downto 0) := (others => '0');

  signal tx_pause_req : std_logic := '0';
  signal conf_burst_lengt  : unsigned(7 downto 0) := (others => '0');
  signal conf_burst_reload : unsigned(7 downto 0) := (others => '0');
  signal conf_latency      : unsigned(7 downto 0) := (others => '0');

  signal tx_valid : std_logic;

begin
  -- generate clk signal
  p_tx_usrclk_gen : process
  begin
   tx_usrclk <= '1';
   wait for (TX_USRCLK_PERIOD / 2);
   tx_usrclk <= '0';
   wait for (TX_USRCLK_PERIOD / 2);
   tx_usrclk_count <= tx_usrclk_count + 1;
  end process;

  p_stimuli : process(tx_usrclk)
  begin
    if rising_edge(tx_usrclk) then 

      if tx_usrclk_count = 2 then 
        conf_burst_lengt  <= to_unsigned(64, 8);
        conf_burst_reload <= to_unsigned( 2, 8);
      end if;

      if tx_usrclk_count = 22 then 
        tx_pause_req <= '1';
      end if;

      if tx_usrclk_count = 122 then 
        tx_pause_req <= '0';
      end if;

      if tx_usrclk_count = 222 then 
        conf_latency <= to_unsigned(98, 8);
        tx_pause_req <= '1';
      end if;
      if tx_usrclk_count = 422 then 
        conf_latency <= to_unsigned(98, 8);
        tx_pause_req <= '1';
      end if;

    end if;
  end process;

  dummy_inst : dummy_sender 
    port map (
      tx_clk         => tx_usrclk,
      tvalid         => tx_valid,
      en             => '1',
      ctl_pause_req  => tx_pause_req,
      burst_length   => std_logic_vector(conf_burst_lengt),
      burst_pause    => std_logic_vector(conf_burst_reload),
      en_immdt_pause => '0',
      latency        => std_logic_vector(conf_latency)
    );

end bh;
