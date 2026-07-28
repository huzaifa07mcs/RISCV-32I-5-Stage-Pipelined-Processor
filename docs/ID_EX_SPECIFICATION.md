# ID/EX Pipeline Register Specification

## 1. Module Name
`ID_EX`

## 2. Purpose
The ID/EX Pipeline Register separates the **Instruction Decode (ID)** stage from the **Execute (EX)** stage in the pipelined RV32I processor. It captures all decoded instruction information, register values, immediate values, instruction fields, and control signals generated during the ID stage on every rising clock edge.

The stored values are forwarded to the EX stage during the next clock cycle, allowing the ID and EX stages to execute concurrently while maintaining correct instruction execution.

**Design note:** `ALUOp` (2-bit, from Main Control) is carried forward here — not the final `ALUControl` (3-bit). The `ALU_Control` module is instantiated in the EX stage itself, consuming `ALUOp_out`, `funct3_out`, and `funct7_out[5]` from this register to compute `ALUControl` right before the ALU. This is the standard textbook/industry approach — keeps `ALU_Control`'s combinational logic in the same stage as the `ALU` it feeds.

## 3. Inputs

| Signal | Width | Description |
|---------|:----:|-------------|
| clk | 1 | System clock |
| reset | 1 | Active-high synchronous reset |
| flush | 1 | Clears pipeline register when asserted |
| pc_in | 32 | Current Program Counter value |
| pc_plus4_in | 32 | PC + 4 value |
| rs1_data_in | 32 | Data read from source register rs1 |
| rs2_data_in | 32 | Data read from source register rs2 |
| imm_in | 32 | Generated immediate value |
| rs1_in | 5 | Source register 1 address |
| rs2_in | 5 | Source register 2 address |
| rd_in | 5 | Destination register address |
| funct3_in | 3 | Instruction funct3 field |
| funct7_in | 7 | Instruction funct7 field |
| ALUSrc_in | 1 | Selects ALU operand source |
| ALUOp_in | 2 | Coarse ALU operation class (fed to ALU_Control in EX stage) |
| Branch_in | 1 | Enables branch operation |
| Jump_in | 1 | Enables jump (JAL) — needed for EX-stage jump-target mux and WB-stage write-back override |
| MemRead_in | 1 | Enables memory read |
| MemWrite_in | 1 | Enables memory write |
| RegWrite_in | 1 | Enables register file write |
| MemToReg_in | 1 | Selects memory data or ALU result |

## 4. Outputs

| Signal | Width | Description |
|---------|:----:|-------------|
| pc_out | 32 | Registered Program Counter |
| pc_plus4_out | 32 | Registered PC + 4 |
| rs1_data_out | 32 | Registered rs1 data |
| rs2_data_out | 32 | Registered rs2 data |
| imm_out | 32 | Registered immediate value |
| rs1_out | 5 | Registered source register 1 address |
| rs2_out | 5 | Registered source register 2 address |
| rd_out | 5 | Registered destination register address |
| funct3_out | 3 | Registered funct3 field |
| funct7_out | 7 | Registered funct7 field |
| ALUSrc_out | 1 | Registered ALU source control |
| ALUOp_out | 2 | Registered ALU operation class |
| Branch_out | 1 | Registered branch control |
| Jump_out | 1 | Registered jump control |
| MemRead_out | 1 | Registered memory read control |
| MemWrite_out | 1 | Registered memory write control |
| RegWrite_out | 1 | Registered register write control |
| MemToReg_out | 1 | Registered memory-to-register control |

## 5. Functional Behavior

### Normal Operation
```verilog
pc_out <= pc_in;
pc_plus4_out <= pc_plus4_in;
rs1_data_out <= rs1_data_in;
rs2_data_out <= rs2_data_in;
imm_out <= imm_in;
rs1_out <= rs1_in;
rs2_out <= rs2_in;
rd_out <= rd_in;
funct3_out <= funct3_in;
funct7_out <= funct7_in;
ALUSrc_out <= ALUSrc_in;
ALUOp_out <= ALUOp_in;
Branch_out <= Branch_in;
Jump_out <= Jump_in;
MemRead_out <= MemRead_in;
MemWrite_out <= MemWrite_in;
RegWrite_out <= RegWrite_in;
MemToReg_out <= MemToReg_in;
```

### Reset Operation
```verilog
pc_out <= 32'b0;
pc_plus4_out <= 32'b0;
rs1_data_out <= 32'b0;
rs2_data_out <= 32'b0;
imm_out <= 32'b0;
rs1_out <= 5'b0;
rs2_out <= 5'b0;
rd_out <= 5'b0;
funct3_out <= 3'b0;
funct7_out <= 7'b0;
ALUSrc_out <= 1'b0;
ALUOp_out <= 2'b0;
Branch_out <= 1'b0;
Jump_out <= 1'b0;
MemRead_out <= 1'b0;
MemWrite_out <= 1'b0;
RegWrite_out <= 1'b0;
MemToReg_out <= 1'b0;
```

Reset inserts a NOP into the Execute stage.

### Flush Operation
Used during control hazards (taken branch, jump). Converts the current instruction into a NOP by disabling all control signals:

```verilog
RegWrite_out <= 1'b0;
MemRead_out <= 1'b0;
MemWrite_out <= 1'b0;
Branch_out <= 1'b0;
Jump_out <= 1'b0;
```

## 6. Priority
1. Reset
2. Flush
3. Normal Update

```verilog
always @(posedge clk)
begin
    if(reset) begin ... end
    else if(flush) begin ... end
    else begin ... end
end
```

## 7. Hardware Resources
Pipeline registers only — no arithmetic, logic, or memory operation performed here.

Stored signals:
- PC, PC+4, rs1/rs2 data, immediate
- rs1/rs2/rd addresses, funct3, funct7
- ALUSrc, ALUOp, Branch, Jump, MemRead, MemWrite, RegWrite, MemToReg

## 8. Reset Behavior
Active-high synchronous reset. After reset, all outputs (including `ALUOp_out`, `Jump_out`) = 0. Pipeline contains a NOP.

## 9. Verification Strategy
- Reset operation
- Normal pipeline update
- Data signal transfer
- Instruction field transfer
- Control signal transfer, **including `ALUOp` and `Jump`** (confirm both correctly propagate — `Jump` specifically needs a JAL test case)
- Flush operation
- NOP insertion after flush
- Multiple consecutive instruction transfers

## 10. Notes
- Second pipeline boundary of the processor.
- Carries `ALUOp` (not `ALUControl`) forward — `ALU_Control` module lives in EX stage, consuming this register's `ALUOp_out`/`funct3_out`/`funct7_out[5]` outputs directly.
- `Jump_out` feeds both the EX-stage jump-target logic and is carried further (via `EX_MEM`) to WB-stage write-back override — mirrors the `Jump`/`pc_plus4` pairing already present in `EX_MEM`.
