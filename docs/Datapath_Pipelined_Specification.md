# Datapath_Pipelined Specification

## 1. Module Name
`Datapath_Pipelined`

## 2. Purpose
This module implements the 5-stage pipelined version of the RV32I single-core processor, built by converting the already-verified single-cycle `Datapath` into a pipelined design. It reuses every functional submodule from Phase 1 (PC, Instruction Memory, Register File, ImmGen, ALU, ALU_Control, MainControl, Data Memory) without modification to their internal logic, and adds:

- Four pipeline registers (`IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`) separating the five stages
- A `Forwarding_Unit` and two new muxes resolving ALU-to-ALU data hazards without stalling
- A `Hazard_Detection_Unit` resolving load-use hazards via a one-cycle stall
- Branch/jump resolution performed combinationally in EX stage, with a backward correction path to IF stage (predict-not-taken strategy)

This is a separate module from the single-cycle `Datapath`, kept alongside it in the repository as a verified reference model — not a replacement.

## 3. Submodules Instantiated

| Module | Role | Status |
|---|---|---|
| programcounter | PC, now with `stall` input | Verified (updated) |
| InstructionMemory | Instruction fetch | Verified |
| IF_ID | Pipeline register: IF → ID | Verified |
| RegisterFile | Register read/write | Verified |
| ImmGen | Immediate decode | Verified |
| MainControl | Control signal decode | Verified |
| ID_EX | Pipeline register: ID → EX | Verified |
| ALU_Control | ALU op decode (now instantiated in EX stage) | Verified |
| ALU | Arithmetic/logic | Verified |
| Forwarding_Unit | ALU-to-ALU hazard resolution | Verified |
| Hazard_Detection_Unit | Load-use hazard detection | Verified |
| EX_MEM | Pipeline register: EX → MEM | Verified |
| DataMemory | Load/store memory | Verified |
| MEM_WB | Pipeline register: MEM → WB | Verified |

## 4. Stage-by-Stage Wiring

### IF Stage
- `pc_plus4 = pc_current + 4`
- `flush_control = ex_branch_taken | ex_jump` — asserted when EX stage detects a misprediction (branch taken) or a jump, requiring PC correction
- `pc_next = flush_control ? ex_target : pc_plus4` — predict-not-taken: normally just advance; only override when EX says otherwise
- `stall` (from Hazard_Detection_Unit) freezes `programcounter` and `IF_ID`
- `IF_ID.flush` is driven by `flush_control` — clears the wrongly-fetched instruction on a misprediction

### IF/ID → ID Stage
- `IF_ID` outputs feed instruction field extraction (`opcode`, `rs1`, `rs2`, `rd`, `funct3`, `funct7_5`), `RegisterFile` read ports, `ImmGen`, and `MainControl` — same decode logic as single-cycle, just reading from `IF_ID`'s registered outputs instead of directly from `InstructionMemory`

### ID/EX → EX Stage
- `ID_EX` carries forward: `pc`, `pc_plus4`, `rs1_data`, `rs2_data`, `imm`, `rs1`, `rs2`, `rd`, `funct3`, `funct7_5`, `ALUSrc`, `ALUOp`, `Branch`, `Jump`, `MemWrite`, `RegWrite`, `MemToReg`
- `ALU_Control` is instantiated here, consuming `ID_EX.ALUOp`, `ID_EX.funct3`, `ID_EX.funct7_5` → produces `ALUControl` for the `ALU` in the same stage
- `Forwarding_Unit` computes `ForwardA`/`ForwardB` using `ID_EX.rs1`/`rs2` against `EX_MEM.rd`/`RegWrite` and `MEM_WB.rd`/`RegWrite`
- Two muxes select ALU `operand_A`/`operand_B`'s register-side input based on `ForwardA`/`ForwardB` (no-forward = `ID_EX` value, EX/MEM-forward = `EX_MEM.alu_result`, MEM/WB-forward = the WB-stage write-back value)
- Existing `ALUSrc` mux still selects between the (possibly-forwarded) `rs2` value and `ID_EX.imm` for `operand_B`
- **Branch/jump resolution happens here, combinationally:**
  - `ex_pc_plus_imm = ID_EX.pc + ID_EX.imm`
  - `ex_branch_taken = ID_EX.Branch & (ALU.Zero ^ ID_EX.funct3[0])`
  - `ex_jump = ID_EX.Jump`
  - `ex_target = ex_pc_plus_imm` (used for both branch and jump correction, same as single-cycle's shared adder)
  - These three signals route directly back to IF stage (no pipeline register) as described in Section 4's IF stage entry
  - `ID_EX.flush` is asserted by the OR of: (a) `Hazard_Detection_Unit.stall` (bubble for load-use), or (b) `ex_branch_taken | ex_jump` (bubble for control hazard correction) — both conditions insert a one-cycle NOP into ID/EX's *next* latch, though for different reasons

### EX/MEM → MEM Stage
- `EX_MEM` carries forward: `alu_result`, `rs2_data`, `rd`, `pc_plus4`, `Jump`, `MemWrite`, `RegWrite`, `MemToReg`
- `DataMemory` reads/writes using `EX_MEM.alu_result` as address, `EX_MEM.rs2_data` as store data, `EX_MEM.MemWrite` as write-enable

### MEM/WB → WB Stage
- `MEM_WB` carries forward: `alu_result`, `mem_read_data`, `rd`, `pc_plus4`, `Jump`, `RegWrite`, `MemToReg`
- Mux A: `wb_data = MEM_WB.MemToReg ? MEM_WB.mem_read_data : MEM_WB.alu_result`
- Mux B: `writeback_data = MEM_WB.Jump ? MEM_WB.pc_plus4 : wb_data`
- `writeback_data` feeds `RegisterFile.write_data`, gated by `MEM_WB.RegWrite`
- This same `writeback_data` (and `MEM_WB.rd`/`RegWrite`) is also fed back into the `Forwarding_Unit` as the MEM/WB forwarding source

## 5. Hazard Detection Unit — Placement
- **Inputs:** `ID_EX.rd`, `ID_EX.MemToReg`, `IF_ID.rs1`, `IF_ID.rs2` (the rs1/rs2 fields extracted combinationally from `IF_ID.instruction_out`, same as ID stage's decode)
- **Output `stall` fans out to:** `programcounter.stall`, `IF_ID.stall`, and is OR'd into `ID_EX.flush`

## 6. Reset Behavior
No new reset logic at this integration level beyond what each submodule/pipeline register already defines. All four pipeline registers and the PC share the same synchronous active-high `reset`.

## 7. Verification Strategy
Program-level verification, same philosophy as the single-cycle `Datapath`, but now must additionally confirm pipeline-specific correctness:

- Re-run the same test program used to verify single-cycle `Datapath`, and confirm **final register/memory state matches exactly** — this is the key cross-check that the pipeline produces identical results to the known-correct single-cycle reference, despite different cycle timing
- Back-to-back ALU-dependent instructions (e.g. `add x1,...` immediately followed by an instruction using `x1`) — confirm correct result via forwarding, no stall
- `LW` immediately followed by an instruction using the loaded register — confirm exactly one stall cycle occurs, then correct forwarded value is used
- Taken branch — confirm the two wrongly-fetched instructions are flushed (never affect register/memory state) and PC correctly redirects
- Taken `JAL` — confirm same flush behavior, correct target redirect, and correct return-address write-back through the full pipeline
- Back-to-back hazards (e.g. a load-use hazard immediately followed by a branch) — confirm both mechanisms interact correctly without conflicting

## 8. Notes
- This module is new and separate from the single-cycle `Datapath` — that file remains unmodified in the repository as a verified reference model, per the project's phased design (Phase 1 single-cycle → Phase 2 pipelined).
- All Phase 1 functional submodules (ALU, ALU_Control, MainControl, RegisterFile, ImmGen, InstructionMemory, DataMemory) are reused without any internal modification — only `programcounter` was updated (added `stall` input).
- Branch/jump resolution in EX stage, with a direct (non-registered) backward path to IF stage, keeps the misprediction penalty at exactly 2 cycles (flushing `IF_ID` and `ID_EX`), consistent with the project's predict-not-taken + flush design goal.
- `ID_EX.flush` serves two distinct purposes (load-use bubble insertion, and control-hazard correction) via a single OR'd signal — documented here explicitly so it isn't mistaken for a bug when reviewing the RTL later.
