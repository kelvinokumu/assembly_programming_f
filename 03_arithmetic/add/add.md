# Addition Findings

`1` = set; `0` = cleared. Flags are shown immediately after each instruction.

| File | Instruction | Result | CF | PF | AF | ZF | SF | OF |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [add1.asm](add1.asm) | `add al, [num2]` | `AL = 0x82` (130 unsigned, -126 signed) | 0 | 1 | 1 | 0 | 1 | 1 |
| [add2.asm](add2.asm) | `add ax, [num2]` | `AX = 0x7EF4` (32500) | 0 | 0 | 0 | 0 | 0 | 0 |
| [add3.asm](add3.asm) | `add ax, [num2]` | `AX = 0x0000` | 1 | 1 | 1 | 1 | 0 | 0 |
| [add3.asm](add3.asm) | `adc ax, 0` | `AX = 0x0001` | 0 | 0 | 0 | 0 | 0 | 0 |

## Why

- **[add1.asm](add1.asm):** `120 + 10 = 130` exceeds signed 8-bit range,
  setting **OF** and the sign bit **SF**. **PF** is set because `0x82` has
  two 1 bits; **AF** is set because `0x8 + 0xA = 0x12` carries into bit 4.
  **CF/ZF** are clear: 130 fits an unsigned byte and is nonzero.
- **[add2.asm](add2.asm):** `32000 + 500 = 32500` fits signed and unsigned
  16-bit ranges and is positive/nonzero. The low byte `0xF4` has five 1 bits
  (odd parity), and `0x0 + 0x4` has no auxiliary carry. All six flags are clear.
- **[add3.asm](add3.asm), ADD:** `0xFFFF + 1` wraps to zero, setting **CF**
  (carry), **AF** (low-nibble carry), **ZF** (zero), and **PF** (zero 1 bits
  is even). **SF/OF** are clear: signed `-1 + 1 = 0` fits in 16 bits.
- **ADC:** Uses the previous `CF = 1`: `0 + 0 + 1 = 1`. All six flags
  become clear: no carry or overflow, a positive nonzero result, and odd parity.
  The final stored result is 1.
- **[adc4.asm](adc4.asm):** Empty; no findings.

**Inspect before the exit code.** `xor ebx, ebx` replaces these flags with
`CF=0, PF=1, ZF=1, SF=0, OF=0`; AF is undefined.