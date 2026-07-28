# ID/EX Pipeline Register Specification

## 1. Module Name

`ID_EX`

---

## 2. Purpose

The ID/EX Pipeline Register separates the **Instruction Decode (ID)** stage from the **Execute (EX)** stage in the pipelined RV32I processor.

It captures all decoded instruction information, register values, immediate values, instruction fields, and control signals generated during the ID stage on every rising clock edge.

The stored values are forwarded to the EX stage during the next clock cycle, allowing the ID and EX stages to execute concurrently while maintaining correct instruction execution.

---

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
| ALUControl_in | 4 | Defines ALU operation |
| Branch_in | 1 | Enables branch operation |
| MemRead_in | 1 | Enables memory read |
| MemWrite_in | 1 | Enables memory write |
| RegWrite_in | 1 | Enables register file write |
| MemToReg_in | 1 | Selects memory data or ALU result |

---

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
| ALUControl_out | 4 | Registered ALU operation control |
| Branch_out | 1 | Registered branch control |
| MemRead_out | 1 | Registered memory read control |
| MemWrite_out | 1 | Registered memory write control |
| RegWrite_out | 1 | Registered register write control |
| MemToReg_out | 1 | Registered memory-to-register control |

---

# 5. Functional Behavior

## Normal Operation

When `reset` and `flush` are not asserted, the ID/EX pipeline register captures all input values on every rising edge of the clock.

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
ALUControl_out <= ALUControl_in;
Branch_out <= Branch_in;

MemRead_out <= MemRead_in;
MemWrite_out <= MemWrite_in;

RegWrite_out <= RegWrite_in;
MemToReg_out <= MemToReg_in;
```

---

## Reset Operation

When `reset` is asserted, all pipeline register outputs are cleared.

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
ALUControl_out <= 4'b0;
Branch_out <= 1'b0;

MemRead_out <= 1'b0;
MemWrite_out <= 1'b0;

RegWrite_out <= 1'b0;
MemToReg_out <= 1'b0;
```

Reset inserts a NOP into the Execute stage.

---

## Flush Operation

When `flush` is asserted, the pipeline register is cleared.

Flush is used during control hazards such as:

- Taken branch
- Jump instruction

The current instruction is converted into a NOP by disabling all control signals.

```verilog
RegWrite_out <= 1'b0;
MemRead_out <= 1'b0;
MemWrite_out <= 1'b0;
Branch_out <= 1'b0;
```

This prevents incorrect instructions from modifying processor state.

---

# 6. Priority

When multiple control signals occur simultaneously, the priority shall be:

1. Reset
2. Flush
3. Normal Update

Example implementation:

```verilog
always @(posedge clk)
begin

    if(reset)
    begin
        ...
    end

    else if(flush)
    begin
        ...
    end

    else
    begin
        ...
    end

end
```

---

# 7. Hardware Resources

This module consists only of pipeline registers.

Stored signals:

## Data Signals

- Current Program Counter
- PC + 4
- rs1 register data
- rs2 register data
- Immediate value

## Instruction Fields

- rs1 address
- rs2 address
- rd address
- funct3
- funct7

## Control Signals

- ALUSrc
- ALUControl
- Branch
- MemRead
- MemWrite
- RegWrite
- MemToReg

No arithmetic, logical, or memory operation is performed inside this module.

---

# 8. Reset Behavior

Active-high synchronous reset.

After reset:

- PC output = 0
- PC + 4 output = 0
- Register data outputs = 0
- Immediate output = 0
- Instruction fields = 0
- All control signals = 0

The pipeline contains an empty instruction (NOP).

---

# 9. Verification Strategy

The module should be verified using a dedicated testbench covering:

- Reset operation
- Normal pipeline update
- Data signal transfer
- Instruction field transfer
- Control signal transfer
- Flush operation
- NOP insertion after flush
- Multiple consecutive instruction transfers

Expected behavior:

| Test Case | Expected Result |
|-----------|----------------|
| Normal clock | Inputs appear at outputs |
| Reset | All outputs become zero |
| Flush | Control signals become zero |
| Multiple instructions | Correct sequential transfer |

---

# 10. Notes

- This module creates the second pipeline boundary of the processor.
- No ALU operation occurs inside this module.
- No memory operation occurs inside this module.
- No instruction decoding occurs inside this module.
- Control signals are generated in the ID stage and stored here.
- This register maintains pipeline state between Decode and Execute stages.
- The outputs represent the complete execution information required by the EX stage.
