----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-07-06
-- Design Name:    reset_deasert_sync
-- Module Name:    reset_deasert_sync
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  Xilinx Vivado 2021.2
--                 GHDL 4.0.0-dev 
--                 cocotb-config 1.8.0
--                 gcc (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0
--                 GNU Make 4.2.1
-- Description:    asynchronous assertion, synchronous deassertion 
--                 of active low reset
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

entity reset_deasert_sync is
  port (
    clk          : in  std_logic;
    i_resetn     : in  std_logic;
    o_resetn     : out std_logic
  );
end reset_deasert_sync;

architecture arch_imp of reset_deasert_sync is
  signal rst_reg  : std_logic := '0';
  signal rst_comb : std_logic := '0';
begin
  p_cdc : process(i_resetn, clk)
  begin
    if rst_comb = '0' then
      if rising_edge(clk) then
        rst_reg <= i_resetn;
      end if;
    end if;
  end process;

  rst_comb <= i_resetn and rst_reg;
  o_resetn <= rst_comb;

end arch_imp;
