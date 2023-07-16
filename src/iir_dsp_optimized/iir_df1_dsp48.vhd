----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-07-16
-- Design Name:    iir_df1_dsp48
-- Module Name:    iir_df1_dsp48
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  Xilinx Vivado 2021.2
--                 GHDL 4.0.0-dev 
--                 cocotb-config 1.8.0
--                 gcc (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0
--                 GNU Make 4.2.1
-- Description:    IIR direct form 1 optimized for high-frequency operation on DSP48
--                 critical path has been retimed for better pipelining
--                 allowing one sample per clock cycle
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

entity iir_df1_dsp48 is
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
end iir_df1_dsp48;

architecture arch_imp of iir_df1_dsp48 is

  signal sum_out        : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_in         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal reg_in         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal reg_in_t1      : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal reg_in_t2      : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_a0         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_a1         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_a2         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_a0_reg     : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_a1_reg     : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_b0         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_b1         : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sig_b0_reg     : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sum_out_reg    : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sum_2          : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sum_3          : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal sum_2_reg      : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');
  signal reg_sum_out_b1 : signed( (WIDTH_DATA-1) downto 0 ) := (others => '0');

  signal gain_a0_out : signed( (WIDTH_COEFFICIENTS + WIDTH_DATA -1) downto 0 );
  signal gain_a1_out : signed( (WIDTH_COEFFICIENTS + WIDTH_DATA -1) downto 0 );
  signal gain_a2_out : signed( (WIDTH_COEFFICIENTS + WIDTH_DATA -1) downto 0 );
  signal gain_b0_out : signed( (WIDTH_COEFFICIENTS + WIDTH_DATA -1) downto 0 );
  signal gain_b1_out : signed( (WIDTH_COEFFICIENTS + WIDTH_DATA -1) downto 0 );

begin
  -- in/out ports
  sig_in <= signed(d_in);
  d_out  <= std_logic_vector(sum_out_reg);

  -- optional input register
  gen_inp_register : if OPT_REG_IN generate
    p_opt_in_reg : process(clk)
    begin
      if rising_edge(clk) then
        reg_in <= sig_in;
      end if;
    end process;
  end generate;

  gen_no_inp_register : if not OPT_REG_IN generate
    reg_in <= sig_in;
  end generate;

  -- optional output register
  gen_outp_register : if OPT_REG_OUT generate
    p_opt_out_reg : process(clk)
    begin
      if rising_edge(clk) then
        sum_out_reg <= sum_out;
      end if;
    end process;
  end generate;

  gen_no_outp_register : if not OPT_REG_OUT generate
    sum_out_reg <= sum_out;
  end generate;

  -- all registers in the IIR filter
  p_all_regs : process(clk)
  begin
    if rising_edge(clk) then
      reg_in_t1  <= reg_in;
      reg_in_t2  <= reg_in_t1;
      sum_2_reg  <= sum_2;
      sig_a0_reg <= sig_a0;
      sig_a1_reg <= sig_a1;
      sig_b0_reg <= sig_b0;
      reg_sum_out_b1 <= sum_out;
    end if;
  end process;

  gain_a0_out <= reg_in    * signed(c_a0);
  gain_a1_out <= reg_in_t1 * signed(c_a1);
  gain_a2_out <= reg_in_t2 * signed(c_a2);
  gain_b0_out <= sum_out   * signed(c_b0);
  gain_b1_out <= reg_sum_out_b1 * signed(c_b1);

  sig_a0 <= gain_a0_out((WIDTH_COEFFICIENTS+WIDTH_DATA-1-2) downto WIDTH_COEFFICIENTS-2);
  sig_a1 <= gain_a1_out((WIDTH_COEFFICIENTS+WIDTH_DATA-1-2) downto WIDTH_COEFFICIENTS-2);
  sig_a2 <= gain_a2_out((WIDTH_COEFFICIENTS+WIDTH_DATA-1-2) downto WIDTH_COEFFICIENTS-2);
  sig_b0 <= gain_b0_out((WIDTH_COEFFICIENTS+WIDTH_DATA-1-2) downto WIDTH_COEFFICIENTS-2);
  sig_b1 <= gain_b1_out((WIDTH_COEFFICIENTS+WIDTH_DATA-1-2) downto WIDTH_COEFFICIENTS-2);

  sum_out <= sig_a0_reg + sum_3;
  sum_3 <= sig_a1_reg + sig_b0_reg + sum_2_reg;
  sum_2 <= sig_a2 + sig_b1;

end arch_imp;
