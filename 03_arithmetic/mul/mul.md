# Multiplication Findings

`1` = set; `0` = cleared; `U` = undefined (no guaranteed value).
Flags are shown immediately after `MUL`.

| File | Full product and registers | CF | PF | AF | ZF | SF | OF |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [mul1.asm](mul1.asm) | 250; `AX = 0x00FA` (`AH = 0x00`, `AL = 0xFA`) | 0 | U | U | U | U | 0 |
| [mul2.asm](mul2.asm) | 600000; `DX = 0x0009`, `AX = 0x27C0` | 1 | U | U | U | U | 1 |
| [mul3.asm](mul3.asm) | 30000000000; `EDX = 0x00000006`, `EAX = 0xFC23AC00` | 1 | U | U | U | U | 1 |

## Why

Unsigned `MUL` sets **CF and OF** when the product's upper half is nonzero;
otherwise both are clear. **PF, AF, ZF, and SF are always undefined after MUL**,
not guaranteed cleared or unchanged.

- **[mul1.asm](mul1.asm):** `25 * 10 = 250` fits in an unsigned byte.
  The upper byte `AH = 0`, so **CF = OF = 0**.
- **[mul2.asm](mul2.asm):** `3000 * 200 = 600000` exceeds 16 bits.
  The upper word `DX = 9`, so **CF = OF = 1**.
- **[mul3.asm](mul3.asm):** `100000 * 300000 = 30000000000` exceeds 32 bits.
  The upper dword `EDX = 6`, so **CF = OF = 1**.

All programs store the full double-width product, even when CF and OF are set.

**Inspect before the exit code.** `xor ebx, ebx` replaces these flags with
`CF=0, PF=1, ZF=1, SF=0, OF=0`; AF is undefined.

Instruction reference: [MUL](https://www.felixcloutier.com/x86/mul).