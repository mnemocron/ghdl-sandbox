----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-09-22
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL
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

entity tb_vector_or_mux is
  generic
  (
      MUX_WIDTH  : natural := 8
  );
end tb_vector_or_mux;

architecture bh of tb_vector_or_mux is

  component vector_or_mux is
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
  end component;

  constant RX_CLK_PERIOD: TIME := 10 ns;
  signal rx_clk     : std_logic;
  signal rx_clk_count : unsigned(31 downto 0) := (others => '0');

  signal sa,sb,sy : std_logic_vector((MUX_WIDTH-1) downto 0) := (others => '0');
  signal ea,eb : std_logic := '0';

begin
  -- generate clk signal
  p_rx_clk_gen : process
  begin
   rx_clk <= '1';
   wait for (RX_CLK_PERIOD / 2);
   rx_clk <= '0';
   wait for (RX_CLK_PERIOD / 2);
   rx_clk_count <= rx_clk_count+1;
  end process;

  sa <= std_logic_vector(rx_clk_count(7 downto 0));
  sb <= std_logic_vector(rx_clk_count(9 downto 2));

  p_test : process(rx_clk)
  begin
    if rx_clk_count = 2 then
      ea <= '1';
    end if;
    if rx_clk_count = 7 then
      eb <= '1';
    end if;
    if rx_clk_count = 15 then
      ea <= '0';
    end if;
    if rx_clk_count = 23 then
      eb <= '0';
    end if;
  end process;

  pinc_inst : vector_or_mux 
    generic map (
      MUX_WIDTH  => MUX_WIDTH
    )
    port map (
      a    => sa,
      b    => sb,
      en_a => ea,
      en_b => eb,
      y    => sy
    );

end bh;
