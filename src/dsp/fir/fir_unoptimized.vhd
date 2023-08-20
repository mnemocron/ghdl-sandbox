----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-20
-- Design Name:    fir_unoptimized
-- Module Name:    
-- Project Name:   
-- Target Devices: Xilinx DSP48E2
-- Tool Versions:  GHDL 4.0.0-dev
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

entity fir_unoptimized is
  generic (
    DATA_WIDTH  : natural := 16;
    COEFF_WIDTH : natural := 16
  );
  port (
    clk  : in  std_logic;
    din  : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    dout : out std_logic_vector((DATA_WIDTH-1) downto 0);
    c0   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
    c1   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
    c2   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
    c3   : in  std_logic_vector((COEFF_WIDTH-1) downto 0);
    c4   : in  std_logic_vector((COEFF_WIDTH-1) downto 0)
  );
end fir_unoptimized;

architecture arch_imp of fir_unoptimized is

  component fir_tap is
    generic (
      DATA_WIDTH  : natural;
      COEFF_WIDTH : natural
    );
    port (
      clk   : in  std_logic;
      xn    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      xnp   : out std_logic_vector((DATA_WIDTH-1) downto 0);
      yn    : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      ynp   : out std_logic_vector((DATA_WIDTH-1) downto 0);
      coeff : in  std_logic_vector((COEFF_WIDTH-1) downto 0)
    );
  end component;

  signal d0,d1,d2,d3,d4 : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');
  signal y0,y1,y2,y3,y4 : std_logic_vector((DATA_WIDTH -1) downto 0 ) := (others => '0');

begin

  dout <= y4;
  
  tap_0_inst : fir_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      COEFF_WIDTH => COEFF_WIDTH  
    )
    port map (
      clk   => clk,
      xn    => din,
      xnp   => d0,
      yn    => (others => '0'),
      ynp   => y0,
      coeff => c0
    );

  tap_1_inst : fir_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      COEFF_WIDTH => COEFF_WIDTH  
    )
    port map (
      clk   => clk,
      xn    => d0,
      xnp   => d1,
      yn    => y0,
      ynp   => y1,
      coeff => c1
    );

  tap_2_inst : fir_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      COEFF_WIDTH => COEFF_WIDTH  
    )
    port map (
      clk   => clk,
      xn    => d1,
      xnp   => d2,
      yn    => y1,
      ynp   => y2,
      coeff => c2
    );

  tap_3_inst : fir_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      COEFF_WIDTH => COEFF_WIDTH  
    )
    port map (
      clk   => clk,
      xn    => d2,
      xnp   => d3,
      yn    => y2,
      ynp   => y3,
      coeff => c3
    );

  tap_4_inst : fir_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      COEFF_WIDTH => COEFF_WIDTH  
    )
    port map (
      clk   => clk,
      xn    => d3,
      xnp   => d4,
      yn    => y3,
      ynp   => y4,
      coeff => c4
    );

end arch_imp;
