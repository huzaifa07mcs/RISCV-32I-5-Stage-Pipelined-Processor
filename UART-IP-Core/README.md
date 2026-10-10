# UART IP Core

This project implements a UART transceiver IP in SystemVerilog. It includes a TX FIFO, an RX FIFO, optional parity, and framing and parity error flags. The design was verified in Vivado XSIM with a self-checking class-based SystemVerilog testbench without UVM.

---

## Table of Contents

- [Highlights](#highlights)
- [UART Specifications](#uart-specifications)
- [Frame Format](#frame-format)
- [Block Overview](#block-overview)
- [Port Description](#port-description)
- [Repository Structure](#repository-structure)
- [Development Workflow](#development-workflow)
- [Module Status](#module-status)
- [Verification](#verification)
- [Simulation Results Summary](#simulation-results-summary)
- [Bug Found by the Testbench](#bug-found-by-the-testbench)
- [Known Limitations](#known-limitations)
- [Future Work](#future-work)
- [Tools](#tools)
- [License](#license)

---

## Highlights

- Parameterized baud rate and clock frequency
- Even, odd and no parity
- 16-entry synchronous FIFOs on both TX and RX
- Framing and parity error flags in the RX
- Self-checking testbench with a queue-based scoreboard
- Scoreboard checks the tx pin independently of the DUT and was validated with a mutation test
- The testbench found a real RTL bug in the TX control logic, now fixed

---

## UART Specifications

| Item | Value |
| :--- | :--- |
| Language | RTL SystemVerilog; testbench SystemVerilog |
| Clock | 50 MHz default (`CLK_FREQ` parameter) |
| Baud rate | 9600 default (`BAUD_RATE` parameter), 5208 clocks per bit |
| Data bits | 8, LSB first |
| Parity | none, even or odd, selected at runtime by `parity_en` and `parity_odd` |
| Stop bits | 1 |
| FIFO depth | 16 (`FIFO_DEPTH` parameter), 8-bit wide |
| Reset | asynchronous, active-high |
| Clock domains | single |
| Simulation tool | Xilinx Vivado 2019.1 (XSIM) |

---

## Frame Format

1 start bit (0), 8 data bits LSB first, optional parity bit, 1 stop bit (1).

- 10 bits without parity, 520.8 us at 9600 baud
- 11 bits with parity, 572.9 us

---

## Block Overview

Host writes into TX FIFO, TX control reads the FIFO and starts `uart_tx`, `uart_tx` drives the `tx` pin. The `rx` pin goes into `uart_rx`, which pushes received bytes into the RX FIFO, and the host reads from it.

```text
Host -> TX FIFO -> TX Control -> uart_tx -> tx pin
rx pin -> uart_rx -> RX FIFO -> Host
```

---

## Port Description

| Port | Direction | Description |
| :--- | :--- | :--- |
| `clk` | in | clock and asynchronous reset clock input |
| `reset` | in | asynchronous reset |
| `rx` | in | serial receive line |
| `tx` | out | serial transmit line |
| `parity_en` | in | enable parity generation and checking |
| `parity_odd` | in | 1 = odd, 0 = even |
| `tx_din[7:0]` | in | byte to transmit |
| `tx_wr_en` | in | write `tx_din` into the TX FIFO |
| `tx_full` | out | TX FIFO status |
| `tx_empty` | out | TX FIFO status |
| `rx_dout[7:0]` | out | byte read from RX FIFO, registered, valid one clock after `rx_rd_en` is accepted |
| `rx_rd_en` | in | read one byte from the RX FIFO |
| `rx_full` | out | RX FIFO status |
| `rx_empty` | out | RX FIFO status |
| `err_frame` | out | stop bit was not 1 |
| `err_parity` | out | received parity did not match |

- A write to a full TX FIFO is ignored.
- A byte finishing while the RX FIFO is full is dropped silently and there is no overrun flag yet.
- A byte with a parity error is still pushed into the RX FIFO and only `err_parity` is raised.

---

## Repository Structure

```text
UART-IP-Core/
├── README.md
├── verification_results.md
├── docs/
│   ├── UART IP Core Specification.md
│   ├── sync_fifo_spec.md
│   ├── uart_rx_spec.md
│   ├── uart_tx_spec.md
│   ├── uart_top_spec.md
│   └── Working.md
├── rtl/
│   ├── uart_top.sv
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── sync_fifo.sv
└── tb/
    ├── uart_if.sv
    ├── uart_trans.sv
    ├── generator.sv
    ├── driver.sv
    ├── monitor.sv
    ├── uart_sco.sv
    ├── environment.sv
    └── tb_top.sv
```

`docs/` stores module specifications and working notes. `rtl/` stores synthesizable RTL modules. `tb/` stores the class-based verification environment and top-level testbench.

---

## Development Workflow

1. Specify: define UART behavior, FIFO behavior, and error handling requirements.
2. Implement: code RTL for FIFO, TX, RX, and top integration.
3. Test: build the class-based self-checking testbench.
4. Simulate: run XSIM with loopback and random stimulus.
5. Verify: compare RX data and decode TX frames in the scoreboard.
6. Fix: resolve RTL or testbench issues found in simulation.
7. Integrate: keep module specs, RTL, and verification aligned.

This follows a normal hardware development flow.

---

## Module Status

| Module | Spec | RTL | Testbench | Simulation | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `sync_fifo` | ✅ | ✅ | Integration TB | ✅ | Complete |
| `uart_tx` | ✅ | ✅ | Integration TB | ✅ | Complete |
| `uart_rx` | ✅ | ✅ | Integration TB | ✅ | Complete |
| `uart_top` | ✅ | ✅ | Integration TB | ✅ | Complete |
| Testbench environment (`interface`, `transaction`, `generator`, `driver`, `monitor`, `scoreboard`, `environment`) | ✅ | - | ✅ | ✅ | Complete for loopback and parity scope |

| Item | Status |
| :--- | :--- |
| Error injection | Not started |
| Overrun | Not started |
| Coverage | Not started |

---

## Verification

The DUT was verified in loopback mode in `tb_top`, with `tx` connected to `rx`, using 30 random bytes and random parity mode.

Verified points:
- TX to RX data integrity
- Parity off, even and odd modes
- Start, stop, data and parity bits on the `tx` pin, checked by the testbench using its own computed parity
- Frame timing, 10 bit and 11 bit frames match 52.08 us per bit

| File | Role |
| :--- | :--- |
| `uart_if.sv` | Interface for DUT and testbench signals |
| `uart_trans.sv` | Transaction object for stimulus data and control |
| `generator.sv` | Random transaction generation |
| `driver.sv` | Drives TX FIFO write and RX FIFO read operations |
| `monitor.sv` | Samples DUT activity and serial frame behavior |
| `uart_sco.sv` | Scoreboard for data and frame checks |
| `environment.sv` | Connects and runs generator, driver, monitor, scoreboard |
| `tb_top.sv` | Top-level testbench with loopback and DUT instantiation |

Scoreboard checks:
1. Data check, queue of written bytes is compared against bytes read from the RX FIFO.
2. Frame check on the `tx` pin, parity is computed in the scoreboard from the data bits.

---

## Simulation Results Summary

| Metric | Value |
| :--- | :--- |
| Bytes written to TX FIFO | 30 |
| Bytes read back correct | 30 |
| Data mismatches | 0 |
| Frames decoded on tx pin correct | 30 |
| Frame failures | 0 |
| Parity off frames | 8 |
| Even parity frames | 12 |
| Odd parity frames | 10 |
| Mutation test (parity even/odd swapped in `uart_tx`) | Frame Pass 8, Frame Fail 22, data check still 30/30 |
| Result | All checks passed |

The mutation test shows loopback alone cannot catch a parity bug that TX and RX share, and the pin-level frame check does catch it. See [verification_results.md](verification_results.md) for details.

---

## Bug Found by the Testbench

The TX control state machine in `uart_top` read one extra byte from the TX FIFO because `tx_busy` stays low for one clock after `tx_start`. In the first multi-byte run only 3 of 5 bytes came back. The fix added a third state, `BUSY_CTRL`, that waits for `tx_busy` before returning to idle.

---

## Known Limitations

- `tx_wr_en` is forced to 1 and the driver waits for each frame to finish, so the TX FIFO never fills.
- `err_frame` and `err_parity` are not connected in the testbench yet.
- `BIT_CLKS` in the monitor is hardcoded to 5208 and must match `CLK_FREQ / BAUD_RATE`.
- The generator's `$fatal` call should be `$fatal(1, "...")` to remove a Vivado warning.
- Only one random seed was run.

---

## Future Work

- Connect `err_frame` and `err_parity` and check them.
- Add a mux in `tb_top` so the driver can send malformed frames on `rx`, framing error and parity error.
- Add an overrun flag in the RTL and test a full RX FIFO.
- Add back-to-back FIFO stress and full-duplex tests.
- Add functional coverage and a multi-seed regression.

---

## Tools

- SystemVerilog, RTL and testbench
- Xilinx Vivado 2019.1, XSIM simulation
- Git and GitHub, version control

---

## License

This project was developed for learning, educational, and portfolio purposes.
