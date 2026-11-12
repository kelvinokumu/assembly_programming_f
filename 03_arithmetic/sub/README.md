# Arithmetic: SUB

This folder demonstrates integer subtraction and how the x86 status flags react to borrow and signed overflow.

## Example 1: `sub1.asm`

Program logic:

```asm
mov al, [num1]   ; AL = 50 (0x32)
sub al, [num2]   ; AL = AL - 80 (0x50)
```

Calculation:

- `50 - 80 = -30`
- In 8-bit unsigned form: `0x32 - 0x50 = 0xE2`

### Flags after `SUB`

- `CF = 1`  
  Borrow occurred because `0x32` is smaller than `0x50`, so subtraction required a borrow from the next higher bit.
- `OF = 1`  
  The signed result is negative, while both operands were positive. That indicates signed overflow in the subtraction interpretation.
- `SF = 1`  
  The result `0xE2` has its sign bit set, so the result is negative.
- `ZF = 0`  
  The result is not zero.
- `AF = 0`  
  No half-carry/borrow occurred between bit 3 and bit 4 in the low nibble.
- `PF = 0`  
  `0xE2` has an odd number of 1 bits, so parity is odd.

## Example 2: `sub2.asm`

Program logic:

```asm
mov ax, [num1]   ; AX = 1000 (0x03E8)
sub ax, [num2]   ; AX = AX - 2000 (0x07D0)
```

Calculation:

- `1000 - 2000 = -1000`
- In 16-bit unsigned form: `0x03E8 - 0x07D0 = 0xFC18`

### Flags after `SUB`

- `CF = 1`  
  Borrow was needed because the minuend was smaller than the subtrahend.
- `OF = 1`  
  The result changed sign from positive to negative, which means the signed subtraction overflowed in the negative direction.
- `SF = 1`  
  The high bit of `0xFC18` is set.
- `ZF = 0`  
  The result is not zero.
- `AF = 0`  
  No nibble borrow occurred in the lower half-byte.
- `PF = 1`  
  `0xFC18` has an even number of 1 bits, so parity is even.

## Summary

`SUB` sets flags according to the result of subtraction and the borrow that happens during the operation:

- `CF` means borrow occurred.
- `OF` means signed overflow occurred.
- `ZF` means the result is zero.
- `SF` reflects the sign bit.
- `AF` reflects borrow from bit 3 to bit 4.
- `PF` reflects parity of the low byte.

The meaning of these flags is not just the displayed hexadecimal result; the flags explain whether a borrow happened and whether the signed result crossed the valid range.
