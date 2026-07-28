# RV32I 5-Stage Pipelined Processor

A 32-bit Single-Core RISC-V (RV32I) processor implemented in Verilog HDL.  
The project is being developed incrementally by first building and verifying a functionally correct **single-cycle processor** and then converting it into a classic **five-stage pipelined processor**.

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
| Current Implementation | Single-Cycle Processor |
| Target Architecture | 5-Stage Pipeline |
| Data Width | 32-bit |
| Register File | 32 × 32-bit |
| Instruction Memory | 256 × 32-bit |
| Data Memory | 256 × 32-bit |
| Language | Verilog HDL |
| Development Flow | Single-Cycle → Pipelined |

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
│   ├── PC_Specification.md
│   ├── InstructionMemory_Specification.md
│   ├── RegisterFile_Specification.md
│   ├── ImmediateGenerator_Specification.md
│   ├── ALU_Specification.md
│   ├── DataMemory_Specification.md
│   ├── ALUControl_Specification.md
│   ├── MainControl_Specification.md
│   └── Datapath_Specification.md
│
├── rtl/
│   ├── ProgramCounter.v
│   ├── InstructionMemory.v
│   ├── RegisterFile.v
│   ├── ImmGen.v
│   ├── ALU.v
│   ├── DataMemory.v
│   ├── ALU_Control.v
│   ├── MainControl.v
│   ├── Datapath.v
│   └── Top.v
│
├── tb/
│   ├── tb_ProgramCounter.v
│   ├── tb_InstructionMemory.v
│   ├── tb_RegisterFile.v
│   ├── tb_ImmGen.v
│   ├── tb_ALU.v
│   ├── tb_DataMemory.v
│   ├── tb_ALU_Control.v
│   ├── tb_MainControl.v
│   └── tb_Top.v
│
├── programs/
│   ├── program.mem
│   └── Instructions.md
│
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

### Purpose

- Stores the current instruction address.
- Updates the PC every clock cycle.

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Instruction Memory

### Purpose

- Stores program instructions.
- Fetches instructions using the Program Counter.
- Supports byte-addressed instruction fetch (`address[31:2]`).

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Register File

### Purpose

- Implements 32 general-purpose RV32I registers.
- Supports two read ports and one write port.
- Register x0 is permanently hardwired to zero.

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Immediate Generator

### Purpose

Generates immediate values from RV32I instructions.

### Supported Formats

- I-Type
- S-Type
- B-Type
- J-Type

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## ALU (Arithmetic Logic Unit)

### Purpose

Performs arithmetic and logical operations.

### Supported Operations

- ADD
- SUB
- AND
- OR
- XOR
- SLT

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Data Memory

### Purpose

- Stores data for load and store instructions.
- Supports synchronous writes and combinational reads.
- Uses byte-addressed memory access (`address[9:2]`).

### Supported Instructions

- LW
- SW

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## ALU Control Unit

### Purpose

Generates ALU control signals using:

- ALUOp
- funct3
- funct7

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Main Control Unit

### Purpose

Generates all datapath control signals.

### Generated Control Signals

- RegWrite
- ALUSrc
- MemWrite
- MemtoReg
- Branch
- Jump
- ALUOp
- ImmSrc

### Status

- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Single-Cycle Datapath

### Purpose

Integrates all verified hardware modules into a complete RV32I single-cycle processor.

### Features

- Instruction Fetch
- Instruction Decode
- Register Read
- Immediate Generation
- ALU Execution
- Data Memory Access
- Register Write Back
- Branch Decision Logic
- Jump (JAL) Support
- PC + 4 Logic
- PC + Immediate Logic
- ALUSrc Multiplexer
- MemtoReg Multiplexer
- JAL Write-Back Multiplexer

### Status

- RTL Implementation ✅
- Functional Simulation ✅
- Processor Verification ✅

---

# Processor Verification

The integrated single-cycle processor has been verified using a custom RISC-V program executing multiple instructions.

### Verified Instructions

- ADDI
- ADD
- SUB
- AND
- OR
- XOR
- SLT
- LW
- SW
- BEQ
- BNE
- JAL

### Verified Functionality

- Correct PC update
- Correct instruction fetch
- Correct instruction decode
- Correct register read/write
- Correct immediate generation
- Correct ALU operations
- Correct memory read/write
- Correct write-back path
- Correct branch handling (BEQ/BNE)
- Correct jump handling (JAL)

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
| Single-Cycle Processor Verification | ✅ | ✅ | ✅ | Complete |
| Pipeline Conversion | ⏳ | ⏳ | ⏳ | Not Started |

---

# Current Milestone

Completed:

- ✅ Processor specification
- ✅ Modular RTL implementation
- ✅ Individual module verification
- ✅ Single-cycle datapath integration
- ✅ Complete processor simulation
- ✅ Program execution verification
- ✅ Branch and jump verification
- ✅ Memory subsystem verification

---

# Current Stage

## Next Task: Pipeline Conversion

The verified single-cycle processor will now be converted into a classic five-stage pipelined processor.

Pipeline stages:

### IF Stage

- Program Counter
- Instruction Memory

### ID Stage

- Instruction Decode
- Register File
- Immediate Generator
- Main Control

### EX Stage

- ALU
- ALU Control
- Branch Address Calculation

### MEM Stage

- Data Memory

### WB Stage

- Register Write Back

---

# Planned Pipeline Features

- IF/ID Pipeline Register
- ID/EX Pipeline Register
- EX/MEM Pipeline Register
- MEM/WB Pipeline Register
- Forwarding Unit
- Hazard Detection Unit
- Load-Use Stall Logic
- Branch Flush Logic
- Pipeline Control Logic
- Complete Five-Stage Pipeline Integration

---

# Tools

- Verilog HDL
- Xilinx Vivado 2019.1
- GitHub

---

# License

This project is developed for learning, educational, and portfolio purposes.
