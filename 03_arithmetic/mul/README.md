# MUL – Arithmetic Operations and EFLAGS

This folder demonstrates unsigned multiplication using the x86 `MUL` instruction.

For `MUL`, the important defined arithmetic flags are **CF and OF**. They are set when the upper half of the multiplication result is non-zero and cleared when the upper half is zero. The other arithmetic flags (SF, ZF, AF and PF) are **undefined** after `MUL`, so their displayed GDB values must not be interpreted as results produced by the multiplication.

## Program 1: `mul1.asm`

### Operation

```asm
mov al, [num1]      ; AL = 25
mul byte [num2]     ; AX = AL × 10
```

The calculation is:

```text
25 × 10 = 250
```

The 16-bit result is:

```text
AX = 0x00FA
```

The upper half is `AH = 0x00`.

### EFLAGS after `MUL`

| Flag | Status | Explanation |
|---|---|---|
| CF | Cleared (0) | The upper half of the result (`AH`) is zero. Therefore the multiplication fits in the original 8-bit operand size and CF is cleared. |
| OF | Cleared (0) | For unsigned `MUL`, OF has the same condition as CF. Because the upper half is zero, there is no significant overflow beyond 8 bits. |
| SF | Undefined | `MUL` does not define SF. A value shown by GDB should not be treated as a meaningful result from this multiplication. |
| ZF | Undefined | `MUL` does not define ZF, even though the result is non-zero. |
| AF | Undefined | `MUL` does not define AF. |
| PF | Undefined | `MUL` does not define PF. |

## Program 2: `mul2.asm`

### Operation

```asm
mov ax, [num1]      ; AX = 3000
mul word [num2]     ; DX:AX = 3000 × 200
```

The calculation is:

```text
3000 × 200 = 600000
```

The result is stored across `DX:AX`:

```text
DX:AX = 0x0009:0x27C0
```

Because `DX` is non-zero, the result does not fit entirely in the original 16-bit `AX` operand.

### EFLAGS after `MUL`

| Flag | Status | Explanation |
|---|---|---|
| CF | Set (1) | The upper half of the 32-bit product is `DX = 0x0009`, which is non-zero. Therefore the multiplication produced significant bits outside AX. |
| OF | Set (1) | For unsigned `MUL`, OF is set under the same condition as CF: the upper half is non-zero. |
| SF | Undefined | `MUL` does not define SF. |
| ZF | Undefined | `MUL` does not define ZF. |
| AF | Undefined | `MUL` does not define AF. |
| PF | Undefined | `MUL` does not define PF. |

## Summary

For unsigned `MUL`, CF and OF indicate whether the upper half of the product is non-zero. The remaining arithmetic flags are undefined, so GDB values for them should not be used as evidence about the multiplication.
