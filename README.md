# RV32I 5-Stage Pipelined Processor

A 32-bit Single-Core RISC-V (RV32I) processor implemented in Verilog HDL. This project is being developed incrementally by first building and verifying a functionally correct single-cycle processor, followed by its conversion into a classic five-stage pipelined processor.

---

## Project Objectives

- Design and implement a 32-bit Single-Core RISC-V (RV32I) processor.
- Verify every RTL module using dedicated testbenches.
- Convert the verified single-cycle processor into a 5-stage pipelined processor.
- Implement forwarding, hazard detection, load-use stall logic, and branch handling.
- Follow professional RTL design and verification practices.

---

## Processor Specifications

| Feature | Specification |
|----------|---------------|
| ISA | RV32I (Subset) |
| Data Width | 32-bit |
| Core | Single-Core |
| Pipeline | 5-Stage (Target) |
| Language | Verilog HDL |
| Development Flow | Single-Cycle → Pipelined |

---

## Supported Instructions (Planned)

| Type | Instructions |
|------|--------------|
| R-Type | ADD, SUB, AND, OR, XOR, SLT |
| I-Type | ADDI, LW |
| S-Type | SW |
| B-Type | BEQ, BNE |
| J-Type | JAL |

---

## Project Structure

```text
RISCV-32I-5-Stage-Pipelined-Processor/
│
├── docs/
│   └── Specification.md
│
├── rtl/
│   └── PC.v
│
├── tb/
│   └── tb_PC.v
│
├── sim/
│
├── README.md
```

---

## Development Progress

| Module | RTL | Testbench | Simulation | Status |
|---------|:---:|:---------:|:----------:|:------:|
| Program Counter | ✅ | ✅ | ✅ | Complete |
| Instruction Memory | ⏳ | ⏳ | ⏳ | Not Started |
| Register File | ⏳ | ⏳ | ⏳ | Not Started |
| Immediate Generator | ⏳ | ⏳ | ⏳ | Not Started |
| ALU | ⏳ | ⏳ | ⏳ | Not Started |
| ALU Control | ⏳ | ⏳ | ⏳ | Not Started |
| Control Unit | ⏳ | ⏳ | ⏳ | Not Started |
| Data Memory | ⏳ | ⏳ | ⏳ | Not Started |
| Datapath Integration | ⏳ | ⏳ | ⏳ | Not Started |
| Pipeline Conversion | ⏳ | ⏳ | ⏳ | Not Started |

---

## Verification Flow

Each module follows the same workflow:

1. Module Specification
2. RTL Implementation
3. Testbench Development
4. Functional Simulation
5. Debugging
6. GitHub Commit

---

## Tools

- Verilog HDL
- Xilinx Vivado
- Git
- GitHub

---

## Current Milestone

- ✅ Project structure created
- ✅ Processor specification completed
- ✅ High-level architecture defined
- ✅ Program Counter (RTL + Testbench + Simulation) completed

---

## Future Work

After completing the single-cycle processor:

- Add pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
- Implement Forwarding Unit
- Implement Hazard Detection Unit
- Implement Load-Use Stall Logic
- Implement Branch Flush Logic
- Verify the complete pipelined processor
