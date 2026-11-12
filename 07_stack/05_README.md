# 05.asm – pushing and restoring a 64-bit value (64-bit)

## The program
```nasm
_start:
    mov rax, 0x1122334455667788
    mov rbx, 0x1234
    push rax
    push rbx
    nop
    pop rbx
    pop rax
    mov rax, 60
    xor rdi, rdi
    syscall
```

## Build, run, debug
```bash
nasm -f elf64 05.asm -o 05.o && ld -o 05 05.o
./05 ; echo $?          # prints nothing, exit code 0
gdb ./05
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers rsp rax rbx
(gdb) x/16bx $rsp
```
Tested on x86-64 Linux, NASM 2.16.01, GNU ld 2.42, GDB 15.1. Absolute addresses vary per machine, so offsets from the starting RSP (`S0`) are shown too.

## How the stack works here
At `_start` RSP = `S0` (`0x7fffffffe9d0` in my run) and points at the `argc` value the kernel placed there. The program uses only the space below it. It saves two registers on the stack, then restores them in reverse order.

## Step by step (state after each instruction)
| # | Instruction | RSP | Stack (from RSP upward) | Registers |
|---|-------------|-----|-------------------------|-----------|
| 1 | `mov rax, 0x1122334455667788` | S0 | `argc`… | rax=0x1122334455667788 |
| 2 | `mov rbx, 0x1234` | S0 | unchanged | rbx=0x1234 |
| 3 | `push rax` | S0−8 (`…e9c8`) | `0x1122334455667788`, `argc`… | – |
| 4 | `push rbx` | S0−16 (`…e9c0`) | `0x0000000000001234`, `0x1122334455667788`, `argc`… | – |
| 5 | `nop` | S0−16 | unchanged | – |
| 6 | `pop rbx` | S0−8 | `0x1122334455667788`, `argc`… | rbx=0x1234 |
| 7 | `pop rax` | S0 | `argc`… (start state) | rax=0x1122334455667788 |
| 8–10 | `mov rax,60` / `xor rdi,rdi` / `syscall` | S0 | unchanged | exit(0) |

## How each operation works
- `push` subtracts 8 from RSP and writes the full 64-bit register at the new top. Even though `rbx` only holds `0x1234`, the push still uses a whole 8-byte slot, with the upper bytes zero.
- `pop` reads the 8 bytes at `[RSP]` into the register and adds 8 to RSP.
- Because the pops are in the **reverse** order of the pushes (`rbx` first, then `rax`), each value returns to the register it came from.

## Observations from running it
1. **Registers are restored exactly.** I pushed `rax` and `rbx` and popped `rbx` then `rax`. Both registers had the same values afterwards. This is the standard "save and restore" use of the stack, and it is the contrast with `01.asm`, where popping into different registers swapped the values.
2. **RSP stepped `S0 → S0−8 → S0−16 → S0−8 → S0`.** Each push or pop moved it exactly 8 bytes, and it finished at its starting value.
3. **Little-endian layout.** `x/16bx $rsp` after the pushes showed `34 12 00 00 00 00 00 00` (the `rbx` slot at the lower address) followed by `88 77 66 55 44 33 22 11` (the `rax` slot). The least significant byte of each value is stored first, so `0x1122334455667788` appears reversed byte by byte.
4. **The top of the stack is the last value pushed.** After the two pushes, `[RSP]` held `0x1234` and `[RSP+8]` held `0x1122334455667788`.
5. Exit code `0`.
