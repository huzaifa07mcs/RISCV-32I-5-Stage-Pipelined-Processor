# Test Program Instructions

| PC | Machine Code | Assembly | Description |
|----|--------------|----------|-------------|
| 0x00 | 00500093 | addi x1, x0, 5 | x1 = 5 |
| 0x04 | 00A00113 | addi x2, x0, 10 | x2 = 10 |
| 0x08 | 002081B3 | add x3, x1, x2 | x3 = x1 + x2 |
| 0x0C | 40208233 | sub x4, x1, x2 | x4 = x1 - x2 |
| 0x10 | 0020F2B3 | and x5, x1, x2 | x5 = x1 & x2 |
| 0x14 | 0020E333 | or x6, x1, x2 | x6 = x1 \| x2 |
| 0x18 | 0020C3B3 | xor x7, x1, x2 | x7 = x1 ^ x2 |
| 0x1C | 0020A433 | slt x8, x1, x2 | x8 = (x1 < x2) |
| 0x20 | 00802023 | sw x8, 0(x0) | Store x8 to memory[0] |
| 0x24 | 00002483 | lw x9, 0(x0) | Load memory[0] into x9 |
| 0x28 | 00302423 | sw x3, 8(x0) | Store x3 to memory[8] |
| 0x2C | 00802503 | lw x10, 8(x0) | Load memory[8] into x10 |
| 0x30 | 00108463 | beq x1, x1, +8 | Branch taken |
| 0x34 | 00100193 | addi x3, x0, 1 | Skipped |
| 0x38 | 00209463 | bne x1, x2, +8 | Branch taken |
| 0x3C | 00200213 | addi x4, x0, 2 | Skipped |
| 0x40 | 0080006F | jal x0, +8 | Jump |
| 0x44 | 00300293 | addi x5, x0, 3 | Skipped |
| 0x48 | 06300313 | addi x6, x0, 99 | x6 = 99 |
| 0x4C | 00618633 | add x12, x3, x6 | x12 = x3 + x6 |
| 0x50 | 406186B3 | sub x13, x3, x6 | x13 = x3 - x6 |
| 0x54 | 0061F733 | and x14, x3, x6 | x14 = x3 & x6 |
| 0x58 | 0061E7B3 | or x15, x3, x6 | x15 = x3 \| x6 |
| 0x5C | 0061C833 | xor x16, x3, x6 | x16 = x3 ^ x6 |
| 0x60 | 0061A8B3 | slt x17, x3, x6 | x17 = (x3 < x6) |
| 0x64 | 00602823 | sw x6, 16(x0) | Store x6 to memory[16] |
| 0x68 | 01002903 | lw x18, 16(x0) | Load memory[16] into x18 |
| 0x6C | 0000006F | jal x0, 0 | Infinite loop |
