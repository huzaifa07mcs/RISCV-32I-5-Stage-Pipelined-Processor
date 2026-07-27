# MainControl Specification

## 1. Module Name
`MainControl`

## 2. Purpose
The Main Control Unit decodes the instruction's opcode (`instr[6:0]`) and generates all control signals needed by the rest of the single-cycle datapath — register write enable, ALU source select, memory write enable, write-back source select, branch/jump control, and the coarse `ALUOp`/`ImmSrc` signals consumed by `ALU_Control` and `ImmGen` respectively. This is the central decode point of the datapath — every other control-dependent module (ALU_Control, ImmGen, register file, data memory, PC update logic) depends on its outputs.

## 3. Inputs
| Signal    | Width | Description                          |
|-----------|-------|------------------------------------------|
| `opcode`  | 7-bit | `instr[6:0]` — instruction opcode field  |

## 4. Outputs
| Signal      | Width | Description                                                                 |
|-------------|-------|---------------------------------------------------------------------------|
| `RegWrite`  | 1     | Write result back to register file                                        |
| `ALUSrc`    | 1     | 0 = operand_B from rs2, 1 = operand_B from immediate                       |
| `MemWrite`  | 1     | Write to data memory (SW)                                                  |
| `MemtoReg`  | 1     | 0 = write ALU result to reg, 1 = write memory read-data to reg             |
| `Branch`    | 1     | Instruction is BEQ/BNE — gate branch decision on ALU `Zero` flag           |
| `Jump`      | 1     | Instruction is JAL — unconditional PC redirect                            |
| `ALUOp`     | 2-bit | Coarse op class, feeds `ALU_Control`                                       |
| `ImmSrc`    | 2-bit | Immediate format select, feeds `ImmGen` (00=I, 01=S, 10=B, 11=J)           |

## 5. Parameters
| Parameter | Value | Description            |
|-----------|-------|--------------------------|
| None      | —     | No parameters required  |

## 6. Internal Storage
Not applicable — `Main_Control` is purely combinational logic, no storage elements.

## 7. Initialization
Not applicable — no memory or registers to initialize.

## 8. Functional Behavior

**Opcode map (RV32I, supported subset):**

| Instruction(s)                          | Opcode      | Instruction Type      |
|-------------------------------------------|-------------|--------------------------|
| ADD, SUB, AND, OR, XOR, SLT                | `7'b0110011`| R-type                   |
| ADDI                                       | `7'b0010011`| I-type (arithmetic)      |
| LW                                         | `7'b0000011`| I-type (load)            |
| SW                                         | `7'b0100011`| S-type                   |
| BEQ, BNE                                   | `7'b1100011`| B-type                   |
| JAL                                        | `7'b1101111`| J-type                   |

**Control signal truth table:**

| Instruction | Opcode      | RegWrite | ALUSrc | MemWrite | MemtoReg | Branch | Jump | ALUOp  | ImmSrc |
|-------------|-------------|----------|--------|----------|----------|--------|------|--------|--------|
| R-type      | `7'b0110011`| 1        | 0      | 0        | 0        | 0      | 0    | 2'b10  | X      |
| ADDI        | `7'b0010011`| 1        | 1      | 0        | 0        | 0      | 0    | 2'b11  | 2'b00  |
| LW          | `7'b0000011`| 1        | 1      | 0        | 1        | 0      | 0    | 2'b00  | 2'b00  |
| SW          | `7'b0100011`| 0        | 1      | 1        | X        | 0      | 0    | 2'b00  | 2'b01  |
| BEQ / BNE   | `7'b1100011`| 0        | 0      | 0        | X        | 1      | 0    | 2'b01  | 2'b10  |
| JAL         | `7'b1101111`| 1        | X*     | 0        | X*       | 0      | 1    | X*     | 2'b11  |

`X` = don't care (signal's value cannot affect the datapath's result for this instruction — see Section 11 for reasoning per row).

`X*` = **open item, not yet finalized** — see Section 8.1 below. Do not treat as confirmed don't-care until resolved.

### 8.1 JAL Datapath Routing 
JAL's jump target (PC + immediate) and return address (PC + 4) are computed 
by dedicated adders outside the main ALU, decoupled from the shared 
ALU/ALU_Control path. This keeps ALU_Control scoped to R-type/I-type 
arithmetic and branch comparison only, and avoids a structural conflict 
in the pipelined design (Phase 2), where the branch/jump target needs to 
be available early (ID stage) rather than waiting on the EX-stage ALU.

`ALUSrc` and `ALUOp` are confirmed genuine don't-cares for JAL — the ALU 
is never touched by this instruction.

**Operation (combinational, conceptual):**

```verilog
case (opcode)
    7'b0110011: begin // R-type
        RegWrite=1; ALUSrc=0; MemWrite=0; MemtoReg=0;
        Branch=0;   Jump=0;   ALUOp=2'b10; ImmSrc=2'bxx;
    end
    7'b0010011: begin // ADDI
        RegWrite=1; ALUSrc=1; MemWrite=0; MemtoReg=0;
        Branch=0;   Jump=0;   ALUOp=2'b11; ImmSrc=2'b00;
    end
    7'b0000011: begin // LW
        RegWrite=1; ALUSrc=1; MemWrite=0; MemtoReg=1;
        Branch=0;   Jump=0;   ALUOp=2'b00; ImmSrc=2'b00;
    end
    7'b0100011: begin // SW
        RegWrite=0; ALUSrc=1; MemWrite=1; MemtoReg=1'bx;
        Branch=0;   Jump=0;   ALUOp=2'b00; ImmSrc=2'b01;
    end
    7'b1100011: begin // BEQ, BNE
        RegWrite=0; ALUSrc=0; MemWrite=0; MemtoReg=1'bx;
        Branch=1;   Jump=0;   ALUOp=2'b01; ImmSrc=2'b10;
    end
    7'b1101111: begin // JAL
        RegWrite=1; ALUSrc=1'bx; MemWrite=0; MemtoReg=1'bx;
        Branch=0;   Jump=1;   ALUOp=2'bxx; ImmSrc=2'b11;
    end
    default: begin // unsupported opcode
        RegWrite=0; ALUSrc=0; MemWrite=0; MemtoReg=0;
        Branch=0;   Jump=0;   ALUOp=2'b00; ImmSrc=2'b00;
    end
endcase
```

## 9. Reset Behavior
No reset. Purely combinational — all outputs update immediately whenever `opcode` changes, with no dependency on clock or reset.

## 10. Verification
The following test cases shall be verified:

- R-type opcode → confirm `RegWrite=1, ALUSrc=0, MemWrite=0, Branch=0, Jump=0, ALUOp=10`
- ADDI opcode → confirm `RegWrite=1, ALUSrc=1, MemWrite=0, MemtoReg=0, ALUOp=11, ImmSrc=00`
- LW opcode → confirm `RegWrite=1, ALUSrc=1, MemWrite=0, MemtoReg=1, ALUOp=00, ImmSrc=00`
- SW opcode → confirm `RegWrite=0, ALUSrc=1, MemWrite=1, ALUOp=00, ImmSrc=01`
- BEQ/BNE opcode → confirm `RegWrite=0, ALUSrc=0, Branch=1, ALUOp=01, ImmSrc=10`
- JAL opcode → confirm `RegWrite=1, Jump=1, ImmSrc=11` (other signals per resolution of Section 8.1)
- Invalid/unsupported opcode → confirm default case gives all control signals de-asserted (safe/inert state)

## 11. Notes
- Purely combinational — required for single-cycle timing, all control outputs must be valid within the same cycle downstream modules consume them.
- `MemtoReg` marked don't-care for SW and BEQ/BNE because both have `RegWrite=0` — the register-file write-data mux this signal controls is never selected for these instructions.
- `ImmSrc` marked don't-care for R-type because `ALUSrc=0` for R-type — `ImmGen`'s output is never selected by the operand_B mux, so its format selection is irrelevant.
- **Section 8.1 (JAL routing) must be resolved before this spec is considered final** — do not proceed to RTL for the JAL row until confirmed.
- `ALUOp` encoding and `ImmSrc` encoding here are matched 1:1 to the already-verified `ALU_Control` and `ImmGen` modules — no changes needed on either side.
