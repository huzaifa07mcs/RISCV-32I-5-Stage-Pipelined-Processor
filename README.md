# RV32I 5-Stage Pipelined Processor

A 32-bit Single-Core RISC-V (RV32I) processor implemented in Verilog HDL.  
The project is being developed incrementally by first building and verifying a functionally correct single-cycle processor and then converting it into a classic five-stage pipelined processor.

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
| Data Width | 32-bit |
| Pipeline | 5-Stage (Target) |
| Register File | 32 × 32-bit |
| Language | Verilog HDL |
| Development Flow | Single-Cycle → Pipelined |

---

# Supported Instructions (Planned)

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
│   └── ControlUnit_Specification.md
│
├── rtl/
│   ├── PC.v
│   ├── InstructionMemory.v
│   ├── RegisterFile.v
│   ├── ImmGen.v
│   ├── ALU.v
│   ├── DataMemory.v
│   ├── ALUControl.v
│   └── ControlUnit.v
│
├── tb/
│   ├── tb_PC.v
│   ├── tb_InstructionMemory.v
│   ├── tb_RegisterFile.v
│   ├── tb_ImmGen.v
│   ├── tb_ALU.v
│   ├── tb_DataMemory.v
│   ├── tb_ALUControl.v
│   └── tb_ControlUnit.v
│
└── README.md
```

---

# Development Workflow

Each module follows the workflow below:

1. Define the module specification.
2. Implement RTL design in Verilog.
3. Develop the corresponding testbench.
4. Perform functional simulation.
5. Verify expected behavior.
6. Debug and fix issues if required.
7. Commit the verified module to GitHub.

---

# Completed Hardware Modules

## Program Counter (PC)

### Purpose
- Stores the address of the current instruction.
- Updates instruction address every clock cycle.

### Status
- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Instruction Memory

### Purpose
- Stores program instructions.
- Provides instruction output based on PC address.

### Status
- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Register File

### Purpose
- Implements 32 general-purpose RISC-V registers.
- Provides two read ports and one write port.

### Status
- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Immediate Generator

### Purpose
- Generates immediate values from RISC-V instruction formats.

### Supported Formats
- I-Type
- S-Type
- B-Type
- J-Type
- U-Type

### Status
- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## ALU (Arithmetic Logic Unit)

### Purpose
- Performs arithmetic and logical operations.

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
- Provides data storage for memory access instructions.
- Handles read and write operations.

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
- Generates ALU operation signals.
- Uses instruction fields:
  - funct3
  - funct7
  - ALUOp

### Status
- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

---

## Main Control Unit

### Purpose
- Generates the control signals required for datapath operation.

### Generated Control Signals

- Branch
- MemRead
- MemWrite
- MemToReg
- ALUSrc
- RegWrite
- ALUOp

### Status
- RTL Implementation ✅
- Testbench ✅
- Simulation Verification ✅

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
| Control Unit | ✅ | ✅ | ✅ | Complete |
| Single-Cycle Datapath Integration | ⏳ | ⏳ | ⏳ | Not Started |
| Single-Cycle Processor Verification | ⏳ | ⏳ | ⏳ | Not Started |
| Pipeline Conversion | ⏳ | ⏳ | ⏳ | Not Started |

---

# Current Milestone

Completed:

- ✅ Repository structure created
- ✅ Processor specification completed
- ✅ High-level architecture defined
- ✅ Program Counter completed
- ✅ Instruction Memory completed
- ✅ Register File completed
- ✅ Immediate Generator completed
- ✅ ALU completed
- ✅ Data Memory completed
- ✅ ALU Control completed
- ✅ Main Control Unit completed

---

# Current Stage

## Next Task: Single-Cycle Datapath Integration

The completed modules will now be connected together to create the complete single-cycle RISC-V processor.

Integration includes:

- Program Counter connection
- Instruction Memory connection
- Instruction decoding
- Register File connection
- Immediate Generator connection
- Main Control Unit connection
- ALU Control connection
- ALU connection
- Data Memory connection
- Write-back path implementation
- Branch and jump logic

---

# Future Work

After successful single-cycle processor verification:

## Five Stage Pipeline Conversion

Implement classic RISC-V pipeline stages:

### IF Stage
- Program Counter
- Instruction Memory

### ID Stage
- Instruction Decode
- Register File
- Immediate Generator
- Control Unit

### EX Stage
- ALU Execution
- ALU Control
- Branch Calculation

### MEM Stage
- Data Memory Access

### WB Stage
- Register Write Back

---

# Pipeline Features

Planned additions:

- IF/ID Pipeline Register
- ID/EX Pipeline Register
- EX/MEM Pipeline Register
- MEM/WB Pipeline Register
- Forwarding Unit
- Hazard Detection Unit
- Load-Use Stall Logic
- Branch Flush Logic
- Complete Five-Stage Pipeline Integration

---

# Tools

- Verilog HDL
- Xilinx Vivado
- GitHub

---

# License

This project is developed for learning, educational, and portfolio purposes.
