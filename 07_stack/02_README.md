# 02.asm – a function with a stack frame and local variables (64-bit)

## The program
```nasm
_start:
    call work
    mov rax, 60
    xor rdi, rdi
    syscall

work:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp - 8], 100
    mov qword [rbp - 16], 200
    mov rax, [rbp - 8]
    mov rbx, [rbp - 16]
    nop
    mov rsp, rbp
    pop rbp
    ret
```

## Build, run, debug
```bash
nasm -f elf64 02.asm -o 02.o && ld -o 02 02.o
./02 ; echo $?          # prints nothing, exit code 0
gdb ./02
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers rsp rbp rax rbx
(gdb) x/6gx $rsp
```
Tested on x86-64 Linux, NASM 2.16.01, GNU ld 2.42, GDB 15.1. Absolute addresses vary per machine; offsets from the starting RSP (`S0`) are shown too. In my run `S0 = 0x7fffffffe9d0`.

## How the stack works here
This program uses the stack in three ways: to hold a **return address** (`call`/`ret`), to save the caller's **base pointer** (`push rbp`/`pop rbp`), and to reserve space for **local variables** (`sub rsp, 16`). Together these form a *stack frame*.

## Step by step (state after each instruction)
| # | Instruction | RSP | RBP | What changed on the stack |
|---|-------------|-----|-----|---------------------------|
| 1 | `call work` | S0−8 (`…e9c8`) | 0 | Pushes the return address `0x401005` (the instruction after the call) |
| 2 | `push rbp` | S0−16 (`…e9c0`) | 0 | Saves the caller's RBP (value 0) |
| 3 | `mov rbp, rsp` | S0−16 | S0−16 (`…e9c0`) | No stack change. RBP now marks the frame base |
| 4 | `sub rsp, 16` | S0−32 (`…e9b0`) | `…e9c0` | Reserves 16 bytes for two locals (contents still 0) |
| 5 | `mov qword [rbp-8], 100` | `…e9b0` | `…e9c0` | `0x64` written at `…e9b8` |
| 6 | `mov qword [rbp-16], 200` | `…e9b0` | `…e9c0` | `0xc8` written at `…e9b0` |
| 7 | `mov rax, [rbp-8]` | `…e9b0` | `…e9c0` | Reads local → rax=100 |
| 8 | `mov rbx, [rbp-16]` | `…e9b0` | `…e9c0` | Reads local → rbx=200 |
| 9 | `nop` | `…e9b0` | `…e9c0` | – |
| 10 | `mov rsp, rbp` | S0−16 (`…e9c0`) | `…e9c0` | Discards the locals by moving RSP back to the frame base |
| 11 | `pop rbp` | S0−8 (`…e9c8`) | 0 | Restores the caller's RBP |
| 12 | `ret` | S0 (`…e9d0`) | 0 | Pops `0x401005` into RIP, so execution resumes after the `call` |
| 13 | `mov rax,60` / `xor rdi,rdi` / `syscall` | S0 | 0 | exit(0) |

## Frame layout inside `work` (after step 6)
```
higher addresses
  S0      …e9d0   argc (not part of the function's frame)
  S0-8    …e9c8   return address 0x401005
  S0-16   …e9c0   saved RBP (0)        <- RBP points here
  RBP-8   …e9b8   local #1 = 100 (0x64)
  RBP-16  …e9b0   local #2 = 200 (0xc8) <- RSP points here
lower addresses
```

## Observations from running it
1. **`call` is a push plus a jump.** RSP dropped by 8 and the stack top became `0x401005`, which is the address of `mov rax, 60` back in `_start`. `ret` popped that exact value into RIP, and the gdb trace shows the next instruction was `_start+5`.
2. **Locals are addressed relative to RBP, not RSP.** Writing to `[rbp-8]` and `[rbp-16]` never changed RSP. Only `sub rsp, 16` allocated the space. That is why the frame stays easy to address even if RSP moves later.
3. **Allocation is just subtraction.** `sub rsp, 16` moved RSP from `…e9c0` to `…e9b0`, and the newly reserved slots held 0 until the program wrote to them.
4. **The epilogue undoes the prologue in reverse.** `mov rsp, rbp` frees the locals, `pop rbp` restores the caller's RBP (back to 0 in the trace), and `ret` removes the return address. RSP finished at `S0`, the same value it had before `call`.
5. The function's work is visible in the registers: `rax = 100` and `rbx = 200` were loaded from the stack. Exit code `0`.
