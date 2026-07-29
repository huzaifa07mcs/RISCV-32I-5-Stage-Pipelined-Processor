# Hazard Detection Unit Specification

## 1. Module Name
`Hazard_Detection_Unit`

## 2. Purpose

The Hazard Detection Unit detects **load-use hazards** — the one data hazard forwarding cannot resolve on its own. This occurs when an instruction needs a value that is being produced by an immediately preceding `LW` instruction, but that value is not yet available even with forwarding, because a load's result only becomes valid at the end of the Memory stage (after the actual memory read), not at the end of Execute like ALU results.

When this condition is detected, the pipeline must stall for exactly one cycle: hold the PC and IF/ID register in place, and insert a single-cycle bubble into ID/EX, giving the load instruction time to reach MEM/WB before the dependent instruction reaches EX.

This module is purely combinational — it only computes a single `stall` signal. It does not perform any data movement or control override itself; the `stall` output is consumed by the PC, IF/ID register, and ID/EX register elsewhere in the `Datapath`.

## 3. Inputs

| Signal | Width | Description |
|---------|:----:|-------------|
| ID_EX_rd | 5 | Destination register of the instruction currently in EX stage |
| ID_EX_MemToReg | 1 | Doubles as the "this instruction is a load" flag in this design — only LW sets `MemToReg=1` |
| IF_ID_rs1 | 5 | Source register 1 of the instruction currently in ID stage (about to enter EX next cycle) |
| IF_ID_rs2 | 5 | Source register 2 of the instruction currently in ID stage |

## 4. Outputs

| Signal | Width | Description |
|---------|:----:|-------------|
| stall | 1 | Asserted for one cycle when a load-use hazard is detected |

This single output fans out to three destinations elsewhere in the `Datapath`:
- `programcounter.stall` — holds the PC, preventing a new instruction from being fetched
- `IF_ID.stall` — holds the currently fetched instruction in place for one extra cycle
- `ID_EX.flush` — inserts a one-cycle bubble (NOP) into EX stage, so the dependent instruction doesn't execute with a stale/incorrect operand

## 5. Functional Behavior

```verilog
assign stall = ID_EX_MemToReg &&
               (ID_EX_rd != 5'b0) &&
               ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2));
```

### Why `ID_EX_rd != 0` matters
Same reasoning as the Forwarding Unit — `x0` is hardwired to zero and can never be a legitimate hazard target. Without this exclusion, an instruction with `rd=0` (which can occur as an encoding artifact) would falsely trigger a stall against any instruction reading `x0`, which is always meaningless anyway since reads of `x0` always return zero regardless of any in-flight write.

### Why this checks `ID_EX` (not `EX_MEM`)
The hazard only exists for **one specific cycle position**: the load must be exactly one instruction ahead of the one that needs its result — i.e., the load is in EX while the dependent instruction is in ID, about to enter EX next cycle. If the load has already moved to EX/MEM by the time the dependent instruction reaches EX, forwarding (from EX/MEM) already handles it correctly with no stall needed. Checking `EX_MEM` here as well would incorrectly stall for a case forwarding already solves.

### One-cycle duration
The stall only needs to last one cycle. Once the bubble is inserted and the load moves into EX/MEM, forwarding immediately becomes available to supply the correct value into the now-executing dependent instruction — no repeated stalling is needed for the same hazard.

## 6. Reset Behavior
Not applicable — this module is purely combinational, with no clock or reset input. The `stall` output updates immediately whenever any input changes.

## 7. Verification Strategy

The following test cases shall be verified:

- No hazard: `ID_EX_rd` differs from both `IF_ID_rs1` and `IF_ID_rs2` → `stall = 0`
- Load-use hazard on rs1: `ID_EX_MemToReg=1`, `ID_EX_rd == IF_ID_rs1` → `stall = 1`
- Load-use hazard on rs2: `ID_EX_MemToReg=1`, `ID_EX_rd == IF_ID_rs2` → `stall = 1`
- Load-use hazard on both rs1 and rs2 simultaneously → `stall = 1` (single condition, not double-counted)
- Matching `rd` but `MemToReg=0` (non-load instruction, e.g. R-type) → `stall = 0` — confirms this only triggers for actual loads, not any ALU-result dependency (which forwarding already handles without a stall)
- Matching `rd` but `rd = 0` (x0) → `stall = 0` — confirms the x0 exclusion
- Back-to-back stall scenarios: confirm `stall` correctly de-asserts the cycle after the bubble is inserted (once the load has advanced to EX/MEM), assuming the test harness models the pipeline registers advancing between checks

## 8. Notes
- Purely combinational — no clock, no reset, no internal state.
- Depends on `MemToReg` as a load-instruction flag rather than a dedicated `MemRead` signal, consistent with the design decision already documented in the `EX_MEM` and `MEM_WB` specs.
- The `stall` output must be wired to exactly three places in `Datapath`: `programcounter.stall`, `IF_ID.stall`, and `ID_EX.flush`. `ID_EX.flush` is reused here rather than adding a separate "bubble" port, since a hazard-induced bubble and a branch/jump flush both reduce to the same action on `ID_EX` — clearing all control signals for one cycle.
- Does not detect or resolve control hazards (branches/jumps) — that logic lives separately in the EX-stage branch resolution and flush signals already designed for `IF_ID`/`ID_EX`.
- This module only concerns the specific one-cycle-away load-use case; all other data hazards (ALU-to-ALU dependencies at any distance) are fully resolved by the Forwarding Unit without any stall.
