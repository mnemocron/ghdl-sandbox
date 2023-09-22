----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-09-22
-- Design Name:    vector_or_mux
-- Module Name:    vector_or_mux
-- Project Name:   
-- Target Devices: Xilinx UltraScale+
-- Tool Versions:  
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

entity vector_or_mux is
  generic (
    MUX_WIDTH  : natural := 8
  );
  port (
    a    : in  std_logic_vector((MUX_WIDTH-1) downto 0);
    b    : in  std_logic_vector((MUX_WIDTH-1) downto 0);
    en_a : in  std_logic;
    en_b : in  std_logic;
    y    : out std_logic_vector((MUX_WIDTH-1) downto 0)
  );
end vector_or_mux;

architecture arch_imp of vector_or_mux is

  signal prod : std_logic_vector((MUX_WIDTH-1) downto 0) := (others => '0');
  signal sel  : std_logic_vector(1 downto 0);

begin

  process (a,b) is
      variable tmp : std_logic_vector((MUX_WIDTH-1) downto 0);
  begin
      for I in (MUX_WIDTH-1) downto 0 loop
          tmp(I) := a(I) or b(I);
      end loop;
      prod <= tmp;
  end process;

  sel(0) <= en_a;
  sel(1) <= en_b;

  y <= a when sel ="01" else
       b when sel ="10" else
       prod when sel = "11" else
       (others => '0');

end arch_imp;
