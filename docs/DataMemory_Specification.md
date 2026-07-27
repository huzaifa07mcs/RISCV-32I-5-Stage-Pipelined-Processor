# DataMemory Specification

## 1. Module Name
`DataMemory`

## 2. Purpose
Data Memory stores and provides access to data used by load (`LW`) and store (`SW`) instructions. It supports a synchronous write (on the clock edge, gated by `write_enable`) and a combinational read, which is required for correct single-cycle timing — `LW`'s read data must be available within the same cycle it's requested, with no clock edge delay, so it can reach the register file write-back mux before the next rising edge.

**Assumption (confirm before finalizing):** per the project spec, this module is word-addressable — `address` is treated as a direct word index into the memory array (i.e. `mem[address]`, not `mem[address >> 2]`). If your datapath instead passes a byte address computed by the ALU (`base + offset`), you'll need to decide where the byte→word conversion happens (inside this module, or upstream) before RTL — flag this back if that's the case so the spec can be corrected.

## 3. Inputs
| Signal          | Width | Description                                              |
|-----------------|-------|--------------------------------------------------------------|
| `clk`           | 1     | Clock — used only for the synchronous write                  |
| `address`       | 32    | Word address into data memory                                |
| `write_data`    | 32    | Data to be written on a store                                 |
| `write_enable`  | 1     | Asserted (from Main Control's `MemWrite`) for SW               |

## 4. Outputs
| Signal        | Width | Description                                  |
|---------------|-------|------------------------------------------------|
| `read_data`   | 32    | Combinational read output — reflects `mem[address]` immediately |

## 5. Parameters
| Parameter | Value | Description                          |
|-----------|-------|------------------------------------------|
| `XLEN`    | 32    | Processor data width                     |
| `DEPTH`   | TBD   | Number of addressable words in memory (size to be decided based on program/data needs) |

## 6. Internal Storage
An array of `DEPTH` words, each `XLEN` bits wide (e.g. `reg [XLEN-1:0] mem [0:DEPTH-1]`). This is the only module so far with actual internal state — everything up to this point (ALU, ALU_Control, Main Control, ImmGen) has been purely combinational.

## 7. Initialization
Memory should be initialized to a known state (typically all zeros, or loaded from a `.hex`/`.mem` file via `$readmemh`/`$readmemb` for test programs) at simulation start — do not leave memory contents as `x` (unknown), since that would make `LW` results untestable/undefined until a location is explicitly written.

## 8. Functional Behavior

**Write (synchronous):**
```verilog
always @(posedge clk) begin
    if (write_enable)
        mem[address] <= write_data;
end
```

**Read (combinational):**
```verilog
assign read_data = mem[address];
```

Notes on this split:
- The write is edge-triggered so that data is committed cleanly on the clock boundary, consistent with the rest of the single-cycle datapath's register updates (PC, register file).
- The read is combinational (`assign`, not `always @(posedge clk)`) specifically because `LW` must see valid data *within the same cycle* it's requested — a registered/synchronous read would return stale data one cycle late, which is incorrect for a single-cycle design (though it becomes the correct choice later in your pipelined MEM stage, where a pipeline register absorbs the extra cycle).

## 9. Reset Behavior
No reset signal on this module. Memory contents persist across cycles by design (that's the whole point of memory) — only explicit `SW` writes change contents. Initial contents are handled via Section 7, not a reset input.

## 10. Verification
The following test cases shall be verified:

- Write to an address, then read the same address on a later cycle — confirm `read_data` matches what was written
- Write to one address, read a *different* address — confirm no cross-contamination (unwritten address reads back as its initialized value, typically 0)
- `write_enable = 0` while `write_data`/`address` are driven — confirm memory is NOT modified
- Read immediately after write (same simulation time, next statement) — confirm the write took effect on the clock edge before the read is checked, not before
- Multiple sequential writes to different addresses, then read back all of them — confirm no address aliasing/overwrite bugs
- Boundary addresses (address 0, and the last valid address given your `DEPTH`) — confirm correct behavior at memory array edges

## 11. Notes
- This is the first stateful (non-combinational) module in the datapath — treat its testbench with extra care, since write/read timing bugs here are a classic source of subtle single-cycle datapath failures (e.g. reading before a write has actually landed).
- `write_enable` is driven directly by Main Control's `MemWrite` output — already verified in the `MainControl` module.
- Reused without modification in the pipelined processor — sits in the MEM stage, where the read naturally aligns with the pipeline register between MEM and WB (unlike here, where it must be combinational for single-cycle correctness).
