# RV32I 5-Stage Pipelined Processor

A 32-bit single-core RISC-V (RV32I subset) processor implemented from scratch in Verilog HDL — designed, verified, and pipelined incrementally following a professional RTL development workflow: specification → implementation → testbench → simulation → integration.

The project was built in two phases: a functionally verified single-cycle processor, followed by its conversion into a classic five-stage pipelined processor with data forwarding, hazard detection, load-use stalling, and predict-not-taken branch handling.

---

## Table of Contents
- [Highlights](#highlights)
- [Processor Specifications](#processor-specifications)
- [Supported Instructions](#supported-instructions)
- [Pipeline Architecture](#pipeline-architecture)
- [Hazard Handling](#hazard-handling)
- [RTL Schematic](#rtl-schematic)
- [Repository Structure](#repository-structure)
- [Development Workflow](#development-workflow)
- [Module Status](#module-status)
- [Verification](#verification)
- [Simulation Results Summary](#simulation-results-summary)
- [Waveforms](#waveforms)
- [Future Work](#future-work)
- [Tools](#tools)
- [License](#license)

---

## Highlights
- Complete RV32I subset datapath, built and verified module-by-module before integration
- Two working, independently verified processors in one repo: single-cycle (reference) and 5-stage pipelined (active)
- Full hazard handling: data forwarding, load-use stall detection, and control hazard flushing
- Predict-not-taken branch resolution in the EX stage
- Every module backed by a written specification and a self-checking testbench
- End-to-end verification against a hand-traced test program, with cycle-accurate simulation metrics

---

## Processor Specifications

| Feature | Specification |
| :--- | :--- |
| **ISA** | RV32I (Subset) |
| **Architecture** | Single-Core |
| **Pipeline** | 5-Stage (IF, ID, EX, MEM, WB) |
| **Data Width** | 32-bit |
| **Address Width** | 32-bit |
| **Register File** | 32 × 32-bit, x0 hardwired to zero |
| **Memory** | Word-addressable, byte-semantics preserved |
| **Endianness** | Little Endian |
| **Clock** | Single clock domain |
| **Reset** | Synchronous, active-high |
| **Branch Strategy** | Predict-Not-Taken, EX-stage resolution |
| **Language** | Verilog HDL |
| **Simulation Tool** | Xilinx Vivado (XSim) |

---

## Supported Instructions

| Type | Instructions |
| :--- | :--- |
| **R-Type** | ADD, SUB, AND, OR, XOR, SLT |
| **I-Type** | ADDI, LW |
| **S-Type** | SW |
| **B-Type** | BEQ, BNE |
| **J-Type** | JAL |

---

## Pipeline Architecture

| Stage | Description |
| :--- | :--- |
| **IF** | Instruction Fetch — PC-driven instruction memory read |
| **ID** | Instruction Decode — register read, immediate generation, control decode |
| **EX** | Execute — ALU operation, branch/jump target resolution |
| **MEM** | Memory Access — load/store to data memory |
| **WB** | Write Back — result written to the register file |

Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) carry data and control signals between stages, with support for stalling and flushing.

---

## Hazard Handling

| Mechanism | Purpose |
| :--- | :--- |
| **Forwarding Unit** | Resolves RAW data hazards by forwarding EX/MEM and MEM/WB results directly into the EX stage, avoiding unnecessary stalls |
| **Hazard Detection Unit** | Detects load-use hazards (an instruction using data from an immediately preceding LW) and stalls IF/ID for one cycle |
| **Branch Handling** | Predict-not-taken; branches and jumps resolve in EX, and a taken outcome flushes IF/ID and ID/EX (2-cycle misprediction penalty) |

---

## RTL Schematic

Synthesized schematic of the pipelined datapath:

![RTL Schematic](RTL%20Schematic.png)

---

## Repository Structure

```text
RISCV-32I-5-Stage-Pipelined-Processor/
│
├── docs/                                   Module and system-level specifications
│   ├── Specification.md
│   ├── SingleCycle_Datapath_Specification.md
│   ├── Datapath_Pipelined_Specification.md
│   ├── PC_Specification.md
│   ├── InstructionMemory_Specification.md
│   ├── DataMemory_Specification.md
│   ├── RegisterFile_Specification.md
│   ├── ImmediateGenerator_Specification.md
│   ├── ALU_Specification.md
│   ├── ALUControl_Specification.md
│   ├── MainControl_Specification.md
│   ├── IF-ID_Specification.md
│   ├── ID_EX_SPECIFICATION.md
│   ├── EX-MEM_Specification.md
│   ├── MEM-WB_Specification.md
│   ├── Forwarding_Unit_Specification.md
│   └── HazardDetectionUnit_Specification.md
│
├── rtl/                                    Verilog source (single-cycle + pipelined)
│   ├── ALU.v
│   ├── ALUControl.v
│   ├── DataMemory.v
│   ├── EX_MEM.v
│   ├── Forwarding_Unit.v
│   ├── HazardDetectionUnit.v
│   ├── ID_EX.v
│   ├── IF_ID.v
│   ├── ImmGen.v
│   ├── InstructionMemory.v
│   ├── MEM_WB.v
│   ├── MainControl.v
│   ├── PC.v
│   ├── PipelinedDatapath.v
│   ├── PipelinedTop.v
│   ├── RegisterFile.v
│   ├── SingleCycleDatapath.v
│   └── SingleCycleTop.v
│
├── tb/                                     Self-checking testbenches
│   ├── tb_ALU.v
│   ├── tb_ALUControl.v
│   ├── tb_DataMemory.v
│   ├── tb_EX_MEM.v
│   ├── tb_Forwarding_Unit.v
│   ├── tb_Hazard_Detection_Unit.v
│   ├── tb_ID_EX.v
│   ├── tb_IF_ID.v
│   ├── tb_ImmGen.v
│   ├── tb_InstructionMemory.v
│   ├── tb_MEM_WB.v
│   ├── tb_MainControl.v
│   ├── tb_PC.v
│   ├── tb_PipelinedTop.v
│   ├── tb_RegisterFile.v
│   └── tb_SinglecycleTop.v
│
├── Test Programs/                          Assembled test programs (hex + listings)
│   ├── Single_Cycle_Hex.mem
│   ├── Pipelined_Hex.mem
│   ├── Single-Cycle_Test_Instructions.md
│   └── Pipelined_Test_Instructions.md
│
├── Verification Results/                   Simulation logs, metrics, and waveforms
│   ├── Simulation Test Results.md
│   ├── Execution Results.png
│   ├── Waveform 1.png
│   ├── Waveform 2.png
│   ├── Waveform 3.png
│   ├── Waveform 4.png
│   └── Full Waveform.wcfg
│
├── RTL Schematic.png
└── README.md
```

---


## Development Workflow

Every module in this project was built following the same disciplined flow:

1. **Specify** — write the module spec (purpose, ports, behavior, edge cases) before writing any RTL
2. **Implement** — write the Verilog RTL
3. **Test** — write a self-checking testbench (no manual waveform inspection required to pass/fail)
4. **Simulate** — run functional simulation in Vivado XSim
5. **Verify** — confirm expected behavior against the spec
6. **Fix** — debug and correct any issues found
7. **Integrate** — commit the verified module and integrate into the datapath

This mirrors a real hardware development flow rather than a single "write everything, debug at the end" pass.

---

## Module Status

| Module | Spec | RTL | Testbench | Simulation | Status |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Program Counter** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Instruction Memory** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Register File** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Immediate Generator** | ✅ | ✅ | ✅ | ✅ | Complete |
| **ALU** | ✅ | ✅ | ✅ | ✅ | Complete |
| **ALU Control** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Main Control** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Data Memory** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Single-Cycle Datapath** | ✅ | ✅ | ✅ | ✅ | Complete (reference) |
| **IF/ID Register** | ✅ | ✅ | ✅ | ✅ | Complete |
| **ID/EX Register** | ✅ | ✅ | ✅ | ✅ | Complete |
| **EX/MEM Register** | ✅ | ✅ | ✅ | ✅ | Complete |
| **MEM/WB Register** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Forwarding Unit** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Hazard Detection Unit** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Pipelined Datapath** | ✅ | ✅ | ✅ | ✅ | Complete |
| **Full Processor Integration** | ✅ | ✅ | — | ✅ | Complete |

---

## Verification

The complete pipelined processor was verified against a comprehensive RISC-V test program exercising every supported instruction, load-use hazards, forwarding chains, taken and not-taken branches, and jumps.

**Verified instructions:** `ADDI` `ADD` `SUB` `AND` `OR` `XOR` `SLT` `LW` `SW` `BEQ` `BNE` `JAL`

**Verified functionality:**
- Correct PC update, including stall behavior
- Correct instruction fetch, decode, and register read/write
- Correct immediate generation across all instruction formats
- Correct ALU operation and forwarding across dependent instructions
- Correct load-use hazard detection and single-cycle stalling
- Correct data memory read/write
- Correct write-back path, including the JAL link-register override (PC + 4)
- Correct branch resolution (BEQ/BNE), both taken and not-taken
- Correct jump handling with pipeline flush
- Correct steady-state behavior at the program's end-of-execution self-loop

Full cycle-by-cycle results and final register/memory state comparison are documented in `Verification Results/Simulation Test Results.md`.

---

## Simulation Results Summary

| Metric | Value |
| :--- | :--- |
| **Total Executed Cycles** | 113 |
| **Total Register Writes** | 71 |
| **Total Data Memory Writes** | 9 |
| **Control Hazards Evaluated (Branches/Jumps)** | 9 |
| **Hazard Stalls** | 11 |
| **Pipeline Flushes** | 7 |
| **Result** | All checks passed — program execution verified correct against hand-traced expected state |

---

## Waveforms

Captured from Vivado XSim, showing PC progression, pipeline register contents, forwarding signals, and stall/flush activity:

Console execution log:
![Execution Results](Verification%20Results/Execution%20Results.png)

Pipeline waveforms:
![Waveform 1](Verification%20Results/Waveform%201.png)
![Waveform 2](Verification%20Results/Waveform%202.png)
![Waveform 3](Verification%20Results/Waveform%203.png)
![Waveform 4](Verification%20Results/Waveform%204.png)

The full signal configuration is available in `Verification Results/Full Waveform.wcfg` — open it in Vivado's waveform viewer to reproduce this exact signal layout.

---

## Future Work

- **ID-stage branch comparator** — move branch comparison earlier to resolve branches in ID instead of EX, reducing the misprediction penalty from 2 cycles to 1
- Continued documentation and diagramming as the project is extended

---

## Tools

- **Verilog HDL** — RTL implementation
- **Xilinx Vivado (XSim)** — simulation and synthesis
- **RARS** — RISC-V assembler used to assemble and cross-check test programs
- **Git / GitHub** — version control, with incremental commits per module

---

## License

This project was developed for learning, educational, and portfolio purposes.
