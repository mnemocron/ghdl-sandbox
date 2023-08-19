----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    mem_cos_sfix16_8_quart
-- Module Name:    mem_cos_sfix16_8_quart
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  
-- Description:    
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
--use ieee.std_logic_arith.all;

entity mem_cos_sfix16_8_quart is
  generic (
    ADDR_WIDTH : natural := 3;
    DATA_WIDTH : natural := 16
  );
  port (
    a : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
    o : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end mem_cos_sfix16_8_quart;

architecture arch_imp of mem_cos_sfix16_8_quart is

  type vector_of_signed16 is array (natural range <>) of signed(15 downto 0);
  
  constant lut_data : vector_of_signed16(0 to 7) := (
    to_signed( 16#7EB8#,16), to_signed( 16#7C48#,16), to_signed( 16#7512#,16), to_signed( 16#695D#,16), 
    to_signed( 16#599A#,16), to_signed( 16#4666#,16), to_signed( 16#307E#,16), to_signed( 16#18B8#,16)
  );

  signal selector : unsigned((ADDR_WIDTH-1) downto 0) := (others => '0');
begin
  selector <= unsigned(a);
  o <= std_logic_vector(lut_data(to_integer(selector)));

end arch_imp;
