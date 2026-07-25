# RV32I 5-Stage Pipelined Processor
A 32-bit Single-Core RISC-V (RV32I) processor implemented in Verilog HDL. The project is being developed incrementally by first building and verifying a functionally correct single-cycle processor and then converting it into a classic five-stage pipelined processor.

---

## Project Objectives
- Design and implement a 32-bit Single-Core RISC-V (RV32I) processor.
- Develop and verify a functionally correct single-cycle processor.
- Convert the design into a five-stage pipelined processor.
- Implement forwarding, hazard detection, load-use stall logic, and branch handling.
- Follow modular RTL design and verification practices.

---

## Processor Specifications
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
│   ├── Specification.md
│   ├── PC_Specification.md
│   ├── InstructionMemory_Specification.md
│   ├── RegisterFile_Specification.md
│   ├── ImmediateGenerator_Specification.md
│   └── ALU_Specification.md
│
├── rtl/
│   ├── PC.v
│   ├── InstructionMemory.v
│   ├── RegisterFile.v
│   ├── ImmGen.v
│   └── ALU.v
│
├── tb/
│   ├── tb_PC.v
│   ├── tb_InstructionMemory.v
│   ├── tb_RegisterFile.v
│   ├── tb_ImmGen.v
│   └── tb_ALU.v
│
└── README.md
```

---

## Development Workflow
Each module follows the workflow below:
1. Define the module specification.
2. Implement the RTL in Verilog.
3. Develop the testbench.
4. Perform functional simulation.
5. Fix issues, if any.
6. Commit the verified module to GitHub.

---

## Project Progress
| Module | RTL | Testbench | Simulation | Status |
|---------|:---:|:---------:|:----------:|:------:|
| Program Counter | ✅ | ✅ | ✅ | Complete |
| Instruction Memory | ✅ | ✅ | ✅ | Complete |
| Register File | ✅ | ✅ | ✅ | Complete |
| Immediate Generator | ✅ | ✅ | ✅ | Complete |
| ALU | ✅ | ✅ | ✅ | Complete |
| ALU Control | ⏳ | ⏳ | ⏳ | Not Started |
| Control Unit | ⏳ | ⏳ | ⏳ | Not Started |
| Data Memory | ⏳ | ⏳ | ⏳ | Not Started |
| Datapath Integration | ⏳ | ⏳ | ⏳ | Not Started |
| Pipeline Conversion | ⏳ | ⏳ | ⏳ | Not Started |

---

## Current Milestone
- ✅ Repository structure created
- ✅ Processor specification completed
- ✅ High-level architecture defined
- ✅ Program Counter RTL, testbench, and simulation completed
- ✅ Instruction Memory RTL, testbench, and simulation completed
- ✅ Register File RTL, testbench, and simulation completed
- ✅ Immediate Generator RTL, testbench, and simulation completed
- ✅ ALU RTL, testbench, and simulation completed
- ⏳ Next: ALU Control module

---

## Tools
- Verilog HDL
- Xilinx Vivado
- GitHub

---

## Future Work
After completing the single-cycle processor, the project will be extended with:
- IF/ID Pipeline Register
- ID/EX Pipeline Register
- EX/MEM Pipeline Register
- MEM/WB Pipeline Register
- Forwarding Unit
- Hazard Detection Unit
- Load-Use Stall Logic
- Branch Flush Logic
- Complete 5-Stage Pipeline Integration

---

## License
This project is developed for learning, educational, and portfolio purposes.
