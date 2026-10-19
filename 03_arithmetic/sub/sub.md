# Subtraction Findings

`1` = set; `0` = cleared. Flags are shown immediately after each instruction.

| File | Instruction | Result | CF | PF | AF | ZF | SF | OF |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [sub1.asm](sub1.asm) | `sub al, [num2]` | `AL = 0xE2` (-30 signed, 226 unsigned) | 1 | 1 | 0 | 0 | 1 | 0 |
| [sub2.asm](sub2.asm) | `sub ax, [num2]` | `AX = 0xFC18` (-1000 signed, 64536 unsigned) | 1 | 1 | 0 | 0 | 1 | 0 |
| [sub3.asm](sub3.asm) | `sub ax, [num2]` | `AX = 0xFFFF` (-1 signed, 65535 unsigned) | 1 | 1 | 1 | 0 | 1 | 0 |
| [sub3.asm](sub3.asm) | `sbb ax, 0` | `AX = 0xFFFE` (-2 signed, 65534 unsigned) | 0 | 0 | 0 | 0 | 1 | 0 |

## Why

- **[sub1.asm](sub1.asm):** `50 - 80 = -30`. **CF** is set for unsigned
  borrow, **SF** for the negative result, and **PF** because `0xE2` has four
  1 bits. **AF** is clear: the low nibbles `0x2 - 0x0` need no borrow.
- **[sub2.asm](sub2.asm):** `1000 - 2000 = -1000`. **CF** is set for
  unsigned borrow, **SF** for the negative result, and **PF** because the low
  byte `0x18` has two 1 bits. **AF** is clear: `0x8 - 0x0` needs no borrow.
- **[sub3.asm](sub3.asm), SUB:** `0 - 1` wraps to `0xFFFF`. **CF/AF**
  are set for unsigned and low-nibble borrows, **SF** for the negative result,
  and **PF** because the low byte `0xFF` has eight 1 bits.
- **SBB:** Uses the previous `CF = 1`: `0xFFFF - 0 - 1 = 0xFFFE` (-2).
  Only **SF** remains set. No new unsigned or low-nibble borrow occurs, and
  the low byte `0xFE` has seven 1 bits (odd parity). The stored result is -2.

All results are nonzero and fit their signed ranges, so **ZF = 0, OF = 0**.

**Inspect before the exit code.** `xor ebx, ebx` replaces these flags with
`CF=0, PF=1, ZF=1, SF=0, OF=0`; AF is undefined.