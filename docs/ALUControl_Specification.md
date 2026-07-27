# ALUControl Specification

## 1. Module Name
`ALU_Control`

## 2. Purpose
The ALU Control unit decodes the exact ALU operation to be performed. It sits between the Main Control Unit and the ALU: the Main Control Unit only outputs a coarse `ALUOp` signal based on instruction type (R-type, I-type, load/store, branch), and this module combines that with `funct3`/`funct7` to generate the precise 3-bit `ALUControl` signal consumed by the ALU. This keeps the Main Control Unit decoupled from instruction-specific arithmetic decoding.

## 3. Inputs
| Signal      | Width | Description                                                          |
|-------------|-------|------------------------------------------------------------------------|
| `ALUOp`     | 2-bit | Coarse operation class from Main Control Unit                        |
| `funct3`    | 3-bit | `instr[14:12]` — distinguishes ADD/SUB/AND/OR/XOR/SLT and BEQ/BNE     |
| `funct7_5`  | 1-bit | `instr[30]` — distinguishes ADD (0) from SUB (1), R-type only         |

## 4. Outputs
| Signal       | Width | Description                                                              |
|--------------|-------|----------------------------------------------------------------------------|
| `ALUControl` | 3-bit | Operation select fed directly into the ALU (matches ALU's `ALUControl` encoding) |

## 5. Parameters
| Parameter | Value | Description            |
|-----------|-------|--------------------------|
| None      | —     | No parameters required  |

## 6. Internal Storage
Not applicable — `ALU_Control` is purely combinational logic, no storage elements.

## 7. Initialization
Not applicable — no memory or registers to initialize.

## 8. Functional Behavior

**`ALUOp` encoding (from Main Control Unit):**

| ALUOp   | Meaning                              | Instructions                    |
|---------|----------------------------------------|----------------------------------|
| `2'b00` | Address calculation → force ADD       | LW, SW                          |
| `2'b01` | Branch comparison → force SUB         | BEQ, BNE                        |
| `2'b10` | R-type → decode via funct3/funct7     | ADD, SUB, AND, OR, XOR, SLT      |
| `2'b11` | I-type → force ADD                    | ADDI                             |

**Decode table (matches ALU's `ALUControl` encoding exactly):**

| ALUOp | funct7_5 | funct3 | Instruction | ALUControl        |
|-------|----------|--------|-------------|--------------------|
| 00    | X        | XXX    | LW / SW     | `3'b000` (ADD)     |
| 11    | X        | XXX    | ADDI        | `3'b000` (ADD)     |
| 01    | X        | XXX    | BEQ / BNE   | `3'b001` (SUB)     |
| 10    | 0        | 000    | ADD         | `3'b000` (ADD)     |
| 10    | 1        | 000    | SUB         | `3'b001` (SUB)     |
| 10    | X        | 111    | AND         | `3'b010` (AND)     |
| 10    | X        | 110    | OR          | `3'b011` (OR)      |
| 10    | X        | 100    | XOR         | `3'b100` (XOR)     |
| 10    | X        | 010    | SLT         | `3'b101` (SLT)     |

`X` = don't care.

**Operation (combinational):**

```verilog
case (ALUOp)
    2'b00: ALUControl = 3'b000;                    // LW, SW -> ADD
    2'b11: ALUControl = 3'b000;                    // ADDI   -> ADD
    2'b01: ALUControl = 3'b001;                    // BEQ, BNE -> SUB
    2'b10: begin                                   // R-type
        case ({funct7_5, funct3})
            4'b0_000: ALUControl = 3'b000;         // ADD
            4'b1_000: ALUControl = 3'b001;         // SUB
            4'b0_111: ALUControl = 3'b010;         // AND
            4'b0_110: ALUControl = 3'b011;         // OR
            4'b0_100: ALUControl = 3'b100;         // XOR
            4'b0_010: ALUControl = 3'b101;         // SLT
            default:  ALUControl = 3'b000;         // reserved/default
        endcase
    end
    default: ALUControl = 3'b000;                  // reserved/default
endcase
```

**Design note — BEQ/BNE:** the ALU Control unit's only job for branches is to force SUBTRACT. The actual branch taken/not-taken decision is made outside this module, using the ALU's `Zero` flag together with `funct3` (BEQ: taken when `Zero=1`; BNE: taken when `Zero=0`) at the datapath/branch-logic level.

## 9. Reset Behavior
No reset. Purely combinational — output updates immediately whenever `ALUOp`, `funct3`, or `funct7_5` changes, with no dependency on clock or reset.

## 10. Verification
The following test cases shall be verified:

- `ALUOp = 00` (LW/SW) → `ALUControl = ADD`, regardless of funct3/funct7_5
- `ALUOp = 11` (ADDI) → `ALUControl = ADD`, regardless of funct3/funct7_5
- `ALUOp = 01` (BEQ/BNE) → `ALUControl = SUB`, regardless of funct3/funct7_5
- `ALUOp = 10`, funct7_5=0, funct3=000 (ADD) → `ALUControl = ADD`
- `ALUOp = 10`, funct7_5=1, funct3=000 (SUB) → `ALUControl = SUB`
- `ALUOp = 10`, funct3=111 (AND) → `ALUControl = AND`
- `ALUOp = 10`, funct3=110 (OR) → `ALUControl = OR`
- `ALUOp = 10`, funct3=100 (XOR) → `ALUControl = XOR`
- `ALUOp = 10`, funct3=010 (SLT) → `ALUControl = SLT`
- Invalid/unsupported `{funct7_5, funct3}` under `ALUOp=10` → confirm default case gives `ALUControl = 3'b000`
- Invalid `ALUOp` value (if ever wider than 2 bits or driven incorrectly) → confirm default case gives `ALUControl = 3'b000`

## 11. Notes
- Purely combinational — required for single-cycle timing, `ALUControl` must be valid within the same cycle the ALU consumes it.
- `ALUControl` encoding here is matched 1:1 to the ALU module's existing `ALUControl` table (000=ADD, 001=SUB, 010=AND, 011=OR, 100=XOR, 101=SLT) — no changes needed on the ALU side.
- Reused without modification in the pipelined processor — sits in the ID or EX stage depending on where you choose to place instruction decode relative to pipeline registers (commonly decoded in ID, then `ALUControl` is latched into the ID/EX register alongside ALUOp-derived signals).
