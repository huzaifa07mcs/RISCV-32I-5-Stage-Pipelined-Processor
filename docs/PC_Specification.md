# Program Counter (PC) Specification

## Purpose

Stores the address of the current instruction.

## Inputs

- clk
- reset
- pc_next

## Outputs

- pc_current

## Width

- 32-bit

## Functional Behavior

- On every rising edge of clk:
    - pc_current <= pc_next

- On reset:
    - pc_current <= 32'h00000000

## Verification

- Verify reset.
- Verify sequential updates.
- Verify jump to arbitrary address.
