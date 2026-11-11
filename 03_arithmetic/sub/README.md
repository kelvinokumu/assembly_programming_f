# SUB – Arithmetic Operations and EFLAGS

This folder demonstrates subtraction and the EFLAGS affected by the `SUB` instruction.

> **Important:** Check EFLAGS immediately after `SUB`. The `xor ebx, ebx` used later to exit the program changes flags.

## Program 1: `sub1.asm`

### Operation

```asm
mov al, [num1]       ; AL = 50
sub al, [num2]       ; AL = 50 - 80
```

The mathematical result is:

```text
50 - 80 = -30
```

In 8-bit two's complement:

```text
50 - 80 = 0xE2
```

`0xE2` represents `-30` as a signed 8-bit value.

### EFLAGS after `SUB`

| Flag | Status | Explanation |
|---|---|---|
| CF | Set (1) | Unsigned subtraction requires a borrow because 50 is smaller than 80. |
| PF | Set (1) | The low byte `0xE2` is `11100010`, containing four 1-bits. Even parity sets PF. |
| AF | Cleared (0) | The low nibble of 50 is `2`, while the low nibble of 80 is `0`. No borrow is needed from bit 4, so AF is cleared. |
| ZF | Cleared (0) | The result is `0xE2`, not zero. |
| SF | Set (1) | The most significant bit of the 8-bit result is 1, indicating a negative signed result. |
| OF | Cleared (0) | Subtracting two positive numbers does not produce a signed overflow in this case. The signed result, -30, is within the 8-bit signed range. |

## Program 2: `sub2.asm`

### Operation

```asm
mov ax, [num1]       ; AX = 1000
sub ax, [num2]       ; AX = 1000 - 2000
```

The mathematical result is:

```text
1000 - 2000 = -1000
```

The 16-bit two's-complement result is:

```text
0xFC18
```

### EFLAGS after `SUB`

| Flag | Status | Explanation |
|---|---|---|
| CF | Set (1) | As an unsigned subtraction, 1000 is smaller than 2000, so the operation requires a borrow. |
| PF | Set (1) | The low byte is `0x18` (`00011000`), containing two 1-bits, so parity is even and PF is set. |
| AF | Cleared (0) | The low nibble of 1000 is `0`, and the low nibble of 2000 is also `0`, so no borrow occurs between bit 3 and bit 4. |
| ZF | Cleared (0) | The result is `-1000`, not zero. |
| SF | Set (1) | Bit 15 of `0xFC18` is 1, indicating a negative signed result. |
| OF | Cleared (0) | The subtraction produces -1000, which is inside the signed 16-bit range, so signed overflow does not occur. |

## Summary

`SUB` uses CF to indicate an unsigned borrow, while OF indicates signed overflow. These are different concepts: a subtraction can set CF without setting OF, as both examples demonstrate.
