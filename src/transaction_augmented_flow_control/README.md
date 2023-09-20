# Flow Control with Augmented Transaction Count

---

### Requirements

The IP has two counters at different clock speeds
- Incomming Rx transaction counter `cnt_rx` @ 322 MHz `rx_usrclk2`
- Shadow counter `cnt_shd` @ 322 MHz `tx_usrclk2`
- Outgoing counter `cnt_out` @ 125 MHz `dac_clk`
- Augmented FIFO count `aug_fifo_level` @ 322 MHz `tx_usrclk2`





The target clock of the IP is `tx_usrclk2` (322 MHz).

There is a CDC for the `cnt_rx` from `rx_usrclk2` to `tx_usrclk2`.

There is a CDC for the `cnt_shd` from `dac_clk` to `tx_usrclk2`.


### Incoming Rx Transaction Counter

This counter increments by one if `rx_tvalid` is high.

### Outgoing Counter

The outgoint counter counts predicted transactions out of the CDC FIFO. It will later be used to subtract.
It increments by 1 on every clock cycle of `dac_clk` only if `aug_fifo_level` > 0.

### Augmented FIFO Level

The augmentet FIFO level predicts the level of the FIFO ahead of all latencies.
It is the difference of: `cnt_rx` - `cnt_out`.
This is the representation of all incomming rx packets and all packets leaving the FIFO.

### Shadow Counter

This counter has a state machine with 2 states:
- `STATE_MIRROR` 
- `STATE_PREDICT` 

In the `STATE_MIRROR` the shadow counter follows the rx counter. There is one clock cycle of lag. The rx counter is always 1 greater or equal to the shadow counter.

In the `STATE_PREDICT` the shadow counter counts down on every clock cycle of 125 MHz. This is achieved by subtracting the `cnt_out` from the `cnt_shd`.

The transition condition from `STATE_MIRROR` to `STATE_PREDICT` is when `tx_pause_req` is asserted.






