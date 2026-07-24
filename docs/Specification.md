# RV32I 5-Stage Pipelined Processor Specification

## 1. Project Overview

This project implements a 32-bit single-core RISC-V (RV32I) processor using Verilog HDL. The processor is based on the classic five-stage pipeline architecture consisting of Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).

The project will be developed incrementally. A functionally correct single-cycle processor will be implemented and verified first. After successful verification, the design will be converted into a five-stage pipelined processor by adding pipeline registers, forwarding logic, hazard detection, load-use stall logic, and branch handling.

The objective of this project is to gain practical experience in RTL design, computer architecture, and processor verification while following professional hardware development practices.
