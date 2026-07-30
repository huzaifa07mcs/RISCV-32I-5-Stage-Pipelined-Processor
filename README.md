# RV32I 5-Stage Pipelined Processor

A 32-bit Single-Core RISC-V (RV32I) processor implemented in Verilog HDL.
The project was developed incrementally by first building and verifying a functionally correct **single-cycle processor**, and then converting it into a classic **five-stage pipelined processor** with data forwarding, hazard detection, load-use stalling, and branch handling.

---

# Project Objectives

- Design and implement a 32-bit Single-Core RISC-V (RV32I) processor.
- Develop and verify a functionally correct single-cycle processor.
- Convert the design into a five-stage pipelined processor.
- Implement forwarding, hazard detection, load-use stall logic, and branch handling.
- Follow modular RTL design and verification practices.
- Maintain proper documentation and verification for every hardware module.

---

# Processor Specifications

| Feature | Specification |
|----------|---------------|
| ISA | RV32I (Subset) |
| Architecture | Single-Core |
| Pipeline | 5-Stage (IF, ID, EX, MEM, WB) |
| Data Width | 32-bit |
| Register File | 32 × 32-bit |
| Instruction Memory | Word-addressable |
| Data Memory | Word-addressable |
| Language | Verilog HDL |
| Development Flow | Single-Cycle → Pipelined |
| Branch Strategy | Predict-Not-Taken, EX-stage resolution |

---

# Supported Instructions

| Type | Instructions |
|------|--------------|
| R-Type | ADD, SUB, AND, OR, XOR, SLT |
| I-Type | ADDI, LW |
| S-Type | SW |
| B-Type | BEQ, BNE |
| J-Type | JAL |

---

# Project Structure

```text
RISCV-32I-5-Stage-Pipelined-Processor/
│
├── docs/
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
├── rtl/
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
├── tb/
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
├── Test Programs/
│   ├── Single_Cycle_Hex.mem
│   ├── Pipelined_Hex.mem
│   ├── Single-Cycle_Test_Instructions.md
│   └── Pipelined_Test_Instructions.md
│
├── Verification Results/
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

# Development Workflow

Each module follows the workflow below:

1. Define the module specification.
2. Implement the RTL in Verilog HDL.
3. Develop the corresponding testbench.
4. Perform functional simulation.
5. Verify expected behavior.
6. Fix bugs if required.
7. Commit the verified module to GitHub.

---

# Completed Hardware Modules

## Program Counter (PC)
Stores the current instruction address and updates it every clock cycle, with stall support for pipeline hazards.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Instruction Memory
Stores program instructions and fetches them using the Program Counter (word-addressable).
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Register File
32 general-purpose RV32I registers, two read ports, one write port, x0 hardwired to zero.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Immediate Generator
Generates immediate values for I, S, B, and J instruction formats.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## ALU
Performs ADD, SUB, AND, OR, XOR, SLT operations.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Data Memory
Stores load/store data with synchronous writes and combinational reads (word-addressable).
**RTL ✅ | Testbench ✅ | Simulation ✅**

## ALU Control Unit
Generates ALU control signals from ALUOp, funct3, and funct7.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Main Control Unit
Generates all datapath control signals: RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, Jump, ALUOp, ImmSrc.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Single-Cycle Datapath
Integrates all verified modules into a complete RV32I single-cycle processor — preserved as a reference implementation.
**RTL ✅ | Simulation ✅ | Verification ✅**

## IF/ID, ID/EX, EX/MEM, MEM/WB Pipeline Registers
Latch and propagate control/data signals between pipeline stages, with flush and stall support.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Forwarding Unit
Resolves RAW data hazards by forwarding EX/MEM and MEM/WB results directly into the EX stage.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Hazard Detection Unit
Detects load-use hazards and stalls the IF and ID stages by one cycle, using MemToReg as the load flag.
**RTL ✅ | Testbench ✅ | Simulation ✅**

## Pipelined Datapath
Full 5-stage pipeline integration with forwarding, hazard detection, and predict-not-taken branch handling (2-cycle misprediction penalty, flushing IF/ID and ID/EX).
**RTL ✅ | Simulation ✅ | Verification ✅**

---

# Processor Verification

The complete pipelined processor has been verified with a comprehensive RISC-V test program executing all supported instruction types, including load-use hazards, forwarding chains, taken/not-taken branches, and jumps.

### Verified Instructions
ADDI, ADD, SUB, AND, OR, XOR, SLT, LW, SW, BEQ, BNE, JAL

### Verified Functionality
- Correct PC update and stall behavior
- Correct instruction fetch, decode, and register read/write
- Correct immediate generation for all formats
- Correct ALU operations and forwarding across dependent instructions
- Correct load-use hazard detection and stalling
- Correct memory read/write
- Correct write-back path (including JAL link register)
- Correct branch resolution (BEQ/BNE) with predict-not-taken flushing
- Correct jump handling (JAL) with pipeline flush
- Correct end-of-program self-loop behavior

Full cycle-by-cycle simulation results, waveforms, and final register/memory verification are documented in [`Verification Results/Simulation Test Results.md`](./Verification%20Results/Simulation%20Test%20Results.md).

---

# Project Progress

| Module | RTL | Testbench | Simulation | Status |
|---------|:---:|:---------:|:----------:|:------:|
| Program Counter | ✅ | ✅ | ✅ | Complete |
| Instruction Memory | ✅ | ✅ | ✅ | Complete |
| Register File | ✅ | ✅ | ✅ | Complete |
| Immediate Generator | ✅ | ✅ | ✅ | Complete |
| ALU | ✅ | ✅ | ✅ | Complete |
| Data Memory | ✅ | ✅ | ✅ | Complete |
| ALU Control | ✅ | ✅ | ✅ | Complete |
| Main Control | ✅ | ✅ | ✅ | Complete |
| Single-Cycle Datapath | ✅ | ✅ | ✅ | Complete |
| IF/ID Register | ✅ | ✅ | ✅ | Complete |
| ID/EX Register | ✅ | ✅ | ✅ | Complete |
| EX/MEM Register | ✅ | ✅ | ✅ | Complete |
| MEM/WB Register | ✅ | ✅ | ✅ | Complete |
| Forwarding Unit | ✅ | ✅ | ✅ | Complete |
| Hazard Detection Unit | ✅ | ✅ | ✅ | Complete |
| Pipelined Datapath | ✅ | ✅ | ✅ | Complete |
| Full Processor Verification | ✅ | ✅ | ✅ | Complete |

---

# Current Milestone

Completed:

- ✅ Single-cycle processor specification, RTL, and verification
- ✅ Pipeline conversion with all four pipeline registers
- ✅ Forwarding Unit and Hazard Detection Unit
- ✅ Load-use stall logic
- ✅ Predict-not-taken branch handling with flush logic
- ✅ Full pipelined datapath integration
- ✅ End-to-end program execution and verification

---


# Tools

- Verilog HDL
- Xilinx Vivado
- GitHub

---

# License

This project is developed for learning, educational, and portfolio purposes.
