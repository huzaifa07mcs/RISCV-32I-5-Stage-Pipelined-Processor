# Datapath Integration — Module Specification

## 1. Module Name

`Datapath`

---

## 2. Purpose

The Datapath module integrates all previously verified modules into a complete single-cycle RV32I processor datapath.

It instantiates and connects the following modules:

- ProgramCounter
- InstructionMemory
- RegisterFile
- ImmGen
- ALU
- ALU_Control
- MainControl
- DataMemory

No new functional units are introduced. This module only adds the combinational logic required to connect these modules together, including adders, multiplexers, and branch decision logic.

All instruction decoding, ALU operations, memory accesses, and register file operations are performed by the instantiated submodules.

---

## 3. Submodules Instantiated

| Module | Purpose |
|---------|---------|
| `ProgramCounter` | Stores the current program counter |
| `InstructionMemory` | Stores program instructions |
| `RegisterFile` | Stores the 32 general-purpose registers |
| `ImmGen` | Generates immediates from instructions |
| `MainControl` | Generates the main control signals |
| `ALU_Control` | Generates the ALU operation |
| `ALU` | Executes arithmetic and logical operations |
| `DataMemory` | Stores data for LW and SW instructions |

---

## 4. Additional Logic

Besides connecting the submodules, the datapath contains the following combinational logic.

### Adder 1

Computes the next sequential instruction address.

```
pc_plus4 = pc_current + 4
```

---

### Adder 2

Computes the branch or jump target address.

```
pc_target = pc_current + imm_out
```

---

### ALUSrc Multiplexer

Selects the second ALU operand.

Input 0

```
read_data2
```

Input 1

```
imm_out
```

Selection

```
ALUSrc
```

---

### Branch Decision Logic

Determines whether a branch instruction should be taken.

```
branch_taken = Branch & (Zero ^ instruction[12])
```

This supports both:

- BEQ
- BNE

using the same hardware.

---

### Branch Multiplexer

Selects between:

```
pc_plus4
```

and

```
pc_target
```

Selection signal:

```
branch_taken
```

---

### Jump Multiplexer

Selects between

```
Branch Mux Output
```

and

```
pc_target
```

Selection signal:

```
Jump
```

The output becomes

```
pc_next
```

which is connected to the ProgramCounter.

---

### Write-back Multiplexer

Selects the value written back to the Register File.

Input 0

```
ALU_result
```

Input 1

```
read_data
```

Selection

```
MemtoReg
```

---

### JAL Write-back Multiplexer

Overrides the normal write-back path during JAL.

Input 0

```
Write-back Mux Output
```

Input 1

```
pc_plus4
```

Selection

```
Jump
```

The output becomes the Register File write data.

---

## 5. Signal Connection Table

| Source | Signal | Destination |
|--------|--------|-------------|
| ProgramCounter | `pc_current` | InstructionMemory `address` |
| ProgramCounter | `pc_current` | PC + 4 Adder |
| ProgramCounter | `pc_current` | PC + Immediate Adder |
| InstructionMemory | `instruction` | MainControl `opcode` |
| InstructionMemory | `instruction` | RegisterFile `read_addr1` |
| InstructionMemory | `instruction` | RegisterFile `read_addr2` |
| InstructionMemory | `instruction` | RegisterFile `write_addr` |
| InstructionMemory | `instruction` | ALU_Control `funct3` |
| InstructionMemory | `instruction` | ALU_Control `funct7_5` |
| InstructionMemory | `instruction` | ImmGen `instruction` |
| MainControl | `RegWrite` | RegisterFile `RegWrite` |
| MainControl | `ALUSrc` | ALUSrc Multiplexer |
| MainControl | `MemWrite` | DataMemory `write_enable` |
| MainControl | `MemtoReg` | Write-back Multiplexer |
| MainControl | `Branch` | Branch Decision Logic |
| MainControl | `Jump` | Jump Multiplexer |
| MainControl | `Jump` | JAL Write-back Multiplexer |
| MainControl | `ALUOp` | ALU_Control `ALUOp` |
| MainControl | `ImmSrc` | ImmGen `ImmSrc` |
| RegisterFile | `read_data1` | ALU `operand_A` |
| RegisterFile | `read_data2` | ALUSrc Multiplexer Input 0 |
| RegisterFile | `read_data2` | DataMemory `write_data` |
| ImmGen | `imm_out` | ALUSrc Multiplexer Input 1 |
| ImmGen | `imm_out` | PC + Immediate Adder |
| ALU_Control | `ALUControl` | ALU `ALUControl` |
| ALU | `ALU_result` | DataMemory `address` |
| ALU | `ALU_result` | Write-back Multiplexer Input 0 |
| ALU | `Zero` | Branch Decision Logic |
| InstructionMemory | `instruction[12]` | Branch Decision Logic |
| DataMemory | `read_data` | Write-back Multiplexer Input 1 |
| PC + 4 Adder | `pc_plus4` | Branch Multiplexer Input 0 |
| PC + Immediate Adder | `pc_target` | Branch Multiplexer Input 1 |
| Branch Multiplexer | `branch_pc` | Jump Multiplexer Input 0 |
| Jump Multiplexer | `pc_next` | ProgramCounter `pc_next` |
| Write-back Multiplexer | `wb_data` | JAL Write-back Multiplexer Input 0 |
| JAL Write-back Multiplexer | `write_back_data` | RegisterFile `write_data` |

---

## 6. Branch Decision Logic

The datapath supports both **BEQ** and **BNE** using a single logic expression.

```verilog
wire branch_taken = Branch & (Zero ^ instruction[12]);
```

Where:

- `Branch` is generated by the MainControl module.
- `Zero` is generated by the ALU after comparing the two source operands.
- `instruction[12]` is the least significant bit of `funct3`.
    - `instruction[12] = 0` → BEQ
    - `instruction[12] = 1` → BNE

Operation:

| Instruction | instruction[12] | Zero | Branch Taken |
|------------|-----------------|------|--------------|
| BEQ | 0 | 1 | Yes |
| BEQ | 0 | 0 | No |
| BNE | 1 | 0 | Yes |
| BNE | 1 | 1 | No |

This implementation supports both branch instructions without requiring separate hardware.

---

## 7. Reset Behavior

The Datapath itself contains no sequential storage elements.

Reset functionality is handled by the instantiated modules.

### ProgramCounter

On reset,

```text
pc_current = 0
```

Execution begins from address 0 after reset is released.

### RegisterFile

On reset,

- All registers are cleared.
- Register `x0` always remains zero.

### InstructionMemory

InstructionMemory has no reset.

Program contents are loaded during simulation using

```verilog
$readmemh("program.mem", memory);
```

### DataMemory

DataMemory has no reset input.

Memory contents are initialized to zero during simulation using an `initial` block.

The memory contents are preserved during processor execution until modified by an `SW` instruction.

---

## 8. Verification Strategy

Unlike individual modules, the complete datapath is verified using instruction sequences rather than isolated signals.

Recommended verification programs include:

### Test 1 — R-Type Instructions

Verify:

- ADD
- SUB
- AND
- OR
- XOR
- SLT

Expected result:

- Correct ALU output.
- Correct destination register write-back.

---

### Test 2 — ADDI

Verify:

- Immediate generation
- ALUSrc multiplexer
- Register write-back

Expected result:

Destination register contains the expected immediate arithmetic result.

---

### Test 3 — LW

Verify:

- Effective address calculation
- DataMemory read
- MemtoReg mux
- Register write-back

Expected result:

Loaded value appears in the destination register.

---

### Test 4 — SW

Verify:

- Effective address calculation
- DataMemory write

Expected result:

Specified memory location stores the expected value.

---

### Test 5 — BEQ

Verify both:

- Branch taken
- Branch not taken

Expected result:

PC updates correctly in both cases.

---

### Test 6 — BNE

Verify both:

- Branch taken
- Branch not taken

Expected result:

Branch decision follows the expression

```verilog
Branch & (Zero ^ instruction[12])
```

---

### Test 7 — JAL

Verify:

- Jump target calculation
- PC update
- Write-back of `PC + 4`

Expected result:

- PC jumps to the correct target.
- Destination register receives the return address.

---

### Test 8 — Mixed Program

Execute a small program containing:

- R-Type instructions
- ADDI
- LW
- SW
- BEQ
- BNE
- JAL

Expected result:

- Registers contain the expected values.
- Memory contains the expected values.
- PC follows the correct execution path.

---

## 9. Notes

- The Datapath module contains only combinational integration logic. All functional units are implemented in separate RTL modules.
- The processor follows the standard RV32I byte-addressed memory model.
- ProgramCounter generates byte addresses.
- InstructionMemory converts the byte address to a word index using:

```verilog
address[9:2]
```

- DataMemory also converts the byte address to a word index using:

```verilog
address[9:2]
```

This keeps instruction fetches and data accesses consistent with the RV32I byte-addressing model.

- DataMemory performs synchronous writes and combinational reads, matching the timing requirements of a single-cycle processor.
- The branch decision logic supports both BEQ and BNE using a single XOR-based expression.
- A dedicated JAL write-back multiplexer writes `PC + 4` into the destination register while simultaneously updating the Program Counter with the jump target.
- This datapath serves as the baseline implementation before introducing the IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers during the pipelined processor phase.
