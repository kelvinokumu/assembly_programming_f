# 06.asm – pushing and restoring registers (32-bit)

## The program
```nasm
BITS 32
_start:
    mov eax, 0x11223344
    mov ebx, 0x1234
    push eax
    push ebx
    nop
    pop ebx
    pop eax
    mov eax, 1
    xor ebx, ebx
    int 0x80
```
This is the 32-bit twin of `05.asm`.

## Build, run, debug
```bash
nasm -f elf32 06.asm -o 06.o && ld -m elf_i386 -o 06 06.o
./06 ; echo $?          # prints nothing, exit code 0
gdb ./06
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers esp eax ebx
(gdb) x/8bx $esp
```
Tested with NASM 2.16.01, GNU ld 2.42 (`-m elf_i386`) and GDB 15.1. Absolute addresses vary per machine; offsets from the starting ESP (`S0`) are shown too. In my run `S0 = 0xffffdae0`.

## How the stack works here
The program saves two 32-bit registers on the stack and restores them in reverse order. At `_start` ESP = `S0`, pointing at the `argc` value left by the kernel. The program only uses the space below it. Each push and pop moves ESP by **4 bytes**.

## Step by step (state after each instruction)
| # | Instruction | ESP | Stack (from ESP upward) | Registers |
|---|-------------|-----|-------------------------|-----------|
| 1 | `mov eax, 0x11223344` | S0 (`…dae0`) | `argc`… | eax=0x11223344 |
| 2 | `mov ebx, 0x1234` | S0 | unchanged | ebx=0x1234 |
| 3 | `push eax` | S0−4 (`…dadc`) | `0x11223344`, `argc`… | – |
| 4 | `push ebx` | S0−8 (`…dad8`) | `0x00001234`, `0x11223344`, `argc`… | – |
| 5 | `nop` | S0−8 | unchanged | – |
| 6 | `pop ebx` | S0−4 | `0x11223344`, `argc`… | ebx=0x1234 |
| 7 | `pop eax` | S0 | `argc`… (start state) | eax=0x11223344 |
| 8–10 | `mov eax,1` / `xor ebx,ebx` / `int 0x80` | S0 | unchanged | exit(0) |

## How each operation works
- **`push eax`**: ESP = ESP − 4, then the 4-byte value is stored at `[ESP]`.
- **`pop ebx`**: load the 4 bytes at `[ESP]` into `ebx`, then ESP = ESP + 4.
- Popping in the **reverse** order (`ebx` then `eax`) puts each value back in the register it came from. That is LIFO behaviour.

## Observations from running it
1. **ESP stepped `S0 → S0−4 → S0−8 → S0−4 → S0`.** Each operation moved it exactly 4 bytes, and it finished where it began. Compare with `05.asm`, where each step is 8 bytes.
2. **The registers are restored exactly.** `eax` and `ebx` held `0x11223344` and `0x1234` before the pushes and after the pops. The `nop` between them is just a convenient place to pause and inspect the stack.
3. **Little-endian layout.** `x/8bx $esp` after both pushes showed `34 12 00 00` (the `ebx` slot at the lower address) followed by `44 33 22 11` (the `eax` slot). Each value is stored least significant byte first.
4. **The last value pushed is at the top.** `[ESP]` held `0x1234` and `[ESP+4]` held `0x11223344`.
5. Execution ends with `eax=1`, `ebx=0` and the `int 0x80` exit syscall. The exit code is `0`.
