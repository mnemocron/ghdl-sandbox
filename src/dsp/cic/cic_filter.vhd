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
    CIC_DELAY_LENGTH : natural := 5;
    OPT_PIPELINE_REG : boolean := false;
    OPT_INREG        : boolean := false;
    OPT_OUTREG       : boolean := false
  );
  port (
    clk   : in  std_logic;
    din   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
    dout  : out std_logic_vector((DATA_WIDTH-1) downto 0)
  );
end cic_filter;

architecture arch_imp of cic_filter is

  type t_vec_array is array (0 to (CIC_DELAY_LENGTH-1)) of std_logic_vector((DATA_WIDTH-1) downto 0);
  signal delay_taps     : t_vec_array := (others=>(others=>'0'));  

  signal s_din          : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_din_reg      : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_dout         : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_dout_reg     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_comb_sum     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_comb         : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_intg_sum     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');
  signal s_intg_dly     : std_logic_vector((DATA_WIDTH-1) downto 0 ) := (others => '0');

begin

  -- s_comb_sum <= std_logic_vector( resize(signed(s_din) - signed(delay_taps(CIC_DELAY_LENGTH-1)), s_comb_sum'length) );
  -- s_intg_sum <= std_logic_vector( resize(signed(s_comb) + signed(s_intg_dly), s_intg_sum'length) );
  s_comb_sum <= std_logic_vector( signed(s_din) - signed(delay_taps(CIC_DELAY_LENGTH-1)) );
  s_intg_sum <= std_logic_vector( signed(s_comb)/2 + signed(s_intg_dly)/2 );

  p_single_tap : process(clk)
  begin
    if rising_edge(clk) then
      delay_taps(0) <= s_din;
      s_intg_dly <= s_intg_sum;
    end if;
  end process;

  gen_tap_delays :
   for J in 1 to (CIC_DELAY_LENGTH-2) generate
     p_tap_delay_reg : process(clk)
      begin
        if rising_edge(clk) then
          delay_taps(J+1) <= delay_taps(J);
        end if;
      end process;
  end generate;

  -- optional intermediate register
  gen_reg : if OPT_PIPELINE_REG generate
    p_reg : process(clk)
    begin
      if rising_edge(clk) then
        s_comb <= s_comb_sum;
      end if;
    end process;
  end generate;
  -- no intermediate register to have a 3-input sum that can be handled in a single CLB LUT in Xilinx
  gen_no_reg : if not OPT_PIPELINE_REG generate
    s_comb <= s_comb_sum;
  end generate;

  -- optional input register
  gen_in_reg : if OPT_INREG generate
    p_reg : process(clk)
    begin
      s_din <= s_din_reg;
      if rising_edge(clk) then
        s_din_reg <= din;
      end if;
    end process;
  end generate;
  
  gen_in_no_reg : if not OPT_INREG generate
    s_din <= din;
  end generate;

  -- optional output register
  gen_out_reg : if OPT_OUTREG generate
    dout <= s_intg_dly;
  end generate;
  
  gen_out_no_reg : if not OPT_OUTREG generate
    dout <= s_intg_sum;
  end generate;

end arch_imp;
