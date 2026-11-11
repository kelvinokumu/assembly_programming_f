# 02.asm — Function Stack Frame (64-bit)

## Purpose
This program demonstrates how a function uses the stack for its return address, saved frame pointer, and local variables.

## Execution from beginning to end

1. `_start` executes `call work`. The CPU first pushes the address of the instruction immediately after the `call` onto the stack (an 8-byte return address in 64-bit mode), decreasing `RSP` by 8. Execution then jumps to `work`.
2. `push rbp` saves the caller's frame pointer on the stack and decreases `RSP` by another 8 bytes.
3. `mov rbp, rsp` establishes the current stack position as this function's frame-pointer reference. `RBP` itself is not a stack pointer and this move does not change `RSP`.
4. `sub rsp, 16` reserves 16 bytes for two 8-byte local variables. `RSP` decreases by 16. The reserved memory is not automatically initialized by `sub`.
5. `mov qword [rbp - 8], 100` writes 100 into the first local-variable slot. `mov qword [rbp - 16], 200` writes 200 into the second slot. These memory writes do not change `RSP`.
6. The two `mov` instructions load those local values into `RAX` and `RBX`. They do not change the stack pointer. `nop` has no effect.
7. `mov rsp, rbp` discards the 16-byte local-variable area by restoring `RSP` to the saved-frame-pointer slot. The local values are no longer part of the active stack frame.
8. `pop rbp` restores the caller's old `RBP` and increases `RSP` by 8.
9. `ret` takes the saved return address from the top of the stack, transfers execution back to the instruction after `call work`, and increases `RSP` by 8.
10. Back in `_start`, the program invokes the 64-bit Linux exit syscall with status 0.

## Stack pointer trace

Let `S` be `RSP` just before `call work`.

| Operation | RSP after operation |
|---|---:|
| Before call | `S` |
| `call work` (return address pushed) | `S - 8` |
| `push rbp` | `S - 16` |
| `mov rbp, rsp` | unchanged (`RBP = S - 16`) |
| `sub rsp, 16` | `S - 32` |
| `mov rsp, rbp` | `S - 16` |
| `pop rbp` | `S - 8` |
| `ret` (return address popped) | `S` |

The local variables are addressed relative to `RBP`: `[RBP-8]` contains 100 and `[RBP-16]` contains 200. The return address and saved `RBP` are above the local-variable area at higher addresses. The function restores the stack before returning, so the caller resumes with its original `RSP`.

## Run and test observations

The supplied prebuilt `02` executable ran successfully and exited with status code **0**, with no terminal output. No output is expected because this program only manipulates the stack and registers; it does not print the local values.

When debugging, stop inside `work` after `sub rsp,16`: inspect `RBP`, `RSP`, and memory at `$rbp-8` and `$rbp-16`. The values should be 100 and 200. After `ret`, `RSP` should be back to its value before the call.

## Build and run

```bash
nasm -f elf64 02.asm -o 02.o
ld 02.o -o 02
./02
echo $?
```

Expected exit status: `0`.
