# 01.asm — Basic 64-bit PUSH and POP

## Purpose
This program demonstrates the last-in, first-out (LIFO) behavior of the x86-64 stack. It places two 64-bit register values on the stack and retrieves them in reverse order.

## Execution from beginning to end

1. `_start` begins. Linux has already established the process stack and initialized `RSP` to the current top of that stack. The exact starting address depends on the operating system and process layout, so it is not a fixed number in this source.
2. `mov rax, 100` places decimal 100 in `RAX`. `mov rbx, 200` places decimal 200 in `RBX`. These instructions do not change `RSP`.
3. `push rax` decreases `RSP` by 8 bytes, then stores the 8-byte value 100 at the new address `[RSP]`.
4. `push rbx` decreases `RSP` by another 8 bytes and stores 200 at the new top. The top item is now 200, above the earlier 100.
5. `nop` does nothing and does not change the stack.
6. `pop rcx` reads the top value (200) into `RCX`, then increases `RSP` by 8 bytes. `RCX` receives 200.
7. `pop rdx` reads the next value (100) into `RDX`, then increases `RSP` by 8 bytes. `RDX` receives 100.
8. The second `nop` has no effect on the stack.
9. The program invokes Linux's 64-bit exit syscall (`RAX=60`, status `RDI=0`). The process terminates.

## Stack and register changes

Let the initial stack pointer be `S`.

| Instruction | RSP after instruction | Value at top / effect |
|---|---:|---|
| Start | `S` | Existing process stack |
| `push rax` | `S - 8` | 100 |
| `push rbx` | `S - 16` | 200 (top), then 100 |
| `pop rcx` | `S - 8` | `RCX=200` |
| `pop rdx` | `S` | `RDX=100` |

The stack grows toward lower memory addresses. A 64-bit `PUSH` or `POP` changes `RSP` by 8 bytes. The two pops reverse the two pushes: the most recently pushed value (200) is removed first.

## Run and test observations

The supplied prebuilt `01` executable was run successfully in the x86-64 environment. It exited with status code **0** and produced no terminal output. This is expected: the program performs register and stack operations but contains no print instruction or output syscall.

The values can be checked while stepping in a debugger: after the pushes, inspect `x/gx $rsp` (top should be 200) and the next 8-byte slot (100); after the pops, inspect `rcx` and `rdx`.

## Build and run

From `07_stack` on a system with NASM and GNU `ld`:

```bash
nasm -f elf64 01.asm -o 01.o
ld 01.o -o 01
./01
echo $?
```

Expected exit status: `0`.
