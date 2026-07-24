# RV32I 5-Stage Pipelined Processor Specification

## 1. Project Overview

This project implements a 32-bit single-core RISC-V (RV32I) processor using Verilog HDL. The processor is based on the classic five-stage pipeline architecture consisting of Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).

The project will be developed incrementally. A functionally correct single-cycle processor will be implemented and verified first. After successful verification, the design will be converted into a five-stage pipelined processor by adding pipeline registers, forwarding logic, hazard detection, load-use stall logic, and branch handling.

The objective of this project is to gain practical experience in RTL design, computer architecture, and processor verification while following professional hardware development practices.

---

## 2. Design Goals

The main goals of this project are:

- Design and implement a 32-bit single-core RISC-V (RV32I) processor.
- Develop and verify a functionally correct single-cycle processor.
- Convert the design into a five-stage pipelined processor.
- Implement data forwarding to reduce data hazards.
- Implement hazard detection and load-use stall logic.
- Implement branch handling using a predict-not-taken approach with pipeline flushing.
- Verify every module using self-checking Verilog testbenches.
- Follow modular RTL design and version control using Git and GitHub.

---

## 3. ISA Specification

The processor implements a subset of the 32-bit RISC-V Integer Instruction Set Architecture (RV32I).

### Processor Configuration

| Parameter | Value |
|-----------|-------|
| ISA | RV32I (Subset) |
| XLEN | 32-bit |
| Core Type | Single-Core |
| Pipeline | 5-Stage |
| Endianness | Little Endian |

---

## 4. Supported Instructions

| Instruction Type | Instructions |
|------------------|--------------|
| R-Type | ADD, SUB, AND, OR, XOR, SLT |
| I-Type | ADDI, LW |
| S-Type | SW |
| B-Type | BEQ, BNE |
| J-Type | JAL |

---

## 5. Processor Specifications

| Feature | Specification |
|----------|---------------|
| Architecture | RISC-V RV32I |
| Data Width | 32 bits |
| Address Width | 32 bits |
| Register File | 32 General Purpose Registers |
| Register Width | 32 bits |
| x0 Register | Hardwired to Zero |
| Clock | Single Clock |
| Reset | Synchronous Active-High |
| Implementation Language | Verilog HDL |

---

## 6. Pipeline Stages

The processor uses the standard five-stage pipeline.

| Stage | Description |
|--------|-------------|
| IF | Instruction Fetch |
| ID | Instruction Decode and Register Read |
| EX | Execute / ALU Operations |
| MEM | Data Memory Access |
| WB | Write Back to Register File |

---

## 7. Memory Organization

### Instruction Memory

- Stores program instructions.
- Read-only during processor execution.
- Word-addressable for this project.

### Data Memory

- Stores load and store data.
- Supports LW and SW instructions.
- Word-aligned accesses only.

---

## 8. Hazard Handling

The pipelined processor will implement:

- Data Forwarding Unit
- Hazard Detection Unit
- Load-Use Stall Logic
- Pipeline Flush Logic
- Predict-Not-Taken Branch Strategy

---

## 9. Verification Strategy

Every module will be verified individually before integration.

Verification flow:

1. Module Specification
2. RTL Implementation
3. Testbench Development
4. Functional Simulation
5. Bug Fixes
6. Integration
7. System-Level Verification

---

## 10. Development Roadmap

### Phase 1

Single-Cycle Processor

- Program Counter
- Instruction Memory
- Register File
- Immediate Generator
- ALU
- ALU Control
- Main Control Unit
- Data Memory
- Datapath Integration
- Top Module

### Phase 2

Pipeline Conversion

- IF/ID Register
- ID/EX Register
- EX/MEM Register
- MEM/WB Register

### Phase 3

Hazard Handling

- Forwarding Unit
- Hazard Detection Unit
- Load-Use Stall Logic
- Branch Flush Logic

### Phase 4

Verification

- Directed Testbenches
- Pipeline Verification
- Functional Validation

---

