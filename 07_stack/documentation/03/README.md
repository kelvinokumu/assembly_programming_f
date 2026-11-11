# 03.asm — CALL and RET with a Register Result (64-bit)

## Purpose
This program demonstrates the stack's role in a function call. It uses the stack to preserve the return address, while the calculation result is returned in `RAX`, not on the stack.

## Execution from beginning to end

1. `_start` begins and executes `mov rax, 10`. `RAX` now contains 10. `RSP` is unchanged.
2. `call calculate` pushes the address labelled `after_call` onto the stack. In 64-bit mode the return address occupies 8 bytes, so `RSP` decreases by 8. Execution jumps to `calculate`.
3. `add rax, 5` changes `RAX` from 10 to 15. This arithmetic instruction does not push or pop anything and does not change `RSP`.
4. `ret` pops the saved return address from the top of the stack, increases `RSP` by 8, and resumes execution at `after_call`.
5. At `after_call`, `RAX` contains 15, as the source comment states. `nop` does nothing.
6. The program then loads 60 into `RAX` for the Linux exit syscall and 0 into `RDI` for the exit status. This overwrites the calculation result because it is no longer needed.
7. `syscall` terminates the process with status 0.

## Stack pointer trace

Let the initial `RSP` be `S`.

| Operation | RSP after operation | Stack effect |
|---|---:|---|
| Before `call` | `S` | No change |
| `call calculate` | `S - 8` | Saves address `after_call` |
| `add rax, 5` | `S - 8` | No stack change |
| `ret` | `S` | Removes return address |

There is no explicit `push` or `pop` in the function body. `CALL` and `RET` perform the equivalent return-address push and pop automatically. The computed value 15 is passed back in `RAX`, following the common x86-64 convention for integer return values.

## Run and test observations

The supplied prebuilt `03` executable ran successfully and exited with status code **0**. It printed nothing, which is expected because it has no output instructions. The final process exit code is not the calculation result: the program deliberately sets the exit status to zero. To verify the calculation, inspect `RAX` at `after_call`, before it is overwritten with 60 for the exit syscall; it should equal 15.

## Build and run

```bash
nasm -f elf64 03.asm -o 03.o
ld 03.o -o 03
./03
echo $?
```

Expected exit status: `0`.
