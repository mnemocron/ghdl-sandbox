----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-07-07
-- Design Name:    reg_slice
-- Module Name:    reg_slice
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  Xilinx Vivado 2021.2
--                 GHDL 4.0.0-dev 
--                 cocotb-config 1.8.0
--                 gcc (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0
--                 GNU Make 4.2.1
-- Description:    simple register slice with configurable width
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

entity reg_slice is
  generic (
    REG_WIDTH  : integer := 32
  );
  port (
    clk : in  std_logic;
    i   : in  std_logic_vector(REG_WIDTH-1 downto 0);
    o   : out std_logic_vector(REG_WIDTH-1 downto 0)
  );
end reg_slice;

architecture arch_imp of reg_slice is
  signal reg_out : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
begin

  o <= reg_out;

  p_reg : process(clk)
  begin
    if rising_edge(clk) then
      reg_out <= i;
    end if;
  end process;

end arch_imp;
