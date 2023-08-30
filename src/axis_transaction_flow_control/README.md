# AXIS Transaction Tracker and Flow Control

---

There are two AXI-Stream interfaces with different clock domains
- AXIS (A) at 322.265625 MHz
- AXIS (B) at 125 MHz

Each AXIS interface has its own counter
- AXIS (A) up-counter `ctr_up`
- AXIS (B) down-counter `ctr_dn`

Each counter can be enabled or disabled via `ctr_up_en` / `ctr_dn_en`

The counter increment (if enabled) is 1 per clock cycle.

The module is running at the higher clock frequency of 322 MHz.

The module calculates the difference `xfer_lvl` = `ctr_up` - `ctr_dn`.

There is a need for a CDC from the slower to the faster clock domain.
Since the down-counter only increments in steps of 1 and because the target clock is faster than the source clock, the following implementation is proposed.
`ctr_dn` is implemented as a 4-bit gray code counter.
The CDC is performed using double flip-flops.
The target clock domain tracks the changes in the received gray code pattern.
If a change in the pattern is detected, the target counter is decremented by 1.

---

```vhdl
pause_level : in std_logic_vector(7 downto 0);
```


