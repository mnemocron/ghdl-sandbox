----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-07-06
-- Design Name:    divu10
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL 4.0.0-dev (3.0.0.r72.gfb218404d)
-- Description:    Unsigned division by constant 10
--                 https://stackoverflow.com/a/19076173
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

entity divu10 is
  generic (
    DATA_WIDTH            : integer := 32
  );
  port (
    aclk       : in  std_logic;
    aresetn    : in  std_logic;
    s00_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    s00_tvalid : in  std_logic;
    s00_tready : out std_logic;
    m00_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    m00_tvalid : out std_logic
  );
end divu10;

architecture arch_imp of divu10 is
  signal numb : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal quot : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal rmnd : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal dout : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
--  signal dbg : std_logic_vector(3 downto 0);

  type t_state is (IDLE, DIV_I1, DIV_I2, DIV_I3, DIV_I4, DIV_I5, DIV_I6, DIV_I7);
  signal state: t_state;
  attribute fsm_state : string;
  attribute fsm_state of state : signal is "ONE_HOT";      -- encoding style of the state register

begin
  m00_tdata <= dout;

  p_fsm : process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        state <= IDLE;
        s00_tready <= '1';
      else
        case state is
          when IDLE   => -- do something
            if s00_tvalid = '1' then
              state <= DIV_I1;
              numb <= s00_tdata;
              s00_tready <= '0';
--                dbg <= "0001";
            end if;
          when DIV_I1 =>
            state <= DIV_I2;
--              dbg <= "0010";
          when DIV_I2 =>
            state <= DIV_I3;
--              dbg <= "0011";
          when DIV_I3 =>
            state <= DIV_I4;
--              dbg <= "0100";
          when DIV_I4 =>
            state <= DIV_I5;
--              dbg <= "0101";
          when DIV_I5 =>
            state <= DIV_I6;
--              dbg <= "0110";
          when DIV_I6 =>
            state <= DIV_I7;
--              dbg <= "0111";
          when DIV_I7 =>
            state <= IDLE;
            s00_tready <= '1';
--              dbg <= "0000";
        end case;
      end if;
    end if;
  end process;

  p_calc : process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        quot <= (others => '0');
        m00_tvalid <= '0';
      else
        case state is 
          when IDLE =>
            quot <= (others => '0');
          when DIV_I1 =>
            quot <= std_logic_vector(shift_right(unsigned(numb), 1) + shift_right(unsigned(numb), 2));
            m00_tvalid <= '0';
          when DIV_I2 =>
            quot <= std_logic_vector(unsigned(quot) + shift_right(unsigned(quot), 4));
          when DIV_I3 =>
            quot <= std_logic_vector(unsigned(quot) + shift_right(unsigned(quot), 8));
          when DIV_I4 =>
            quot <= std_logic_vector(unsigned(quot) + shift_right(unsigned(quot), 16));
          when DIV_I5 =>
            quot <= std_logic_vector(shift_right(unsigned(quot), 3));
          when DIV_I6 =>
            rmnd <= std_logic_vector(unsigned(numb) - shift_left(unsigned(quot),3) - shift_left(unsigned(quot),1));
          when DIV_I7 =>
            dout <= std_logic_vector(unsigned(quot) + shift_right((unsigned(rmnd)+6), 4));
            m00_tvalid <= '1';
        end case;
      end if;
    end if;
  end process;

end arch_imp;
