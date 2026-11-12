# Arithmetic: DIV

This folder demonstrates integer division and the important fact that the `DIV` instruction does not define the standard arithmetic flags in the same way as `ADD`, `SUB`, and `MUL`.

## Example 1: `div1.asm`

Program logic:

```asm
mov ax, [dividend]  ; AX = 100
mov bl, [divisor]   ; BL = 7
div bl              ; AL = quotient, AH = remainder
```

Calculation:

- `100 / 7 = 14` with remainder `2`
- `AL = 14` (`0x0E`)
- `AH = 2`

### Flags after `DIV`

- `CF = undefined`
- `OF = undefined`
- `SF = undefined`
- `ZF = undefined`
- `AF = undefined`
- `PF = undefined`

Reason: On x86, `DIV` is a division instruction, not a general arithmetic instruction. It does not produce condition codes in the same way as `ADD` or `SUB`. The quotient and remainder are stored in the register pair, and the flags are not meaningful for branch decisions after division.

## Example 2: `div2.asm`

Program logic:

```asm
mov ax, [dividend]  ; AX = 50000
mov dx, [highpart]  ; DX = 0
mov bx, [divisor]   ; BX = 300
div bx              ; AX = quotient, DX = remainder
```

Calculation:

- `50000 / 300 = 166` with remainder `200`
- Quotient = `166` (`0x00A6`)
- Remainder = `200` (`0x00C8`)

### Flags after `DIV`

- `CF = undefined`
- `OF = undefined`
- `SF = undefined`
- `ZF = undefined`
- `AF = undefined`
- `PF = undefined`

Reason: `DIV` does not set arithmetic condition flags in the standard sense. The hardware uses the division result to place quotient and remainder in registers; it does not encode the same flags that `ADD` and `SUB` do.

## Summary

For `DIV`, the correct interpretation is:

- The result is stored in quotient/remainder registers.
- The condition flags are not defined as reliable status indicators.

This is an important difference from `ADD`, `SUB`, and `MUL`, where the flags are used to describe carry, borrow, overflow, and parity.
