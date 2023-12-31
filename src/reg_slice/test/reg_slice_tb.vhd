----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023
-- Design Name:    
-- Module Name:    
-- Project Name:   
-- Target Devices: 
-- Tool Versions:  GHDL 4.0.0
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

-- this testbench acts as a streaming master, sending bursts of data
-- counting from 1-4, also asserting tlast on the 4th data packet

-- the testbench itself acts as a correct streaming master which keeps the data
-- until it is acknowledged by the DUT by asserting tready.

-- the data pattern can be influenced by the user in 2 ways
-- + Tx requests are generated by changing the pattern in p_stimuli_tready
--   the master will try to send data for as long as sim_valid_data = '1'
-- + Rx acknowledgements are generated by changing the pattern in p_stimuli_tready
--   the downstream slave after the DUT will signal ready-to-receive 
--   when sim_ready_data = '1'

-- simulate both with OPT_DATA_REG = True / False
entity reg_slice_tb is
  generic
  (
    DATA_WIDTH   : natural := 1
  );
end reg_slice_tb;

architecture bh of reg_slice_tb is
  -- DUT component declaration
  component reg_slice is
    generic (
      REG_WIDTH  : integer
    );
    port (
      clk : in  std_logic;
      i   : in  std_logic_vector(REG_WIDTH-1 downto 0);
      o   : out std_logic_vector(REG_WIDTH-1 downto 0)
    );
  end component;
  
  constant CLK_PERIOD: TIME := 5 ns;

  signal clk       : std_logic;
  signal clk_count : std_logic_vector(7 downto 0) := (others => '0');
  signal sig_in    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_out   : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
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

  -- generate ready signal
  p_stimuli : process(clk)
  begin
    if rising_edge(clk) then
      sig_in <= not sig_in;
    end if;
  end process;


-- DUT instance and connections
  dut_inst : reg_slice
  generic map (
    REG_WIDTH  => DATA_WIDTH
  )
  port map (
    clk => clk,
    i   => sig_in,
    o   => sig_out
  );

end bh;
