# 04.asm — 32-bit Function Stack Frame (ESP/EBP)

## Purpose
This program demonstrates the 32-bit version of a stack frame. It uses `ESP` as the stack pointer and `EBP` as the frame pointer. The source is explicitly marked `BITS 32`.

## Execution from beginning to end

1. `_start` executes `call work`. In 32-bit mode, the CPU pushes the 4-byte address of the instruction after the call onto the stack. `ESP` decreases by 4, then execution jumps to `work`.
2. `push ebp` saves the caller's frame pointer and decreases `ESP` by 4.
3. `mov ebp, esp` establishes the current stack position as the frame-pointer reference. It does not change `ESP`.
4. `sub esp, 8` reserves 8 bytes for two 4-byte local variables. `ESP` decreases by 8.
5. `mov dword [ebp - 4], 100` stores 100 in the first local slot. `mov dword [ebp - 8], 200` stores 200 in the second. These writes do not change `ESP`.
6. The program loads the local values into `EAX` and `EBX`; `nop` does nothing.
7. `mov esp, ebp` releases the 8-byte local-variable area by restoring `ESP` to the saved `EBP` slot.
8. `pop ebp` restores the caller's frame pointer and increases `ESP` by 4.
9. `ret` pops the 4-byte return address, increases `ESP` by 4, and resumes after `call work`.
10. `_start` exits using the Linux i386 system call (`EAX=1`, `EBX=0`, `int 0x80`).

## Stack pointer trace

Let the initial `ESP` before the call be `S`.

| Operation | ESP after operation |
|---|---:|
| Before call | `S` |
| `call work` | `S - 4` |
| `push ebp` | `S - 8` |
| `mov ebp, esp` | unchanged (`EBP = S - 8`) |
| `sub esp, 8` | `S - 16` |
| `mov esp, ebp` | `S - 8` |
| `pop ebp` | `S - 4` |
| `ret` | `S` |

The local variable at `[EBP-4]` is 100; `[EBP-8]` is 200. In 32-bit mode, each pushed value and return address is 4 bytes. The stack still grows toward lower memory addresses.

## Run and test observations / environment limitation

The supplied `04` executable is identified as a 32-bit Intel 80386 ELF file, but this execution environment returned `Exec format error` when asked to run it. This indicates that the current environment cannot execute that 32-bit binary; it is not evidence of an error in the assembly logic. Therefore, a successful runtime result for this source could not be confirmed here. The stack trace above is derived from the actual instructions in `04.asm`, not an invented runtime trace.

To test on a Linux system with 32-bit execution support:

```bash
nasm -f elf32 04.asm -o 04.o
ld -m elf_i386 04.o -o 04
./04
echo $?
```

Expected exit status on a compatible Linux system: `0`. If the linker or kernel lacks 32-bit support, use a 32-bit-capable Linux VM or configure the required i386 support.
