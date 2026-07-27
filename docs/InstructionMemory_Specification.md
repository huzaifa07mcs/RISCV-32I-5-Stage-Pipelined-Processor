# Instruction Memory Specification

## 1. Module Name

InstructionMemory

---

## 2. Purpose

The Instruction Memory stores the program instructions that are executed by the processor. It receives the Program Counter (PC) address as input and outputs the corresponding 32-bit instruction.

---

## 3. Inputs

| Signal | Width | Description |
|--------|------:|-------------|
| address | 32-bit | Address of the instruction to be fetched |

---

## 4. Outputs

| Signal | Width | Description |
|--------|------:|-------------|
| instruction | 32-bit | Instruction stored at the given address |

---

## 5. Parameters

| Parameter | Value | Description |
|-----------|------:|-------------|
| XLEN | 32 | Processor data width |
| DEPTH | 256 | Number of instruction words |

---

## 6. Internal Storage

- Memory Type: ROM
- Word Width: 32 bits
- Number of Words: 256

Declaration:

```verilog
reg [31:0] memory [0:255];
```

---

## 7. Initialization

The instruction memory is initialized from an external hexadecimal memory file using:

```verilog
$readmemh("program.mem", memory);
```

The memory file contains one 32-bit instruction per line.

---

## 8. Functional Behavior

- The Program Counter (PC) generates a **byte address**.
- Since each instruction is 32 bits (4 bytes), the two least significant address bits (`address[1:0]`) are ignored to obtain the word index.
- For a memory depth of 256 words, `address[9:2]` provides the required 8-bit memory index.
- The instruction output updates immediately whenever the address changes (combinational read).

Operation:

```verilog
assign instruction = memory[address[9:2]];
```

## 9. Reset Behavior

Instruction Memory has no reset.

Its contents are loaded once during simulation using `$readmemh`.

---

## 10. Verification

The following test cases shall be verified:

- Read instruction from address 0x00000000.
- Read instruction from address 0x00000004.
- Read instruction from address 0x00000008.
- Read instruction from address 0x0000000C.
- Read instruction from a higher address (for example, 0x00000020).
- Verify correct address-to-word conversion.
- Verify that memory contents match the values stored in `program.mem`.

---

## 11. Notes

- Read-only memory for this project.
- Supports instruction fetch only.
- Used during the Instruction Fetch (IF) stage.
- Designed for the single-cycle processor and reused without modification in the pipelined processor.
