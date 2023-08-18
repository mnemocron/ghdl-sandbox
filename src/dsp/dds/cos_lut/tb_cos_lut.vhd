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
entity tb_cos_lut is
  generic
  (
    ADDR_WIDTH : natural := 7;
    DATA_WIDTH : natural := 16
  );
end tb_cos_lut;

architecture bh of tb_cos_lut is

  component cos_lut is
    generic (
      ADDR_WIDTH : natural;
      DATA_WIDTH : natural
    );
    port (
      a : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
      o : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
  end component;

  constant CLK_PERIOD: TIME := 5 ns;

  signal clk        : std_logic;
  signal clk_count  : std_logic_vector(31 downto 0) := (others => '0');
  signal phase      : std_logic_vector((ADDR_WIDTH-1) downto 0) := (others => '0');
  signal amplitude  : std_logic_vector((DATA_WIDTH-1) downto 0) := (others => '0');
begin

  -- generate clk signal
  p_clk_gen : process
  begin
   clk <= '1';
   wait for (CLK_PERIOD / 2);
   clk <= '0';
   wait for (CLK_PERIOD / 2);
   clk_count <= std_logic_vector(unsigned(clk_count) + 1);
  end process;

  phase <= clk_count((ADDR_WIDTH-1) downto 0);


  lut_inst : cos_lut 
    generic map (
      ADDR_WIDTH => ADDR_WIDTH,
      DATA_WIDTH => DATA_WIDTH
    )
    port map (
      a => phase, -- : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
      o => amplitude -- : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );

end bh;
