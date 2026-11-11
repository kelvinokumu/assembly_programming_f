# ADD – Arithmetic Operations and EFLAGS

This folder contains programs that demonstrate addition and how the `ADD` instruction affects the x86 EFLAGS register.

> **Important:** The flags must be checked immediately after the arithmetic instruction. The later `xor ebx, ebx` used for program termination changes some flags, so it should not be used to determine the flags produced by `ADD`.

## Program 1: `add1.asm`

### Operation

```asm
mov al, [num1]       ; AL = 120
add al, [num2]       ; AL = 120 + 10
```

The calculation is:

```text
120 + 10 = 130
```

In 8-bit hexadecimal:

```text
0x78 + 0x0A = 0x82
```

`0x82` represents `-126` when interpreted as a signed 8-bit value, showing signed overflow.

### EFLAGS after `ADD`

| Flag | Status | Explanation |
|---|---|---|
| CF | Cleared (0) | There is no unsigned carry out of bit 7 because `120 + 10 = 130`, which is less than 256. |
| PF | Set (1) | The low byte `0x82` is `10000010`, which contains two 1-bits. Because the number of 1-bits is even, the Parity Flag is set. |
| AF | Set (1) | In the low nibble, `0x8 + 0xA` produces a carry from bit 3 to bit 4. Therefore AF is set. |
| ZF | Cleared (0) | The result is `0x82`, not zero. |
| SF | Set (1) | Bit 7 of `0x82` is 1, so the result is negative when interpreted as signed. |
| OF | Set (1) | Both operands are positive signed 8-bit values, but their mathematical sum is 130, which is outside the signed 8-bit range `-128` to `127`. |

## Program 2: `add2.asm`

### Operation

```asm
mov ax, [num1]       ; AX = 32000
add ax, [num2]       ; AX = 32000 + 500
```

The calculation is:

```text
32000 + 500 = 32500
```

The 16-bit result is:

```text
0x7EF4
```

### EFLAGS after `ADD`

| Flag | Status | Explanation |
|---|---|---|
| CF | Cleared (0) | The unsigned result 32500 fits inside a 16-bit register (`0` to `65535`), so there is no carry out of bit 15. |
| PF | Cleared (0) | The low byte is `0xF4` (`11110100`), which contains five 1-bits. Odd parity clears PF. |
| AF | Cleared (0) | The low nibbles are `0 + 4`, so there is no carry from bit 3 to bit 4. |
| ZF | Cleared (0) | The result `32500` is not zero. |
| SF | Cleared (0) | The most significant bit of the 16-bit result `0x7EF4` is 0, so the signed result is positive. |
| OF | Cleared (0) | 32000 + 500 = 32500, which is within the signed 16-bit range `-32768` to `32767`. |

## Summary

The two examples show why flags cannot be determined only by looking at whether an arithmetic operation "worked." `ADD` sets or clears flags according to properties of the binary result: carries, zero result, sign bit, parity, auxiliary carry, and signed overflow.
