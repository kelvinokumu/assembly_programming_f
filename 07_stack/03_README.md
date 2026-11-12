# 03.asm — Call and return without a stack frame

## Execution and stack flow

At `_start`, `RAX` is set to 10. `call calculate` pushes the address of `after_call` onto the stack and decreases `RSP` by 8, then transfers control to `calculate`. The function adds 5 to `RAX`, making it 15. It does not allocate local variables or save registers, so it performs no explicit push or pop.

`ret` pops the saved return address into the instruction pointer and increases `RSP` by 8, returning to `after_call` with the original stack pointer restored. `RAX` retains 15 because it is the function's return-value register by convention and this function leaves it unchanged after the addition. The `nop` does nothing. The caller then invokes Linux x86-64 syscall 60 with status 0 in `RDI` and exits.

## Run observations

The comment in the program correctly predicts `RAX=15` after the call. The program prints nothing and exits successfully; the single return address pushed by `call` is removed by `ret`. These observations are determined from the instructions; no runtime test was performed.
