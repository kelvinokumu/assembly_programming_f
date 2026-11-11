# 06.asm – PUSH/POP in 32-bit mode

## What the program does
32-bit version of `05.asm`. Loads `eax = 0x11223344`, `ebx = 0x1234`, pushes both, pops them back in reverse order, and exits with `int 0x80`.

## How I built and ran it
```bash
nasm -f elf32 06.asm -o 06.o
ld -m elf_i386 06.o -o 06
./06          # no output, exit code 0
gdb ./06
```

## Step by step (addresses from my gdb run)
Start: `ESP = 0xffffc6f0`.

| Instruction | ESP | Stack (top first) |
|---|---|---|
| `mov eax, 0x11223344` | `...c6f0` | – |
| `mov ebx, 0x1234` | `...c6f0` | – |
| `push eax` | `...c6ec` (−4) | `0x11223344` |
| `push ebx` | `...c6e8` (−4) | `0x00001234`, `0x11223344` |
| `nop` | `...c6e8` | same |
| `pop ebx` | `...c6ec` (+4) | `0x11223344` |
| `pop eax` | `...c6f0` (+4) | (original) |
| `mov eax,1` / `xor ebx,ebx` / `int 0x80` | `...c6f0` | exit(0) |

## Explanation
- In 32-bit mode each push/pop moves **4 bytes**, so ESP changes by 4 each time (compare 8 in `05.asm`).
- `eax` was pushed first, so it sits deeper (`...c6ec`); `ebx` is on top (`...c6e8`).
- Popping `ebx` first and then `eax` is the reverse of the push order (LIFO), so each register gets back its own value.

## Observations
- At the `nop`, gdb's `x/4wx $esp` showed `0x00001234 0x11223344 ...`, matching the push order.
- ESP returned to `0xffffc6f0`, the starting value, so it is balanced.
- The stack addresses are 4 apart here, and 8 apart in the 64-bit programs. That is the main difference between the two modes.
- The program finishes with exit code 0 and prints nothing, since it only moves data around.
