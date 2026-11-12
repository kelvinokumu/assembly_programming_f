# 03.asm – call and ret without a stack frame (64-bit)

## The program
```nasm
_start:
    mov rax, 10
    call calculate

after_call:
    ; RAX should now be 15
    nop
    mov rax, 60
    xor rdi, rdi
    syscall

calculate:
    add rax, 5
    ret
```

## Build, run, debug
```bash
nasm -f elf64 03.asm -o 03.o && ld -o 03 03.o
./03 ; echo $?          # prints nothing, exit code 0
gdb ./03
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers rsp rax
(gdb) x/4gx $rsp
```
Tested on x86-64 Linux, NASM 2.16.01, GNU ld 2.42, GDB 15.1. Absolute addresses vary per machine; offsets from the starting RSP (`S0`) are shown too. In my run `S0 = 0x7fffffffe9d0`.

## How the stack works here
This is the smallest possible use of the stack: the **only** thing ever stored is the return address. There is no `push`/`pop`, no `rbp` and no local variables. The argument and the result both travel in `rax`.

## Step by step (state after each instruction)
| # | Instruction | RSP | RAX | Stack top |
|---|-------------|-----|-----|-----------|
| 1 | `mov rax, 10` | S0 (`…e9d0`) | 10 | `argc` |
| 2 | `call calculate` | S0−8 (`…e9c8`) | 10 | `0x40100a` (return address) |
| 3 | `add rax, 5` | `…e9c8` | 15 | `0x40100a` |
| 4 | `ret` | S0 (`…e9d0`) | 15 | `argc` |
| 5 | `nop` at `after_call` | S0 | 15 | `argc` |
| 6–8 | `mov rax,60` / `xor rdi,rdi` / `syscall` | S0 | 60 | exit(0) |

## How `call` and `ret` use the stack
- **`call calculate`** pushes the address of the next instruction (RSP − 8, store the address), then jumps to `calculate`. The next instruction is the `after_call` label, which sits at `0x40100a` in my build.
- **`ret`** pops the 8 bytes at `[RSP]` into RIP and adds 8 to RSP, so the program continues from `after_call`.

## Observations from running it
1. **The saved value is exactly the address of `after_call`.** In gdb the stack top was `0x40100a` inside `calculate`, and after `ret` the debugger reported `0x40100a in after_call ()`.
2. **RSP is the same before `call` and after `ret`** (`…e9d0`). Between them it was 8 lower. The function leaves the stack balanced, and that balance is what makes returning work.
3. **RAX went 10 → 15.** The function did its job entirely in a register, so the stack only carried the return address.
4. **Comparison with `02.asm`:** that program also stores a saved RBP and local variables. Here none of that is needed because `calculate` doesn't need any local storage.
5. Exit code `0`.
