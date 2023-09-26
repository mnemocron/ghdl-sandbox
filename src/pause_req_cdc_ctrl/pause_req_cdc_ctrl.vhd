----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-09-26
-- Design Name:    pause_req_cdc_ctrl
-- Module Name:    pause_req_cdc_ctrl
-- Project Name:   
-- Target Devices: Xilinx UltraScale+
-- Tool Versions:  GHDL 4.0.0-dev
-- Description:    
-- Dependencies:   
-- 
-- Revision:
-- Additional Comments:
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

entity pause_req_cdc_ctrl is
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
end pause_req_cdc_ctrl;

architecture arch_imp of pause_req_cdc_ctrl is



  signal s_pause_req : std_logic_vector((PAUSE_WIDTH-1) downto 0) := (others => '0');
  signal s_pause_req_async : std_logic_vector((PAUSE_WIDTH-1) downto 0) := (others => '0');
  signal s_pause_req_cdc   : std_logic_vector((PAUSE_WIDTH-1) downto 0) := (others => '0');

  attribute ASYNC_REG : boolean;
  attribute ASYNC_REG of s_pause_req_async : signal is TRUE;
  attribute ASYNC_REG of s_pause_req_cdc   : signal is TRUE;

begin

  p_inreg : process(rx_clk)
  begin
    if rising_edge(rx_clk) then
      s_pause_req <= i_pause_req;
    end if;
  end process;

  p_cdc : process(tx_clk)
  begin
    if rising_edge(tx_clk) then
      s_pause_req_async <= s_pause_req;
      s_pause_req_cdc <= s_pause_req_async;
    end if;
  end process;

  p_and_ernic : process (s_pause_req,en_ernic_pause)
      variable tmp : std_logic_vector((PAUSE_WIDTH-1) downto 0);
  begin
      for I in (PAUSE_WIDTH-1) downto 0 loop
          tmp(I) := s_pause_req(I) and en_ernic_pause;
      end loop;
      ernic_pause_req <= tmp;
  end process;

  p_and_custom : process (s_pause_req,en_custom_pause)
      variable tmp : std_logic_vector((PAUSE_WIDTH-1) downto 0);
  begin
      for I in (PAUSE_WIDTH-1) downto 0 loop
          tmp(I) := s_pause_req(I) and en_custom_pause;
      end loop;
      custom_pause_req <= tmp;
  end process;

end arch_imp;
