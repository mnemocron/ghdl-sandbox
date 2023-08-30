----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-21
-- Design Name:    cic_filter
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

entity cic_filter is
  generic (
    DATA_WIDTH       : natural := 16;
    CIC_DELAY_LENGTH : natural := 5
  );
  port (
    clk   : in  std_logic;
    din   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    dout  : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end cic_filter;

architecture arch_imp of cic_filter is

  component cic_tap is
    generic (
      DATA_WIDTH  : natural := 16;
      OPT_SUM_REG : boolean := false
    );
    port (
      clk   : in  std_logic;
      din   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      dout  : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
  end component;

  type t_vec_array is array (0 to (CIC_DELAY_LENGTH-2)) of std_logic_vector((DATA_WIDTH-1) downto 0);
  signal d_values     : t_vec_array := (others=>(others=>'0'));  
  signal d_values_reg : t_vec_array := (others=>(others=>'0'));  

begin
  
  tap_din_inst : cic_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      OPT_SUM_REG => false  
    )
    port map (
      clk   => clk,
      din   => din, 
      dout  => d_values(0)
    );

  gen_filter_inst :
   for J in 1 to (CIC_DELAY_LENGTH-2) generate
   tap_inst : cic_tap
     generic map (
       DATA_WIDTH  => DATA_WIDTH,
       OPT_SUM_REG => false  
     )
     port map (
       clk   => clk,
       din   => d_values_reg(J-1),
       dout  => d_values(J)
     );
  end generate;

  tap_dout_inst : cic_tap
    generic map (
      DATA_WIDTH  => DATA_WIDTH,
      OPT_SUM_REG => false  
    )
    port map (
      clk   => clk,
      din   => d_values_reg(CIC_DELAY_LENGTH-2),
      dout  => dout
    );

  gen_value_reg :
    for J in 0 to (CIC_DELAY_LENGTH-2) generate
      process(clk)
      begin
        if rising_edge(clk) then
          d_values_reg(J) <= d_values(J);
        end if;
      end process;
  end generate;

end arch_imp;
