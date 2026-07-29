# Forwarding Unit Specification

## 1. Module Name
`Forwarding_Unit`

## 2. Purpose

The Forwarding Unit resolves **data hazards** that occur when an instruction in the Execute (EX) stage needs a source operand (`rs1` or `rs2`) whose value is still in flight further down the pipeline — either being computed in the Execute stage of an *older* instruction (now sitting in EX/MEM) or having just been computed and sitting in MEM/WB, not yet written back to the Register File.

Without forwarding, the pipeline would need to stall for 2–3 cycles every time back-to-back instructions depend on each other's results (a very common pattern, e.g. `add x1, x2, x3` followed immediately by `sub x4, x1, x5`). Forwarding avoids these stalls entirely for ALU-to-ALU dependencies by routing the not-yet-written-back result directly into the ALU's input muxes, bypassing the Register File.

This module is purely combinational — it only computes **select signals** for two muxes that sit in front of the ALU. It does not perform any data movement itself.

## 3. Inputs

| Signal | Width | Description |
|---------|:----:|-------------|
| ID_EX_rs1 | 5 | Source register 1 address of the instruction currently in EX stage |
| ID_EX_rs2 | 5 | Source register 2 address of the instruction currently in EX stage |
| EX_MEM_rd | 5 | Destination register address of the instruction currently in EX/MEM (one stage ahead — was in EX last cycle) |
| EX_MEM_RegWrite | 1 | Whether EX/MEM's instruction will write to the Register File |
| MEM_WB_rd | 5 | Destination register address of the instruction currently in MEM/WB (two stages ahead) |
| MEM_WB_RegWrite | 1 | Whether MEM/WB's instruction will write to the Register File |

## 4. Outputs

| Signal | Width | Description |
|---------|:----:|-------------|
| ForwardA | 2 | Select signal for the mux feeding ALU `operand_A` (sourced from `rs1`) |
| ForwardB | 2 | Select signal for the mux feeding ALU `operand_B`'s register-side input (sourced from `rs2`, before the existing `ALUSrc` mux) |

### ForwardA / ForwardB Encoding

| Value | Meaning |
|-------|---------|
| `2'b00` | No forwarding — use `ID_EX.rs1_data` / `ID_EX.rs2_data` directly (normal Register File read value) |
| `2'b10` | Forward from **EX/MEM** — use `EX_MEM.alu_result` |
| `2'b01` | Forward from **MEM/WB** — use the MEM/WB write-back value (already resolved by the WB-stage mux: `MemToReg`/`Jump` combination) |

## 5. Functional Behavior

### Priority Rule
EX/MEM forwarding always takes priority over MEM/WB forwarding when both could apply to the same register, because EX/MEM holds the **more recently produced** value — it is only one instruction ahead of the one needing it, versus two for MEM/WB. Forwarding the older MEM/WB value in that situation would silently use stale data.

### ForwardA Logic (for rs1)

```verilog
if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1))
    ForwardA = 2'b10;                 // forward from EX/MEM
else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs1))
    ForwardA = 2'b01;                 // forward from MEM/WB
else
    ForwardA = 2'b00;                 // no hazard, use register file value
```

### ForwardB Logic (for rs2)

```verilog
if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2))
    ForwardB = 2'b10;
else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs2))
    ForwardB = 2'b01;
else
    ForwardB = 2'b00;
```

### Why `rd != 0` matters
Register `x0` is hardwired to zero and can never legitimately be a forwarding target — some instructions may have `rd = 0` as an artifact of encoding (e.g. certain NOP-like patterns), and forwarding to `x0` would be meaningless. Excluding it prevents an accidental false-positive match.

### Mux Placement
`ForwardA`'s mux sits directly in front of the ALU's `operand_A` input — a straightforward 3-way mux between `ID_EX.rs1_data`, `EX_MEM.alu_result`, and the MEM/WB write-back value.

`ForwardB`'s mux sits in front of the **existing `ALUSrc` mux**, not after it — it only ever supplies the "register" side of that mux (the `rs2`-sourced operand). This is because forwarding is only relevant when the ALU's second operand actually comes from a register (R-type instructions); for I-type/LW/SW, `operand_B` comes from the immediate via `ImmSrc`/`ImmGen`, which is never subject to a register data hazard, so `ALUSrc` still makes the final choice between the (possibly-forwarded) register value and the immediate.

## 6. Reset Behavior
Not applicable — this module is purely combinational, with no clock or reset input. Outputs update immediately whenever any input changes.

## 7. Verification Strategy

The following test cases shall be verified:

- No hazard: `EX_MEM_rd` and `MEM_WB_rd` both differ from `ID_EX_rs1`/`ID_EX_rs2` → both `ForwardA`/`ForwardB` = `2'b00`
- EX/MEM hazard on rs1 only → `ForwardA = 2'b10`, `ForwardB = 2'b00`
- EX/MEM hazard on rs2 only → `ForwardB = 2'b10`, `ForwardA = 2'b00`
- EX/MEM hazard on both rs1 and rs2 (e.g. `add x1, x1, x1`-style pattern) → both `ForwardA` and `ForwardB = 2'b10`
- MEM/WB hazard only (no EX/MEM conflict) → correctly resolves to `2'b01`
- **Priority case:** both EX/MEM and MEM/WB target the same `rs1` → `ForwardA` must resolve to `2'b10` (EX/MEM wins), not `2'b01`
- `EX_MEM_RegWrite = 0` with matching `rd` → must NOT forward (confirms `RegWrite` gating works, not just address matching)
- `MEM_WB_RegWrite = 0` with matching `rd` → must NOT forward
- `EX_MEM_rd = 0` (x0) with `RegWrite=1` and address match → must NOT forward (confirms the `rd != 0` exclusion)
- Same tests repeated for `rs2`/`ForwardB` independently of `rs1`/`ForwardA`

## 8. Notes
- Purely combinational — no clock, no reset, no internal state.
- This module only computes select signals; the actual 3-way muxes feeding the ALU are instantiated separately in the `Datapath`, not inside this module.
- Depends on signals already available in `EX_MEM` and `MEM_WB` pipeline registers — no new signals needed there beyond what's already specified (`rd`, `RegWrite`).
- Does not handle **load-use hazards** (where the needed value isn't computed yet even with forwarding, because it's still being read from Data Memory in MEM stage) — that case requires a one-cycle stall regardless of forwarding, and is handled separately by the Hazard Detection Unit (next module).
- Reused without modification if the design is ever extended — this module's logic doesn't change based on which specific ALU operation is being forwarded into, since it only concerns register dependency addresses.
