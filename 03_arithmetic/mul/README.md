# Arithmetic: MUL

This folder demonstrates integer multiplication and the special behavior of the `MUL` instruction.

## Example 1: `mul1.asm`

Program logic:

```asm
mov al, [num1]      ; AL = 25
mul byte [num2]     ; AX = AL * 10
```

Calculation:

- `25 * 10 = 250`
- Decimal result: `250`
- `AX = 0x00FA`

### Flags after `MUL`

- `CF = 0`  
  The upper half of the 16-bit result is zero, so no carry is produced.
- `OF = 0`  
  The upper half of the product is also zero, so there is no overflow beyond the operand size.
- `SF`, `ZF`, `AF`, `PF`  
  These flags are not defined by `MUL` in a useful way for normal condition testing, so they are not relied on here.

Reason: `MUL` is different from `ADD` and `SUB`. It produces a wider result and sets `CF` and `OF` only when the upper half is non-zero.

## Example 2: `mul3.asm`

Program logic:

```asm
mov eax, [num1]     ; EAX = 100000
mul dword [num2]    ; EDX:EAX = EAX * 300000
```

Calculation:

- `100000 * 300000 = 30,000,000,000`
- This product is larger than 32 bits, so the result spans both `EAX` and `EDX`.

### Flags after `MUL`

- `CF = 1`  
  The upper 32 bits (`EDX`) are non-zero, so the multiplication overflowed the lower 32-bit register.
- `OF = 1`  
  A non-zero high-half result means the product cannot fit in the destination register width, so `OF` is set.
- `SF`, `ZF`, `AF`, `PF`  
  These flags are not meaningful after `MUL` and are not used here.

## Summary

The `MUL` instruction is different from the arithmetic instructions that set all condition flags:

- `CF = 1` and `OF = 1` when the upper half of the product is non-zero.
- `CF = 0` and `OF = 0` when the result fits completely in the lower register half.
- Other flags are not consistently defined for `MUL` and should not be interpreted as arithmetic status flags in the same way as `ADD` or `SUB`.

This is why the explanation depends on whether the result spills into the higher-order bits, not on the raw value alone.
