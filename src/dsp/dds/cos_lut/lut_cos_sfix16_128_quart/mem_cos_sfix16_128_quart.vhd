----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    
-- Design Name:    mem_cos_sfix16_128_quart
-- Module Name:    mem_cos_sfix16_128_quart
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

entity mem_cos_sfix16_128_quart is
  generic (
    ADDR_WIDTH : natural := 7;
    DATA_WIDTH : natural := 16
  );
  port (
    a : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
    o : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end mem_cos_sfix16_128_quart;

architecture arch_imp of mem_cos_sfix16_128_quart is

  type vector_of_signed16 is array (natural range <>) of signed(15 downto 0);
  
  constant lut_data : vector_of_signed16(0 to 127) := (
    to_signed( 16#7EB8#,16), to_signed( 16#7EB5#,16), to_signed( 16#7EAE#,16), to_signed( 16#7EA2#,16), 
    to_signed( 16#7E91#,16), to_signed( 16#7E7B#,16), to_signed( 16#7E60#,16), to_signed( 16#7E40#,16), 
    to_signed( 16#7E1C#,16), to_signed( 16#7DF2#,16), to_signed( 16#7DC4#,16), to_signed( 16#7D91#,16), 
    to_signed( 16#7D59#,16), to_signed( 16#7D1C#,16), to_signed( 16#7CDA#,16), to_signed( 16#7C94#,16), 
    to_signed( 16#7C48#,16), to_signed( 16#7BF8#,16), to_signed( 16#7BA4#,16), to_signed( 16#7B4A#,16), 
    to_signed( 16#7AEC#,16), to_signed( 16#7A89#,16), to_signed( 16#7A21#,16), to_signed( 16#79B4#,16), 
    to_signed( 16#7943#,16), to_signed( 16#78CD#,16), to_signed( 16#7852#,16), to_signed( 16#77D3#,16), 
    to_signed( 16#774F#,16), to_signed( 16#76C7#,16), to_signed( 16#763A#,16), to_signed( 16#75A9#,16), 
    to_signed( 16#7512#,16), to_signed( 16#7478#,16), to_signed( 16#73D9#,16), to_signed( 16#7335#,16), 
    to_signed( 16#728D#,16), to_signed( 16#71E1#,16), to_signed( 16#7130#,16), to_signed( 16#707B#,16), 
    to_signed( 16#6FC1#,16), to_signed( 16#6F03#,16), to_signed( 16#6E41#,16), to_signed( 16#6D7B#,16), 
    to_signed( 16#6CB0#,16), to_signed( 16#6BE2#,16), to_signed( 16#6B0F#,16), to_signed( 16#6A38#,16), 
    to_signed( 16#695D#,16), to_signed( 16#687D#,16), to_signed( 16#679A#,16), to_signed( 16#66B3#,16), 
    to_signed( 16#65C8#,16), to_signed( 16#64D9#,16), to_signed( 16#63E6#,16), to_signed( 16#62EF#,16), 
    to_signed( 16#61F4#,16), to_signed( 16#60F6#,16), to_signed( 16#5FF4#,16), to_signed( 16#5EEE#,16), 
    to_signed( 16#5DE4#,16), to_signed( 16#5CD7#,16), to_signed( 16#5BC6#,16), to_signed( 16#5AB2#,16), 
    to_signed( 16#599A#,16), to_signed( 16#587F#,16), to_signed( 16#5760#,16), to_signed( 16#563E#,16), 
    to_signed( 16#5519#,16), to_signed( 16#53F0#,16), to_signed( 16#52C5#,16), to_signed( 16#5196#,16), 
    to_signed( 16#5063#,16), to_signed( 16#4F2E#,16), to_signed( 16#4DF6#,16), to_signed( 16#4CBA#,16), 
    to_signed( 16#4B7C#,16), to_signed( 16#4A3B#,16), to_signed( 16#48F7#,16), to_signed( 16#47B0#,16), 
    to_signed( 16#4666#,16), to_signed( 16#451A#,16), to_signed( 16#43CB#,16), to_signed( 16#4279#,16), 
    to_signed( 16#4125#,16), to_signed( 16#3FCE#,16), to_signed( 16#3E75#,16), to_signed( 16#3D1A#,16), 
    to_signed( 16#3BBC#,16), to_signed( 16#3A5C#,16), to_signed( 16#38F9#,16), to_signed( 16#3794#,16), 
    to_signed( 16#362E#,16), to_signed( 16#34C5#,16), to_signed( 16#335A#,16), to_signed( 16#31ED#,16), 
    to_signed( 16#307E#,16), to_signed( 16#2F0D#,16), to_signed( 16#2D9B#,16), to_signed( 16#2C26#,16), 
    to_signed( 16#2AB0#,16), to_signed( 16#2939#,16), to_signed( 16#27BF#,16), to_signed( 16#2645#,16), 
    to_signed( 16#24C8#,16), to_signed( 16#234B#,16), to_signed( 16#21CC#,16), to_signed( 16#204B#,16), 
    to_signed( 16#1ECA#,16), to_signed( 16#1D47#,16), to_signed( 16#1BC3#,16), to_signed( 16#1A3E#,16), 
    to_signed( 16#18B8#,16), to_signed( 16#1731#,16), to_signed( 16#15AA#,16), to_signed( 16#1421#,16), 
    to_signed( 16#1297#,16), to_signed( 16#110D#,16), to_signed( 16#0F83#,16), to_signed( 16#0DF7#,16), 
    to_signed( 16#0C6B#,16), to_signed( 16#0ADF#,16), to_signed( 16#0952#,16), to_signed( 16#07C5#,16), 
    to_signed( 16#0637#,16), to_signed( 16#04AA#,16), to_signed( 16#031C#,16), to_signed( 16#018E#,16)
  );

  signal selector : unsigned((ADDR_WIDTH-1) downto 0) := (others => '0');
begin
  selector <= unsigned(a);
  o <= std_logic_vector(lut_data(to_integer(selector)));

end arch_imp;
