# 04.asm – a function with a stack frame (32-bit)

## The program
```nasm
BITS 32
_start:
    call work
    mov eax, 1          ; exit
    xor ebx, ebx
    int 0x80

work:
    push ebp
    mov ebp, esp
    sub esp, 8
    mov dword [ebp - 4], 100
    mov dword [ebp - 8], 200
    mov eax, [ebp - 4]
    mov ebx, [ebp - 8]
    nop
    mov esp, ebp
    pop ebp
    ret
```
This is the 32-bit twin of `02.asm`. It uses the same logic with `esp`/`ebp` and 4-byte slots.

## Build, run, debug
```bash
nasm -f elf32 04.asm -o 04.o && ld -m elf_i386 -o 04 04.o
./04 ; echo $?          # prints nothing, exit code 0
gdb ./04
(gdb) break _start
(gdb) run
(gdb) stepi
(gdb) info registers esp ebp eax ebx
(gdb) x/6wx $esp
```
Tested with NASM 2.16.01, GNU ld 2.42 (`-m elf_i386`) and GDB 15.1. Absolute addresses vary per machine; offsets from the starting ESP (`S0`) are shown too. In my run `S0 = 0xffffdae0`.

## How the stack works here
It stores a **return address**, the caller's **base pointer**, and two **local variables**. Every slot is 4 bytes because this is 32-bit code, so `push`, `pop`, `call` and `ret` all move ESP by 4 instead of 8.

## Step by step (state after each instruction)
| # | Instruction | ESP | EBP | What changed on the stack |
|---|-------------|-----|-----|---------------------------|
| 1 | `call work` | S0−4 (`…dadc`) | 0 | Pushes the return address `0x08049005` |
| 2 | `push ebp` | S0−8 (`…dad8`) | 0 | Saves the caller's EBP (0) |
| 3 | `mov ebp, esp` | `…dad8` | `…dad8` | No stack change; EBP marks the frame base |
| 4 | `sub esp, 8` | S0−16 (`…dad0`) | `…dad8` | Reserves 8 bytes for two locals |
| 5 | `mov dword [ebp-4], 100` | `…dad0` | `…dad8` | `0x64` written at `…dad4` |
| 6 | `mov dword [ebp-8], 200` | `…dad0` | `…dad8` | `0xc8` written at `…dad0` |
| 7 | `mov eax, [ebp-4]` | `…dad0` | `…dad8` | eax=100 |
| 8 | `mov ebx, [ebp-8]` | `…dad0` | `…dad8` | ebx=200 |
| 9 | `nop` | `…dad0` | `…dad8` | – |
| 10 | `mov esp, ebp` | S0−8 (`…dad8`) | `…dad8` | Frees the locals |
| 11 | `pop ebp` | S0−4 (`…dadc`) | 0 | Restores the caller's EBP |
| 12 | `ret` | S0 (`…dae0`) | 0 | Pops `0x08049005` into EIP |
| 13 | `mov eax,1` / `xor ebx,ebx` / `int 0x80` | S0 | 0 | exit(0) |

## Frame layout inside `work` (after step 6)
```
  S0     …dae0   argc
  S0-4   …dadc   return address 0x08049005
  S0-8   …dad8   saved EBP (0)         <- EBP points here
  EBP-4  …dad4   local #1 = 100 (0x64)
  EBP-8  …dad0   local #2 = 200 (0xc8) <- ESP points here
```

## Observations from running it
1. **Everything moves in steps of 4 bytes.** ESP went `…dae0 → …dadc → …dad8 → …dad0` (the last step is `sub esp, 8`), and came back through `…dad8` and `…dadc` to `…dae0`.
2. **Compared with `02.asm`:** the return address is 4 bytes instead of 8, and the locals are at `[ebp-4]` and `[ebp-8]` instead of `[rbp-8]` and `[rbp-16]`. The frame is half the size. The design is identical.
3. **The return address `0x08049005` is the address of `mov eax, 1` in `_start`.** `ret` popped it into EIP and gdb showed execution resuming at `_start+5`.
4. **Locals live below EBP, and writing to them doesn't change ESP.** Only `sub esp, 8` allocated the space.
5. **ESP finished at `S0`**, exactly where it started, so the stack was balanced. When `work` returned, `eax=100` and `ebx=200`; `xor ebx, ebx` then set `ebx=0`, which is the exit code (`0`).
6. The exit uses `int 0x80` with `eax = 1`, the 32-bit syscall interface, unlike the `syscall` instruction in the 64-bit programs.
