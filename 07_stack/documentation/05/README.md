# 05.asm — 64-bit PUSH/POP with Different Values

## Purpose
This program demonstrates that the stack is LIFO and that `PUSH` and `POP` transfer full 64-bit values between registers and stack memory.

## Execution from beginning to end

1. `_start` loads `0x1122334455667788` into `RAX` and `0x1234` into `RBX`. Neither instruction changes `RSP`.
2. `push rax` decreases `RSP` by 8 and stores the 64-bit value `0x1122334455667788` at the new top of the stack.
3. `push rbx` decreases `RSP` by another 8 and stores `0x1234` at the new top. This second value is now on top of the first.
4. `nop` has no effect.
5. `pop rbx` retrieves the top value (`0x1234`) into `RBX` and increases `RSP` by 8.
6. `pop rax` retrieves the next value (`0x1122334455667788`) into `RAX` and increases `RSP` by another 8.
7. The program sets up and invokes the 64-bit Linux exit syscall with status 0.

## Stack pointer trace

Let the initial stack pointer be `S`.

| Operation | RSP after operation | Value retrieved/stored |
|---|---:|---|
| Before pushes | `S` | — |
| `push rax` | `S - 8` | Stores `0x1122334455667788` |
| `push rbx` | `S - 16` | Stores `0x1234` at top |
| `pop rbx` | `S - 8` | `RBX = 0x1234` |
| `pop rax` | `S` | `RAX = 0x1122334455667788` |

The pop order must be the reverse of the push order. This program restores both original register values. Each push/pop uses 8 bytes in 64-bit mode, and `RSP` returns to its original value after the two pops.

## Run and test observations

The supplied prebuilt `05` executable ran successfully in the x86-64 environment and exited with status code **0**. It produced no output, which is expected because it does not print the values. The values are verified by following the push/pop order in the instructions or inspecting `RBX` and `RAX` immediately after the pops.

## Build and run

```bash
nasm -f elf64 05.asm -o 05.o
ld 05.o -o 05
./05
echo $?
```

Expected exit status: `0`.
