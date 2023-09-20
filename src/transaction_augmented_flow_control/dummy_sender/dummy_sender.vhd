----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-09-20
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: Xilinx UltraScale+
-- Tool Versions:  
-- Description:    
-- Dependencies:   
-- 
-- Revision:       0.0.1
-- 
-- Additional Comments:
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

entity dummy_sender is
  port (
    tx_clk         : in  std_logic;
    tvalid         : out std_logic;
    en             : in  std_logic;
    ctl_pause_req  : in  std_logic;
    burst_length   : in  std_logic_vector(7 downto 0);
    burst_pause    : in  std_logic_vector(7 downto 0);
    en_immdt_pause : in  std_logic;
    latency        : in  std_logic_vector(7 downto 0)
  );
end dummy_sender;

architecture arch_imp of dummy_sender is
  signal xfer_length     : unsigned(7 downto 0) := (others => '0');
  signal xfer_pause      : unsigned(7 downto 0) := (others => '0');
  signal xfer_length_ctr : unsigned(7 downto 0) := (others => '0');
  signal xfer_reload_ctr : unsigned(7 downto 0) := (others => '0');

  signal pause_req_delay : std_logic_vector(255 downto 0) := (others => '0');
  signal effective_pause : std_logic := '0';
  signal latency_reg     : std_logic_vector(7 downto 0);

  signal state : unsigned(3 downto 0) := (others => '0');
begin
  
  p_latency : process(tx_clk)
  begin
    if rising_edge(tx_clk) then
      latency_reg <= latency;
      pause_req_delay(0) <= ctl_pause_req;
      pause_req_delay(255 downto 1) <= pause_req_delay(254 downto 0);
    end if;
  end process;
  effective_pause <= pause_req_delay( to_integer(unsigned(latency_reg)) );

  p_input : process(tx_clk)
  begin
    if rising_edge(tx_clk) then
      xfer_pause  <= unsigned(burst_pause);
      xfer_length <= unsigned(burst_length);
    end if;
  end process;

  p_xfer : process(tx_clk)
  begin
    if rising_edge(tx_clk) then
      if en = '1' then
        -- BURST SEND
        if state = "0000" then
          tvalid <= '1';
          if en_immdt_pause = '1' then
            if effective_pause = '1' then -- go to pause immediately without finishing burst
              state <= "0100"; -- to TX BREAK
            else -- continue burst
              if (xfer_length_ctr +1) = xfer_length then
                xfer_length_ctr <= (others => '0');
                state <= "0001"; -- to TX RELOAD
              end if;
            end if;
          else -- wait for burst to finish before reacting to pending pause_req
            if (xfer_length_ctr +1) = xfer_length then
              xfer_length_ctr <= (others => '0');
              if effective_pause = '1' then
                state <= "0100"; -- to TX BREAK
              else
                state <= "0001"; -- to TX RELOAD
              end if;
            else
              xfer_length_ctr <= xfer_length_ctr+1;
            end if;
          end if;
        -- BURST RELOAD
        elsif state = "0001" then
          tvalid <= '0';
          if en_immdt_pause = '1' then
            if effective_pause = '1' then -- go to pause immediately without finishing burst
              state <= "0101"; -- to TX BREAK
            else -- continue burst
              if (xfer_reload_ctr +1) = xfer_pause then
                xfer_reload_ctr <= (others => '0');
                state <= "0000"; -- to TX SEND
              end if;
            end if;
          else -- wait for burst to finish before reacting to pending pause_req
            if (xfer_reload_ctr +1) = xfer_pause then
              xfer_reload_ctr <= (others => '0');
              if effective_pause = '1' then
                state <= "0101"; -- to TX BREAK
              else
                state <= "0000"; -- to TX SEND
              end if;
            else
              xfer_reload_ctr <= xfer_reload_ctr+1;
            end if;
          end if;
        -- BURST SEND PAUSE
        elsif state = "0100" then 
          if effective_pause = '0' then
            state <= "0000";
          end if;
          tvalid <= '0';
        -- BURST RELOAD PAUSE 
        elsif state = "0101" then 
          if effective_pause = '0' then
            state <= "0001";
          end if;
          tvalid <= '0';
        else
          state <= "0000";
        end if;
      else 
        tvalid <= '0';
        state <= (others => '0');
        xfer_length_ctr <= (others => '0');
        xfer_reload_ctr  <= (others => '0');
      end if;
    end if;
  end process;

end arch_imp;
