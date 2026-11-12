# 01.asm – push and pop with two registers (64-bit)

## The program
```nasm
_start:
    mov rax, 100
    mov rbx, 200
    push rax
    push rbx
    nop
    pop rcx
    pop rdx
    nop
    mov rax, 60
    xor rdi, rdi
    syscall
```

## Build, run, debug
```bash
nasm -f elf64 01.asm -o 01.o && ld -o 01 01.o
./01 ; echo $?          # prints nothing, exit code 0
gdb ./01
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers rsp rax rbx rcx rdx
(gdb) x/4gx $rsp
```
Tested on x86-64 Linux with NASM 2.16.01, GNU ld 2.42 and GDB 15.1. Absolute stack addresses differ from machine to machine (they depend on the environment), so the table also shows each RSP as an offset from the starting value `S0`. The offsets are always the same.

## How the stack works here
The kernel creates the stack before `_start` runs. At the first instruction RSP already points at valid data: the top qword is `1` (`argc`), followed by the `argv` and environment pointers. In my run `S0 = 0x7fffffffe9d0`, which is 16-byte aligned. The program never touches that data. It only uses the space **below** `S0`, because the x86-64 stack grows toward lower addresses.

## Step by step (state after each instruction)
| # | Instruction | RSP | Stack content (from RSP upward) | Registers |
|---|-------------|-----|---------------------------------|-----------|
| 1 | `mov rax, 100` | S0 (`…e9d0`) | `argc` … (untouched) | rax=100 |
| 2 | `mov rbx, 200` | S0 | unchanged | rbx=200 |
| 3 | `push rax` | S0−8 (`…e9c8`) | `0x64`, then `argc`… | rax=100 |
| 4 | `push rbx` | S0−16 (`…e9c0`) | `0xc8`, `0x64`, then `argc`… | rbx=200 |
| 5 | `nop` | S0−16 | unchanged | – |
| 6 | `pop rcx` | S0−8 (`…e9c8`) | `0x64`, then `argc`… | rcx=200 |
| 7 | `pop rdx` | S0 (`…e9d0`) | `argc`… (back to start) | rdx=100 |
| 8 | `nop` | S0 | unchanged | – |
| 9–11 | `mov rax,60` / `xor rdi,rdi` / `syscall` | S0 | unchanged | exit(0) |

## How each operation works
- **`push rax`** does two things: RSP = RSP − 8, then it stores the 8-byte value at the new `[RSP]`. After the two pushes the stack holds `200` on top of `100`.
- **`pop rcx`** does the reverse: it loads the 8 bytes at `[RSP]` into the register, then RSP = RSP + 8.
- The stack is **LIFO** (last in, first out). `200` was pushed last, so it comes off first.

## Observations from running it
1. **The values swap registers.** I pushed `rax`(100) then `rbx`(200) but popped into `rcx` then `rdx`. The result was `rcx = 200` and `rdx = 100`: the reverse order of the pushes.
2. **RSP moves 8 bytes per operation** on a 64-bit machine: `…e9d0 → …e9c8 → …e9c0` going down, and back up the same way. It ends at exactly the value it started with. A balanced number of pushes and pops leaves the stack as it was.
3. **Little-endian storage.** `x/16bx $rsp` after the pushes showed `c8 00 00 00 00 00 00 00` followed by `64 00 00 00 00 00 00 00`. The low byte sits at the lowest address, and the 8-byte slot is padded with zeros.
4. **`pop` does not erase memory.** After both pops, `x/2gx $rsp-16` still showed `0xc8` and `0x64` in the old slots. The pop only moved RSP; the bytes stay until something overwrites them. Anything below RSP is simply considered free.
5. The program exits with code `0` (`echo $?`).
