# 05.asm – PUSH/POP with a 64-bit value and byte order (64-bit)

## What the program does
Loads `rax = 0x1122334455667788` and `rbx = 0x1234`, pushes both, then pops them back in reverse order into `rbx` and `rax`, then exits.

## How I built and ran it
```bash
nasm -f elf64 05.asm -o 05.o
ld 05.o -o 05
./05          # no output, exit code 0
gdb ./05
```

## Step by step (addresses from my gdb run)
Start: `RSP = 0x7fffffffd540`.

| Instruction | RSP | Stack (top first) |
|---|---|---|
| `mov rax, 0x1122334455667788` | `...d540` | – |
| `mov rbx, 0x1234` | `...d540` | – |
| `push rax` | `...d538` (−8) | `0x1122334455667788` |
| `push rbx` | `...d530` (−8) | `0x1234`, `0x1122334455667788` |
| `nop` | `...d530` | same |
| `pop rbx` | `...d538` (+8) | `0x1122334455667788` |
| `pop rax` | `...d540` (+8) | (original) |
| exit | `...d540` | – |

## Explanation
- A push always writes a full 8 bytes in 64-bit mode, so even though `0x1234` is small it is stored as `0x0000000000001234` and uses the whole 8-byte slot.
- The big value was pushed first, so it is deeper in the stack at `...d538`; `rbx` is on top at `...d530`.
- Popping in the **reverse order** (`rbx` first, then `rax`) puts every value back in its own register. This is how you save and restore registers properly.

## Observations
- `x/2gx $rsp` at the `nop` showed `0x0000000000001234 0x1122334455667788`, so the top of stack (lowest address) holds the last pushed value.
- At the end `rax = 0x1122334455667788` and `rbx = 0x1234` again, unchanged, since the push/pop order matched (the `mov rax, 60` afterwards then overwrites rax for the exit call).
- Contrast with `01.asm`: there the pop order was the same as the push order, so values got swapped between registers. Here the pop order is reversed, so nothing is swapped.
- In memory (little-endian) the bytes of `0x1122334455667788` are stored as `88 77 66 55 44 33 22 11`, lowest byte first, though gdb's `x/gx` shows it as a whole number.
