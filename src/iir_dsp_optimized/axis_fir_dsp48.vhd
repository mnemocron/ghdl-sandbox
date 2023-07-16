----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-06-16
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL 0.37
-- Description:    bidirectional AXIS pipeline register
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

entity axis_fir_dsp48 is
  generic (
    C_S_AXIS_TDATA_WIDTH  : integer := 16;
    WIDTH_COEFFICIENTS    : natural := 16;
    OPT_REG_IN            : boolean := true;
    OPT_REG_OUT           : boolean := true;
    COEF_A0               : signed  := x"0000";
    COEF_A1               : signed  := x"0000";
    COEF_A2               : signed  := x"0000";
    COEF_B0               : signed  := x"0000";
    COEF_B1               : signed  := x"0000"
  );
  port (
    AXIS_ACLK     : in  std_logic;
    S_AXIS_TVALID : in  std_logic;
    S_AXIS_TDATA  : in  std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
    S_AXIS_TREADY : out std_logic;
    M_AXIS_TVALID : out std_logic;
    M_AXIS_TDATA  : out std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
    M_AXIS_TREADY : in  std_logic
  );
end axis_fir_dsp48;

architecture arch_imp of axis_fir_dsp48 is

  component iir_df1_dsp48 is
    generic (
      WIDTH_COEFFICIENTS : natural := 16;
      WIDTH_DATA         : natural := 16;
      OPT_REG_IN         : boolean := true;
      OPT_REG_OUT        : boolean := true
    );
    port (
      clk   : in  std_logic;
      d_in  : in  std_logic_vector((WIDTH_DATA-1) downto 0);
      d_out : out std_logic_vector((WIDTH_DATA-1) downto 0);
      c_a0  : in  std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0);
      c_a1  : in  std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0);
      c_a2  : in  std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0);
      c_b0  : in  std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0);
      c_b1  : in  std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0)
    );
  end component;

  -- signals
  signal aclk        : std_logic;
  signal s_tdata_in  : std_logic_vector((C_S_AXIS_TDATA_WIDTH-1) downto 0);
  signal m_tdata_out : std_logic_vector((C_S_AXIS_TDATA_WIDTH-1) downto 0);
  signal sig_c_a0    : std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0) := std_logic_vector(COEF_A0);
  signal sig_c_a1    : std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0) := std_logic_vector(COEF_A1);
  signal sig_c_a2    : std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0) := std_logic_vector(COEF_A2);
  signal sig_c_b0    : std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0) := std_logic_vector(COEF_B0);
  signal sig_c_b1    : std_logic_vector((WIDTH_COEFFICIENTS-1) downto 0) := std_logic_vector(COEF_B1);

begin
  -- I/O connections assignments
  aclk    <= AXIS_ACLK;
  S_AXIS_TREADY <= '1';
  s_tdata_in <= S_AXIS_TDATA;
  M_AXIS_TDATA <= m_tdata_out;

  iir_inst : iir_df1_dsp48
    generic map (
      WIDTH_COEFFICIENTS => WIDTH_COEFFICIENTS,
      WIDTH_DATA         => C_S_AXIS_TDATA_WIDTH,
      OPT_REG_IN         => OPT_REG_IN,
      OPT_REG_OUT        => OPT_REG_OUT
    )
    port map (
      clk   => aclk,
      d_in  => s_tdata_in,
      d_out => m_tdata_out,
      c_a0  => sig_c_a0,
      c_a1  => sig_c_a1,
      c_a2  => sig_c_a2,
      c_b0  => sig_c_b0,
      c_b1  => sig_c_b1
    );

end arch_imp;
