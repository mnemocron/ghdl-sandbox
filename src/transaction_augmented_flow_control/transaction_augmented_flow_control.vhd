----------------------------------------------------------------------------------
-- Company:        
-- Engineer:       simon.burkhardt
-- 
-- Create Date:    2023-09-20
-- Design Name:    transaction_augmented_flow_control
-- Module Name:    transaction_augmented_flow_control
-- Project Name:   
-- Target Devices: Xilinx UltraScale+
-- Tool Versions:  
-- Description:    This IP is part of a transmission rate control loop.
--                 AXI transactions (tvald & tready) to and from a CDC-FIFO are
--                 counted. To deal with the large latencies, the counters are 
--                 augmented (predictive counting) in order to have a tighter 
--                 control loop.
-- Dependencies:   
-- 
-- Revision:       0.0.1
-- 
-- Additional Comments:
-- a 32 bit counter at 322 MHz will overflow after 10 seconds
-- a 48 bit counter at 322 MHz will overflow after 10 days
-- a 64 bit counter at 322 MHz will overflow after 1800 years
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;

entity transaction_augmented_flow_control is
  generic (
    ACCUMULATOR_WIDTH  : natural := 48;
    THESHOLD_WIDTH     : natural := 16
  );
  port (
    rx_usrclk2    : in  std_logic;
    tx_usrclk2    : in  std_logic;
    axis_aclk     : in  std_logic;
    rx_tvalid     : in  std_logic;
    tx_tvalid     : in  std_logic;

    thresh_full      : in  std_logic_vector((THESHOLD_WIDTH-1) downto 0);
    thresh_empty     : in  std_logic_vector((THESHOLD_WIDTH-1) downto 0);
    ctl_tx_pause_req : out std_logic
  );
end transaction_augmented_flow_control;

architecture arch_imp of transaction_augmented_flow_control is

  signal level_xoff : unsigned((THESHOLD_WIDTH-1) downto 0) := (others => '0');
  signal level_xon  : unsigned((THESHOLD_WIDTH-1) downto 0) := (others => '0');
  signal tx_ticks : std_logic := '0';
  signal tx_ticks_async : std_logic := '0';
  signal tx_ticks_cdc   : std_logic := '0';
  signal tx_ticks_reg   : std_logic := '0';
  
  signal tx_cnt_cdc : std_logic := '0';
  signal tx_cnt_prv : std_logic := '0';

  signal tx_count : unsigned((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal rx_count : unsigned((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal xfer_count : unsigned((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal xfer_count_freeze : unsigned((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal tx_count_freeze : unsigned((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');
  signal augment_count : unsigned((ACCUMULATOR_WIDTH-1) downto 0) := (others => '0');

  attribute ASYNC_REG : boolean;
  attribute ASYNC_REG of tx_ticks_async : signal is TRUE;
  attribute ASYNC_REG of tx_ticks_cdc   : signal is TRUE;
  -- needs additional constraint: 
  -- set_max_delay -datapath_only <rx_usrclk_period> -from tx_ticks -to tx_ticks_cdc(0)

  -- type AUGMENTATION_STATE_T is (STATE_MIRROR, STATE_PREDICT);
  -- signal augment_state : AUGMENTATION_STATE_T := STATE_MIRROR;
  -- type FLOW_CONTROL_STATE_T is (PFC_XON, PFC_XOFF);
  -- signal pause_state : FLOW_CONTROL_STATE_T := PFC_XON;
  signal augment_state : std_logic := '0';
  signal pause_state : std_logic := '0';

begin
  
  -- inputs should remain constant
  -- @TODO build an internal adapptation algorithm to adjust those levels tighter together
  p_inp_reg : process(tx_usrclk2)
  begin
    if rising_edge(tx_usrclk2) then
      level_xoff <= unsigned(thresh_full);
      level_xon  <= unsigned(thresh_empty);
    end if;
  end process;

  p_tx_gray_counter : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      tx_ticks <= not tx_ticks;
    end if;
  end process;

  p_cdc_slow_to_rxclk : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      tx_ticks_async <= tx_ticks;       -- slow clock to meta stable
      tx_ticks_cdc   <= tx_ticks_async; -- meta stable to stable
      tx_ticks_reg   <= tx_ticks_cdc;   -- stable to one delayed for edge detection
    end if;
  end process;

  p_tx_counter : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      --if tx_cnt_cdc /= tx_cnt_prv then
      if tx_ticks_reg /= tx_ticks_cdc then
        if xfer_count > 1 then
          tx_count <= tx_count +1;
        end if;
      else
        tx_count <= tx_count;
      end if;
    end if;
  end process;

  p_rx_counter : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      if rx_tvalid = '1' then
        rx_count <= rx_count +1;
      else
        rx_count <= rx_count;
      end if;
    end if;
  end process;

  p_transaction_counter : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      xfer_count <= rx_count - tx_count;
    end if;
  end process;

  p_augmentation_fsm : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      -- if augment_state = STATE_MIRROR then
      if augment_state = '0' then
        -- if pause_state = PFC_XOFF then
        if pause_state = '1' then
          -- augment_state <= STATE_PREDICT;
          augment_state <= '1';
        end if;
      else 
        if xfer_count < augment_count then
          -- augment_state <= STATE_MIRROR;
          augment_state <= '0';
        end if;
      end if;
    end if;
  end process;

  p_augmentatoin_counter : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      -- if augment_state = STATE_MIRROR then
      if augment_state = '0' then
        augment_count <= xfer_count;
        xfer_count_freeze <= xfer_count;
        tx_count_freeze <= tx_count;
      else 
        augment_count <= xfer_count_freeze - (tx_count_freeze - tx_count);
      end if;
    end if;
  end process;

  p_pause_fsm : process(rx_usrclk2)
  begin
    if rising_edge(rx_usrclk2) then
      -- if pause_state = PFC_XON then
      if pause_state = '0' then
        if augment_count > level_xoff then
          -- pause_state <= PFC_XOFF;
          pause_state <= '1';
        end if;
      else
        if augment_count < level_xon then
          -- pause_state <= PFC_XON;
          pause_state <= '0';
        end if;
      end if;
    end if;
  end process;

  p_pause_gen : process(tx_usrclk2)
  begin
    if rising_edge(tx_usrclk2) then
      -- if pause_state = PFC_XON then
      if pause_state = '0' then
        ctl_tx_pause_req <= '0';
      else
        ctl_tx_pause_req <= '1';
      end if;
    end if;
  end process;

end arch_imp;
