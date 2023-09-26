----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-09-26
-- Design Name:    pause_req_cdc_ctrl
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL 4.0.0-dev
-- Description:    
-- 
-- Dependencies:   
-- 
-- Revision:
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- simulate both with OPT_DATA_REG = True / False
entity tb_pause_req_cdc_ctrl is
  generic
  (
    PAUSE_WIDTH  : natural := 9
  );
end tb_pause_req_cdc_ctrl;

architecture bh of tb_pause_req_cdc_ctrl is

  component pause_req_cdc_ctrl is
    generic (
      PAUSE_WIDTH  : natural := 9
    );
    port (
      rx_clk           : in  std_logic;
      tx_clk           : in  std_logic;
      i_pause_req      : in  std_logic_vector((PAUSE_WIDTH-1) downto 0);
      ernic_pause_req  : out std_logic_vector((PAUSE_WIDTH-1) downto 0);
      custom_pause_req : out std_logic_vector((PAUSE_WIDTH-1) downto 0);
      en_ernic_pause   : in  std_logic;
      en_custom_pause  : in  std_logic
    );
  end component;

  constant TX_CLK_PERIOD: TIME := 3.103 ns; -- 322.265625
  constant RX_CLK_PERIOD: TIME := 3.102 ns; 

  signal tx_clk     : std_logic;
  signal rx_clk     : std_logic;

  signal tx_clk_count  : unsigned(31 downto 0) := (others => '0');
  signal rx_clk_count  : unsigned(31 downto 0) := (others => '0');

  signal cmac_pause_req : std_logic_vector((PAUSE_WIDTH-1) downto 0) := (others => '0');
  signal pause_req_to_ernic : std_logic_vector((PAUSE_WIDTH-1) downto 0) := (others => '0');
  signal pause_req_to_custm : std_logic_vector((PAUSE_WIDTH-1) downto 0) := (others => '0');
  signal en_ernic : std_logic := '0';
  signal en_custm : std_logic := '0';



begin
  -- generate clk signal
  p_tx_clk_gen : process
  begin
   tx_clk <= '1';
   wait for (TX_CLK_PERIOD / 2);
   tx_clk <= '0';
   wait for (TX_CLK_PERIOD / 2);
   tx_clk_count <= tx_clk_count + 1;
  end process;

  p_rx_clk_gen : process
  begin
   rx_clk <= '1';
   wait for (RX_CLK_PERIOD / 2);
   rx_clk <= '0';
   wait for (RX_CLK_PERIOD / 2);
   rx_clk_count <= rx_clk_count + 1;
  end process;

  p_test : process(rx_clk)
  begin
    if rx_clk_count = 2 then
      en_ernic <= '1';
    end if;
    if rx_clk_count = 5 then
      cmac_pause_req(3) <= '1';
    end if;
    if rx_clk_count = 12 then
      cmac_pause_req(3) <= '0';
    end if;
    if rx_clk_count = 15 then
      en_ernic <= '0';
    end if;

    if rx_clk_count = 20 then
      en_custm <= '1';
    end if;
    if rx_clk_count = 25 then
      cmac_pause_req(3) <= '1';
    end if;
    if rx_clk_count = 34 then
      cmac_pause_req(3) <= '0';
    end if;
    if rx_clk_count = 39 then
      en_custm <= '0';
    end if;

  end process;


  pinc_inst : pause_req_cdc_ctrl 
    generic map (
      PAUSE_WIDTH  => PAUSE_WIDTH
    )
    port map (
      rx_clk           => rx_clk,
      tx_clk           => tx_clk,
      i_pause_req      => cmac_pause_req,
      ernic_pause_req  => pause_req_to_ernic,
      custom_pause_req => pause_req_to_custm,
      en_ernic_pause   => en_ernic,
      en_custom_pause  => en_custm
    );

end bh;
