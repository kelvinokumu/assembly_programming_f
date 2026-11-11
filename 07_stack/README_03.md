# 03.asm – CALL and RET only (64-bit)

## What the program does
Sets `rax = 10`, calls `calculate`, which adds 5 to `rax` and returns. After the call `rax = 15`, and the program exits.

## How I built and ran it
```bash
nasm -f elf64 03.asm -o 03.o
ld 03.o -o 03
./03          # no output, exit code 0
gdb ./03      # check rax = 15 at after_call
```

## Step by step (addresses from my gdb run)
Start: `RSP = 0x7fffffffd540`.

| Instruction | RSP | Stack top |
|---|---|---|
| `mov rax, 10` | `...d540` | (OS data) |
| `call calculate` | `...d538` (−8) | `0x40100a` = address of `after_call` |
| `add rax, 5` | `...d538` | `0x40100a` (rax = 15) |
| `ret` | `...d540` (+8) | (OS data) |
| `nop` at `after_call` | `...d540` | – |
| exit syscall | `...d540` | – |

## Explanation
- This program has **no push or pop**, but the stack is still used the whole time by `call` and `ret`.
- `call calculate` does two things: (1) push the return address (the address of the next instruction, `0x40100a`) and (2) jump to `calculate`. In gdb I saw RSP drop by 8 and `0x40100a` appear at the top of the stack.
- Inside `calculate`, `add rax, 5` only touches a register, so the stack does not change.
- `ret` pops the top of the stack into RIP. That is how the CPU knows where to go back to. RSP went up by 8 and execution continued at `after_call` (`0x40100a`).

## Observations
- The return address pushed by `call` is exactly the address gdb showed me for `after_call`.
- `rax` is 15 after the call, because the function and the caller share the registers.
- RSP is the same before the call and after the return, so nothing was leaked.
- The procedure never changed RSP itself, so `ret` found the right address. If `calculate` had pushed something without popping it, `ret` would have jumped to the wrong place.
