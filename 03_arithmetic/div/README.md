# DIV – Arithmetic Operations and EFLAGS

This folder demonstrates unsigned division using the x86 `DIV` instruction.

A key point for this assignment is that **`DIV` does not define the arithmetic status flags**. Therefore, CF, PF, AF, ZF, SF and OF cannot correctly be described as set or cleared based on the quotient or remainder.

If GDB displays values for these flags after `DIV`, those values are not reliable indicators of the division result. They may reflect values left by an earlier instruction.

## Program 1: `div1.asm`

### Operation

```asm
mov ax, [dividend]  ; AX = 100
mov bl, [divisor]   ; BL = 7
div bl
```

For an 8-bit divisor, `DIV` divides the 16-bit `AX` value by the 8-bit operand.

```text
100 ÷ 7 = 14 remainder 2
```

Therefore:

```text
AL = 14       ; quotient
AH = 2        ; remainder
```

### EFLAGS after `DIV`

| Flag | Status | Explanation |
|---|---|---|
| CF | Undefined | `DIV` does not define CF. It cannot be determined from the quotient or remainder. |
| PF | Undefined | `DIV` does not define PF. |
| AF | Undefined | `DIV` does not define AF. |
| ZF | Undefined | `DIV` does not define ZF, even though the quotient is non-zero. |
| SF | Undefined | `DIV` does not define SF. |
| OF | Undefined | `DIV` does not define OF. |

## Program 2: `div2.asm`

### Operation

```asm
mov ax, [dividend]  ; AX = 50000
mov dx, [highpart]  ; DX = 0
mov bx, [divisor]   ; BX = 300
div bx
```

For a 16-bit divisor, `DIV` divides the 32-bit `DX:AX` dividend by the 16-bit divisor.

The calculation is:

```text
50000 ÷ 300 = 166 remainder 200
```

Therefore:

```text
AX = 166       ; quotient
DX = 200       ; remainder
```

### EFLAGS after `DIV`

| Flag | Status | Explanation |
|---|---|---|
| CF | Undefined | `DIV` leaves CF undefined. |
| PF | Undefined | `DIV` leaves PF undefined. |
| AF | Undefined | `DIV` leaves AF undefined. |
| ZF | Undefined | `DIV` leaves ZF undefined. |
| SF | Undefined | `DIV` leaves SF undefined. |
| OF | Undefined | `DIV` leaves OF undefined. |

## Summary

Unlike `ADD`, `SUB`, and `MUL`, the `DIV` instruction does not produce defined arithmetic status flags. The important outputs of division are the **quotient and remainder**, stored in the registers specified by the operand size. Therefore, a GDB display of EFLAGS after `DIV` should not be used to claim that a particular flag was set or cleared.
