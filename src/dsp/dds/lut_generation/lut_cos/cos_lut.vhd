----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    cos_lut
-- Module Name:    cos_lut
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

entity cos_lut is
  generic (
    ADDR_WIDTH : natural := 7;
    DATA_WIDTH : natural := 16
  );
  port (
    a : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
    o : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end cos_lut;

architecture arch_imp of cos_lut is

  type vector_of_signed16 is array (natural range <>) of signed(15 downto 0);
  
  constant lut_data : vector_of_signed16(0 to 127) := (
    to_signed( 16#7EB8#,16), to_signed( 16#7E91#,16), to_signed( 16#7E1C#,16), to_signed( 16#7D59#,16), 
    to_signed( 16#7C48#,16), to_signed( 16#7AEC#,16), to_signed( 16#7943#,16), to_signed( 16#774F#,16), 
    to_signed( 16#7512#,16), to_signed( 16#728D#,16), to_signed( 16#6FC1#,16), to_signed( 16#6CB0#,16), 
    to_signed( 16#695D#,16), to_signed( 16#65C8#,16), to_signed( 16#61F4#,16), to_signed( 16#5DE4#,16), 
    to_signed( 16#599A#,16), to_signed( 16#5519#,16), to_signed( 16#5063#,16), to_signed( 16#4B7C#,16), 
    to_signed( 16#4666#,16), to_signed( 16#4125#,16), to_signed( 16#3BBC#,16), to_signed( 16#362E#,16), 
    to_signed( 16#307E#,16), to_signed( 16#2AB0#,16), to_signed( 16#24C8#,16), to_signed( 16#1ECA#,16), 
    to_signed( 16#18B8#,16), to_signed( 16#1297#,16), to_signed( 16#0C6B#,16), to_signed( 16#0637#,16), 
    to_signed( 16#0000#,16), to_signed(-16#0637#,16), to_signed(-16#0C6B#,16), to_signed(-16#1297#,16), 
    to_signed(-16#18B8#,16), to_signed(-16#1ECA#,16), to_signed(-16#24C8#,16), to_signed(-16#2AB0#,16), 
    to_signed(-16#307E#,16), to_signed(-16#362E#,16), to_signed(-16#3BBC#,16), to_signed(-16#4125#,16), 
    to_signed(-16#4666#,16), to_signed(-16#4B7C#,16), to_signed(-16#5063#,16), to_signed(-16#5519#,16), 
    to_signed(-16#599A#,16), to_signed(-16#5DE4#,16), to_signed(-16#61F4#,16), to_signed(-16#65C8#,16), 
    to_signed(-16#695D#,16), to_signed(-16#6CB0#,16), to_signed(-16#6FC1#,16), to_signed(-16#728D#,16), 
    to_signed(-16#7512#,16), to_signed(-16#774F#,16), to_signed(-16#7943#,16), to_signed(-16#7AEC#,16), 
    to_signed(-16#7C48#,16), to_signed(-16#7D59#,16), to_signed(-16#7E1C#,16), to_signed(-16#7E91#,16), 
    to_signed(-16#7EB8#,16), to_signed(-16#7E91#,16), to_signed(-16#7E1C#,16), to_signed(-16#7D59#,16), 
    to_signed(-16#7C48#,16), to_signed(-16#7AEC#,16), to_signed(-16#7943#,16), to_signed(-16#774F#,16), 
    to_signed(-16#7512#,16), to_signed(-16#728D#,16), to_signed(-16#6FC1#,16), to_signed(-16#6CB0#,16), 
    to_signed(-16#695D#,16), to_signed(-16#65C8#,16), to_signed(-16#61F4#,16), to_signed(-16#5DE4#,16), 
    to_signed(-16#599A#,16), to_signed(-16#5519#,16), to_signed(-16#5063#,16), to_signed(-16#4B7C#,16), 
    to_signed(-16#4666#,16), to_signed(-16#4125#,16), to_signed(-16#3BBC#,16), to_signed(-16#362E#,16), 
    to_signed(-16#307E#,16), to_signed(-16#2AB0#,16), to_signed(-16#24C8#,16), to_signed(-16#1ECA#,16), 
    to_signed(-16#18B8#,16), to_signed(-16#1297#,16), to_signed(-16#0C6B#,16), to_signed(-16#0637#,16), 
    to_signed( 16#0000#,16), to_signed( 16#0637#,16), to_signed( 16#0C6B#,16), to_signed( 16#1297#,16), 
    to_signed( 16#18B8#,16), to_signed( 16#1ECA#,16), to_signed( 16#24C8#,16), to_signed( 16#2AB0#,16), 
    to_signed( 16#307E#,16), to_signed( 16#362E#,16), to_signed( 16#3BBC#,16), to_signed( 16#4125#,16), 
    to_signed( 16#4666#,16), to_signed( 16#4B7C#,16), to_signed( 16#5063#,16), to_signed( 16#5519#,16), 
    to_signed( 16#599A#,16), to_signed( 16#5DE4#,16), to_signed( 16#61F4#,16), to_signed( 16#65C8#,16), 
    to_signed( 16#695D#,16), to_signed( 16#6CB0#,16), to_signed( 16#6FC1#,16), to_signed( 16#728D#,16), 
    to_signed( 16#7512#,16), to_signed( 16#774F#,16), to_signed( 16#7943#,16), to_signed( 16#7AEC#,16), 
    to_signed( 16#7C48#,16), to_signed( 16#7D59#,16), to_signed( 16#7E1C#,16), to_signed( 16#7E91#,16)
  );

  -- signal asdf     : std_logic_vector( (ACCUMULATOR_WIDTH-1) downto 0 ) := (others => '0');
  signal selector : unsigned((ADDR_WIDTH-1) downto 0) := (others => '0');
begin
  selector <= unsigned(a);
  o <= std_logic_vector(lut_data(to_integer(selector)));

end arch_imp;
