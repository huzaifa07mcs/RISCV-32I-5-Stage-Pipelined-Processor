# Datapath_Integration — Module Specification

## 1. Module Name
`Datapath` (top-level wiring of all Phase 1 modules, pre-Top-Module wrapper)

## 2. Purpose
Integrates all previously verified modules — PC, Instruction Memory, Register File, ImmGen, ALU, ALU_Control, Main Control, Data Memory — into one complete single-cycle RV32I datapath. This module adds no new functional logic beyond muxes and adders for PC update and write-back path selection; all instruction decode/ALU/memory behavior is delegated to the already-verified submodules.

## 3. Submodules Instantiated
| Module        | Status      |
|---------------|-------------|
| PC            | Verified    |
| Instruction_Memory | Verified |
| Register_File | Verified    |
| ImmGen        | Verified    |
| ALU           | Verified    |
| ALU_Control   | Verified    |
| MainControl   | Verified    |
| Data_Memory   | Verified    |

## 4. New Logic Added at Integration Level
Beyond wiring submodule ports together, this level adds:
- **Adder 1:** `PC + 4`
- **Adder 2:** `PC + ImmGen_output` (shared by both branch and JAL targets, distinguished by `ImmSrc` at the time each instruction executes)
- **Mux 1 (branch mux):** sel = `Branch & (Zero ^ funct3[0])` → chooses Adder 1 vs Adder 2 output
- **Mux 2 (jump mux):** sel = `Jump` → chooses Mux 1 output vs Adder 2 output; feeds PC's next-value input
- **Mux A (write-back, existing MemToReg mux):** sel = `MemtoReg` → chooses ALU result vs Data Memory read_data
- **Mux B (write-back override):** sel = `Jump` → chooses Mux A output vs Adder 1 output (PC+4); feeds Register File write-data input
- **ALUSrc mux:** sel = `ALUSrc` → chooses Register File rs2 read-data vs ImmGen output; feeds ALU operand_B

## 5. Signal Connection Table

| Source | Signal | Destination |
|---|---|---|
| PC | `pc_out` | Instruction_Memory `address` |
| PC | `pc_out` | Adder 1 (`+4`) |
| PC | `pc_out` | Adder 2 (`+ ImmGen_output`) |
| Instruction_Memory | `instruction` | opcode → MainControl; rs1/rs2/rd → Register_File; funct3/funct7 → ALU_Control, branch logic; full instruction → ImmGen |
| MainControl | `RegWrite` | Register_File write-enable |
| MainControl | `ALUSrc` | ALUSrc mux select |
| MainControl | `MemWrite` | Data_Memory `write_enable` |
| MainControl | `MemtoReg` | Mux A select |
| MainControl | `Branch` | Mux 1 select logic (ANDed with computed branch-taken condition) |
| MainControl | `Jump` | Mux 2 select, Mux B select |
| MainControl | `ALUOp` | ALU_Control `ALUOp` |
| MainControl | `ImmSrc` | ImmGen `ImmSrc` |
| Register_File | `read_data1` (rs1) | ALU `operand_A` |
| Register_File | `read_data2` (rs2) | ALUSrc mux input 0; Data_Memory `write_data` |
| ImmGen | `imm_out` | ALUSrc mux input 1; Adder 2 |
| ALU_Control | `ALUControl` | ALU operation select |
| ALU | `ALU_result` | Data_Memory `address`; Mux A input 0 |
| ALU | `Zero` | Branch-taken condition logic |
| funct3[0] | — | Branch-taken condition logic (XOR with Zero) |
| Data_Memory | `read_data` | Mux A input 1 |
| Adder 1 | `PC+4` | Mux 1 input 0; Mux B input 1 |
| Adder 2 | `PC+imm` | Mux 1 input 1; Mux 2 input 1 |
| Mux 1 | output | Mux 2 input 0 |
| Mux 2 | output | PC next-value input |
| Mux A | output | Mux B input 0 |
| Mux B | output | Register_File write-data input |

## 6. Branch-Taken Logic
```verilog
wire branch_taken = Branch & (Zero ^ funct3[0]);
```
Handles both BEQ (`funct3[0]=0`, taken when `Zero=1`) and BNE (`funct3[0]=1`, taken when `Zero=0`) with a single expression.

## 7. Reset Behavior
No reset at this integration level beyond what individual submodules already define (PC's own synchronous active-high reset, per the project spec). No new stateful elements introduced here — all muxes/adders are combinational.

## 8. Verification Strategy
Integration cannot be verified signal-by-signal like individual modules — verification here is **program-level**: write small assembly test programs (as `.hex`/`.mem` files loaded into Instruction_Memory) exercising each instruction type, and confirm final register/memory state matches hand-calculated expected results. Suggested minimum test programs:

- A sequence of R-type instructions (confirm ALU ops + register write-back)
- ADDI + LW + SW sequence (confirm immediate path + memory read/write)
- A taken BEQ and a not-taken BEQ (confirm branch mux + Zero flag logic)
- A taken BNE (confirm the funct3[0] XOR fix actually works — this is the bug we specifically caught and fixed, so it must be tested directly)
- A JAL instruction (confirm both the jump target mux AND the write-back override mux — two separate things that must both work)

## 9. Notes
- This spec documents the **corrected** datapath logic after catching two integration bugs during design review: (1) the original branch condition (`Branch & Zero` alone) would have silently broken every BNE instruction, and (2) the original jump mux was wired to instruction memory output instead of the PC+immediate adder, which would have sent garbage into the PC. Both are recorded here as a reminder of why the corrected logic looks the way it does — worth keeping this note even after RTL is written, since it documents *why*, not just *what*.
- Mux B (write-back override for JAL) is a new addition beyond a bare-minimum single-cycle design — without it, JAL cannot correctly write its return address to `rd`.
