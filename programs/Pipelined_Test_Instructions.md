# Test Program Instructions

| PC | Machine Code | Assembly | Description |
|----|--------------|----------|-------------|
| 0x00 | 00500093 | addi x1, x0, 5 | x1 = 5 |
| 0x04 | 00a00113 | addi x2, x0, 10 | x2 = 10 |
| 0x08 | 00f00193 | addi x3, x0, 15 | x3 = 15 |
| 0x0C | 01400213 | addi x4, x0, 20 | x4 = 20 |
| 0x10 | 01900293 | addi x5, x0, 25 | x5 = 25 |
| 0x14 | 01e00313 | addi x6, x0, 30 | x6 = 30 |
| 0x18 | 02300393 | addi x7, x0, 35 | x7 = 35 |
| 0x1C | 02800413 | addi x8, x0, 40 | x8 = 40 |
| 0x20 | 002084b3 | add x9, x1, x2 | x9 = x1 + x2 (15) |
| 0x24 | 40348533 | sub x10, x9, x3 | x10 = x9 - x3 (0) |
| 0x28 | 004575b3 | and x11, x10, x4 | x11 = x10 & x4 (0) |
| 0x2C | 0055e633 | or x12, x11, x5 | x12 = x11 \| x5 (25) |
| 0x30 | 006646b3 | xor x13, x12, x6 | x13 = x12 ^ x6 (7) |
| 0x34 | 0020a733 | slt x14, x1, x2 | x14 = (x1 < x2) ? 1 : 0 (1) |
| 0x38 | 00a487b3 | add x15, x9, x10 | x15 = x9 + x10 (15) |
| 0x3C | 40b78833 | sub x16, x15, x11 | x16 = x15 - x11 (15) |
| 0x40 | 00c868b3 | or x17, x16, x12 | x17 = x16 \| x12 (31) |
| 0x44 | 00d8c933 | xor x18, x17, x13 | x18 = x17 ^ x13 (24) |
| 0x48 | 00e979b3 | and x19, x18, x14 | x19 = x18 & x14 (0) |
| 0x4C | 01302023 | sw x19, 0(x0) | Store x19 to memory[0] |
| 0x50 | 00002a03 | lw x20, 0(x0) | Load memory[0] into x20 |
| 0x54 | 001a0ab3 | add x21, x20, x1 | x21 = x20 + x1 (5) |
| 0x58 | 01502223 | sw x21, 4(x0) | Store x21 to memory[4] |
| 0x5C | 00402b03 | lw x22, 4(x0) | Load memory[4] into x22 |
| 0x60 | 402b0bb3 | sub x23, x22, x2 | x23 = x22 - x2 (-5) |
| 0x64 | 01702423 | sw x23, 8(x0) | Store x23 to memory[8] |
| 0x68 | 00802c03 | lw x24, 8(x0) | Load memory[8] into x24 |
| 0x6C | 003c4cb3 | xor x25, x24, x3 | x25 = x24 ^ x3 (-10) |
| 0x70 | 00802d03 | lw x26, 8(x0) | Load memory[8] into x26 |
| 0x74 | 004d0db3 | add x27, x26, x4 | x27 = x26 + x4 (15) |
| 0x78 | 00208463 | beq x1, x2, +8 | Branch if x1 == x2 (Not taken) |
| 0x7C | 06400e13 | addi x28, x0, 100 | x28 = 100 |
| 0x80 | 00108663 | beq x1, x1, +12 | Branch if x1 == x1 (Taken) |
| 0x84 | 0c800e93 | addi x29, x0, 200 | Skipped by branch |
| 0x88 | 0c900f13 | addi x30, x0, 201 | Skipped by branch |
| 0x8C | 00209463 | bne x1, x2, +8 | Branch if x1 != x2 (Taken) |
| 0x90 | 12c00f93 | addi x31, x0, 300 | Skipped by branch |
| 0x94 | 00c0056f | jal x10, +12 | Jump to L4, x10 = PC + 4 (0x98) |
| 0x98 | 19000593 | addi x11, x0, 400 | Skipped by jump |
| 0x9C | 19100613 | addi x12, x0, 401 | Skipped by jump |
| 0xA0 | 015d86b3 | add x13, x27, x21 | x13 = x27 + x21 (20) |
| 0xA4 | 41668733 | sub x14, x13, x22 | x14 = x13 - x22 (15) |
| 0xA8 | 017777b3 | and x15, x14, x23 | x15 = x14 & x23 (11) |
| 0xAC | 0187e833 | or x16, x15, x24 | x16 = x15 \| x24 (-5) |
| 0xB0 | 019848b3 | xor x17, x16, x25 | x17 = x16 ^ x25 (5) |
| 0xB4 | 01a8a933 | slt x18, x17, x26 | x18 = (x17 < x26) ? 1 : 0 (0) |
| 0xB8 | 01202623 | sw x18, 12(x0) | Store x18 to memory[12] |
| 0xBC | 00c02983 | lw x19, 12(x0) | Load memory[12] into x19 |
| 0xC0 | 01298a33 | add x20, x19, x18 | x20 = x19 + x18 (0) |
| 0xC4 | 411a0ab3 | sub x21, x20, x17 | x21 = x20 - x17 (-5) |
| 0xC8 | 010afb33 | and x22, x21, x16 | x22 = x21 & x16 (-5) |
| 0xCC | 00fb6bb3 | or x23, x22, x15 | x23 = x22 \| x15 (-5) |
| 0xD0 | 00ebcc33 | xor x24, x23, x14 | x24 = x23 ^ x14 (-10) |
| 0xD4 | 00dc2cb3 | slt x25, x24, x13 | x25 = (x24 < x13) ? 1 : 0 (1) |
| 0xD8 | 01902823 | sw x25, 16(x0) | Store x25 to memory[16] |
| 0xDC | 01002d03 | lw x26, 16(x0) | Load memory[16] into x26 |
| 0xE0 | 00cd0db3 | add x27, x26, x12 | x27 = x26 + x12 |
| 0xE4 | 40bd8e33 | sub x28, x27, x11 | x28 = x27 - x11 |
| 0xE8 | 01c02a23 | sw x28, 20(x0) | Store x28 to memory[20] |
| 0xEC | 01402e83 | lw x29, 20(x0) | Load memory[20] into x29 |
| 0xF0 | 00aecf33 | xor x30, x29, x10 | x30 = x29 ^ x10 |
| 0xF4 | 009f6fb3 | or x31, x30, x9 | x31 = x30 \| x9 |
| 0xF8 | 008f80b3 | add x1, x31, x8 | x1 = x31 + x8 |
| 0xFC | 40708133 | sub x2, x1, x7 | x2 = x1 - x7 |
| 0x100 | 006171b3 | and x3, x2, x6 | x3 = x2 & x6 |
| 0x104 | 0051e233 | or x4, x3, x5 | x4 = x3 \| x5 |
| 0x108 | 001242b3 | xor x5, x4, x1 | x5 = x4 ^ x1 |
| 0x10C | 0022a333 | slt x6, x5, x2 | x6 = (x5 < x2) ? 1 : 0 |
| 0x110 | 00030463 | beq x6, x0, +8 | Branch if x6 == x0 |
| 0x114 | 1f400393 | addi x7, x0, 500 | x7 = 500 |
| 0x118 | 00531463 | bne x6, x5, +8 | Branch if x6 != x5 |
| 0x11C | 25800413 | addi x8, x0, 600 | x8 = 600 |
| 0x120 | 00c004ef | jal x9, +12 | Jump to L8, x9 = PC + 4 (0x124) |
| 0x124 | 2bc00513 | addi x10, x0, 700 | Skipped by jump |
| 0x128 | 2bd00593 | addi x11, x0, 701 | Skipped by jump |
| 0x12C | 00002603 | lw x12, 0(x0) | Load memory[0] into x12 |
| 0x130 | 00b606b3 | add x13, x12, x11 | x13 = x12 + x11 |
| 0x134 | 00d02c23 | sw x13, 24(x0) | Store x13 to memory[24] |
| 0x138 | 01802703 | lw x14, 24(x0) | Load memory[24] into x14 |
| 0x13C | 40a707b3 | sub x15, x14, x10 | x15 = x14 - x10 |
| 0x140 | 00f02e23 | sw x15, 28(x0) | Store x15 to memory[28] |
| 0x144 | 01c02803 | lw x16, 28(x0) | Load memory[28] into x16 |
| 0x148 | 009848b3 | xor x17, x16, x9 | x17 = x16 ^ x9 |
| 0x14C | 0088e933 | or x18, x17, x8 | x18 = x17 \| x8 |
| 0x150 | 007979b3 | and x19, x18, x7 | x19 = x18 & x7 |
| 0x154 | 00698a33 | add x20, x19, x6 | x20 = x19 + x6 |
| 0x158 | 405a0ab3 | sub x21, x20, x5 | x21 = x20 - x5 |
| 0x15C | 004acb33 | xor x22, x21, x4 | x22 = x21 ^ x4 |
| 0x160 | 003b6bb3 | or x23, x22, x3 | x23 = x22 \| x3 |
| 0x164 | 002bfc33 | and x24, x23, x2 | x24 = x23 & x2 |
| 0x168 | 001c2cb3 | slt x25, x24, x1 | x25 = (x24 < x1) ? 1 : 0 |
| 0x16C | 03902023 | sw x25, 32(x0) | Store x25 to memory[32] |
| 0x170 | 02002d03 | lw x26, 32(x0) | Load memory[32] into x26 |
| 0x174 | 019d0db3 | add x27, x26, x25 | x27 = x26 + x25 |
| 0x178 | 00000063 | beq x0, x0, 0 | Infinite loop (END) |
