# IF/ID Pipeline Register  Specification

## 1. Module Name

`IF_ID`

---

## 2. Purpose

The IF/ID Pipeline Register separates the **Instruction Fetch (IF)** stage from the **Instruction Decode (ID)** stage in the pipelined RV32I processor.

It captures all outputs generated during the IF stage on every rising clock edge and forwards them to the ID stage during the next clock cycle.

This register allows the IF and ID stages to execute concurrently while preserving instruction correctness.

---

## 3. Inputs

| Signal | Width | Description |
|---------|:----:|-------------|
| clk | 1 | System clock |
| reset | 1 | Active-high synchronous reset |
| stall | 1 | Holds current values when asserted |
| flush | 1 | Clears pipeline register when asserted |
| pc_current_in | 32 | Current Program Counter value |
| pc_plus4_in | 32 | PC + 4 |
| instruction_in | 32 | Instruction fetched from Instruction Memory |

---

## 4. Outputs

| Signal | Width | Description |
|---------|:----:|-------------|
| pc_current_out | 32 | Registered Program Counter |
| pc_plus4_out | 32 | Registered PC + 4 |
| instruction_out | 32 | Registered instruction |

---

## 5. Functional Behavior

### Normal Operation

On every rising edge of the clock, when neither `stall` nor `flush` is asserted, the input values are stored into the pipeline register.

```verilog
pc_current_out <= pc_current_in;
pc_plus4_out <= pc_plus4_in;
instruction_out <= instruction_in;
```

---

### Reset Operation

When `reset` is asserted, all pipeline register outputs are cleared.

```verilog
pc_current_out <= 32'b0;
pc_plus4_out <= 32'b0;
instruction_out <= 32'b0;
```

---

### Stall Operation

When `stall` is asserted, the register holds its previous contents.

No values are updated.

```verilog
pc_current_out <= pc_current_out;
pc_plus4_out <= pc_plus4_out;
instruction_out <= instruction_out;
```

---

### Flush Operation

When `flush` is asserted, the pipeline register is cleared.

This inserts a NOP into the Decode stage.

```verilog
pc_current_out <= 32'b0;
pc_plus4_out <= 32'b0;
instruction_out <= 32'b0;
```

---

## 6. Priority

When multiple control signals occur simultaneously, the priority shall be:

1. Reset
2. Flush
3. Stall
4. Normal Update

Example implementation:

```verilog
always @(posedge clk) begin
    if (reset) begin
        ...
    end
    else if (flush) begin
        ...
    end
    else if (stall) begin
        ...
    end
    else begin
        ...
    end
end
```

---

## 7. Hardware Resources

This module consists only of pipeline registers.

Stored signals:

- Current PC
- PC + 4
- Instruction

No arithmetic or combinational logic is performed.

---

## 8. Reset Behavior

Active-high synchronous reset.

After reset:

- PC output = 0
- PC + 4 output = 0
- Instruction output = 0

This effectively inserts a NOP into the pipeline.

---

## 9. Verification Strategy

The module should be verified using a dedicated testbench covering the following cases:

- Reset operation
- Normal pipeline update
- Multiple consecutive instruction transfers
- Stall operation (outputs remain unchanged)
- Flush operation (outputs cleared)
- Flush priority over stall
- Reset priority over flush and stall

---

## 10. Notes

- This module introduces the first pipeline boundary of the processor.
- No instruction decoding occurs inside this module.
- No control signals are generated.
- The module only stores IF-stage outputs for use by the ID stage.
- Stall support is required for load-use hazard handling.
- Flush support is required for branch and jump recovery.
- The outputs represent the complete state transferred from the IF stage to the ID stage during each clock cycle.
