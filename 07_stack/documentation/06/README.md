# 06.asm — 32-bit PUSH/POP with Different Values (ESP)

## Purpose
The source file explicitly declares `BITS 32` and demonstrates 32-bit stack operations. It pushes two 32-bit register values and pops them in reverse order.

## Execution from beginning to end

1. `_start` loads `0x11223344` into `EAX` and `0x1234` into `EBX`. `ESP` is unchanged.
2. `push eax` decreases `ESP` by 4 bytes and stores `0x11223344` at the new top of the stack.
3. `push ebx` decreases `ESP` by another 4 bytes and stores `0x1234` at the new top.
4. `nop` does nothing.
5. `pop ebx` reads the top value (`0x1234`) into `EBX` and increases `ESP` by 4.
6. `pop eax` reads the next value (`0x11223344`) into `EAX` and increases `ESP` by another 4.
7. The program exits using the Linux i386 exit syscall (`EAX=1`, `EBX=0`, `int 0x80`). The exit setup overwrites the earlier values in `EAX` and `EBX`, after the demonstration has completed.

## Stack pointer trace

Let the initial `ESP` be `S`.

| Operation | ESP after operation | Value retrieved/stored |
|---|---:|---|
| Before pushes | `S` | — |
| `push eax` | `S - 4` | Stores `0x11223344` |
| `push ebx` | `S - 8` | Stores `0x1234` at top |
| `pop ebx` | `S - 4` | `EBX = 0x1234` |
| `pop eax` | `S` | `EAX = 0x11223344` |

The stack grows toward lower addresses. In 32-bit mode, a register push/pop uses 4 bytes. The two pops restore `ESP` to its initial value and restore the original values to the registers before the exit instructions run.

## Run and test observations / important supplied-file mismatch

The source `06.asm` is 32-bit (`BITS 32`), but the prebuilt file named `06` in the supplied archive is identified as a **64-bit x86-64 executable**. It is therefore not a valid build artifact for this source. When run, that supplied executable terminated with signal 11 (segmentation fault). That result must not be reported as a successful test of `06.asm`; it tests a mismatched prebuilt binary.

A fresh build and test requires assembling the source as 32-bit:

```bash
nasm -f elf32 06.asm -o 06.o
ld -m elf_i386 06.o -o 06
./06
echo $?
```

Expected exit status for a correct run on a Linux system with 32-bit execution support: `0`. The current environment could not confirm that runtime result. Use a 32-bit-capable Linux VM if the host cannot execute i386 programs.
