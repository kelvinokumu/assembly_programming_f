# Arithmetic: ADD

This folder demonstrates integer addition and how the x86 status flags change after `ADD` instructions.

## Example 1: `add1.asm`

Program logic:

```asm
mov al, [num1]   ; AL = 120 (0x78)
add al, [num2]   ; AL = AL + 10 (0x0A)
```

Calculation:

- `0x78 + 0x0A = 0x82`
- Decimal: `120 + 10 = 130`

### Flags after `ADD`

- `CF = 0`  
  No carry out of bit 7 occurred, because `0x78 + 0x0A = 0x82` does not exceed 8 bits.
- `OF = 1`  
  Signed overflow occurred. Both operands were positive, but the result `130` cannot be represented in a signed 8-bit value (`127` max). The bit pattern `10000010` is interpreted as `-126` in signed form.
- `SF = 1`  
  The result bit 7 is set (`0x82` has the sign bit set), so the result is negative in signed interpretation.
- `ZF = 0`  
  The result is not zero.
- `AF = 1`  
  There is a carry from bit 3 to bit 4: `0x8 + 0xA = 0x12`, so the half-carry flag is set.
- `PF = 1`  
  `0x82` has two 1 bits, which is even parity, so the parity flag is set.

## Example 2: `add2.asm`

Program logic:

```asm
mov ax, [num1]   ; AX = 32000 (0x7D00)
add ax, [num2]   ; AX = AX + 500 (0x01F4)
```

Calculation:

- `32000 + 500 = 32500`
- `0x7D00 + 0x01F4 = 0x7EF4`

### Flags after `ADD`

- `CF = 0`  
  There is no carry beyond bit 15.
- `OF = 0`  
  The signed result stays within range: both inputs are positive, and the final value remains positive.
- `SF = 0`  
  The sign bit is not set; the result is positive.
- `ZF = 0`  
  The result is not zero.
- `AF = 0`  
  No half-carry from bit 3 to bit 4 occurs in this case.
- `PF = 1`  
  The low byte `0xF4` contains an even number of 1 bits, so parity is even.

## Summary

`ADD` updates the flags based on the arithmetic result:

- `CF` reflects unsigned carry out.
- `OF` reflects signed overflow.
- `ZF` shows whether the result is zero.
- `SF` reflects the sign bit.
- `AF` reflects carry from bit 3 to bit 4.
- `PF` reflects even/odd parity of the low byte.

These examples show why the flags are set or cleared based on the actual numerical result, not just because the instruction was `ADD`.
