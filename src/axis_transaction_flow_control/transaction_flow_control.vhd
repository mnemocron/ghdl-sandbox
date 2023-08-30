----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-08-30
-- Design Name:    transaction_flow_control
-- Module Name:    transaction_flow_control
-- Project Name:   
-- Target Devices: Xilinx UltraScale+
-- Tool Versions:  
-- Description:    tracking AXIS transaction and initiating a pause request on reaching a level
-- Dependencies:   
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- a 32 bit counter at 322 MHz will overflow after 10 seconds
-- a 48 bit counter at 322 MHz will overflow after 10 days
-- a 64 bit counter at 322 MHz will overflow after 1800 years
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

entity transaction_flow_control is
  generic (
    ACCUMULATOR_WIDTH  : natural := 48
  );
  port (
    clk_gt        : in  std_logic;
    clk_axis      : in  std_logic;
    en_cnt_up     : in  std_logic;
    en_cnt_dn     : in  std_logic;
    pause_level   : in  std_logic_vector(7 downto 0);
    pause_request : out std_logic
  );
end transaction_flow_control;

architecture arch_imp of transaction_flow_control is

  signal cnt_gray      : std_logic_vector(2 downto 0) := (others => '0');
  signal cnt_gray_next : std_logic_vector(2 downto 0) := (others => '0');

  signal cdc_gray_async : std_logic_vector(2 downto 0) := (others => '0');
  signal cdc_gray_reg   : std_logic_vector(2 downto 0) := (others => '0');
  signal cdc_gray_prev  : std_logic_vector(2 downto 0) := (others => '0');

  attribute ASYNC_REG : boolean;
  attribute ASYNC_REG of cdc_gray_async : signal is TRUE;
  attribute ASYNC_REG of cdc_gray_prev   : signal is TRUE;

  signal gray_increment_valid : std_logic;
  signal pause_request_reg : std_logic;


  signal cnt_up  : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal cnt_dn  : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal cnt_res : std_logic_vector((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');

begin

  cnt_gray_next <=  "001" when cnt_gray = "000" else
                    "011" when cnt_gray = "001" else
                    "010" when cnt_gray = "011" else
                    "110" when cnt_gray = "010" else
                    "111" when cnt_gray = "110" else
                    "101" when cnt_gray = "111" else
                    "100" when cnt_gray = "101" else
                    "000" when cnt_gray = "100";
  p_gray_counter : process(clk_axis)
  begin
    if rising_edge(clk_axis) then
      if en_cnt_dn = '1' then
        cnt_gray <= cnt_gray_next;
      end if;
    end if;
  end process;

  p_gray_cdc : process(clk_gt)
  begin
    if rising_edge(clk_gt) then
      cdc_gray_async <= cnt_gray;
      cdc_gray_prev <= cdc_gray_async;
      cdc_gray_reg  <= cdc_gray_prev;
    end if;
  end process;
  gray_increment_valid <= (cdc_gray_reg(0) xor cdc_gray_prev(0)) or (cdc_gray_reg(1) xor cdc_gray_prev(1)) or (cdc_gray_reg(2) xor cdc_gray_prev(2));

  p_up_counter : process(clk_gt)
  begin
    if rising_edge(clk_gt) then
      if en_cnt_up = '1' then
        cnt_up <= std_logic_vector(signed(cnt_up)+1);
      end if;
    end if;
  end process;

  p_down_counter : process(clk_gt)
  begin
    if rising_edge(clk_gt) then
      if gray_increment_valid = '1' then
        cnt_dn <= std_logic_vector(signed(cnt_dn)+1);
      else
        cnt_dn <= cnt_dn;
      end if;
    end if;
  end process;

  p_result : process(clk_gt)
  begin
    if rising_edge(clk_gt) then
      cnt_res <= std_logic_vector(signed(cnt_up)-signed(cnt_dn));
    end if;
  end process;

  p_pause_gen : process(clk_gt)
  begin
    if rising_edge(clk_gt) then
      if unsigned(cnt_res) > unsigned(pause_level) then
        pause_request_reg <= '1';
      else
        pause_request_reg <= '0';
      end if;
    end if;
  end process;

  pause_request <= pause_request_reg;


end arch_imp;
