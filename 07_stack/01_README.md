# 01.asm — Basic 64-bit push and pop

## Execution and stack flow

Execution begins at `_start`. `RAX` is set to 100 and `RBX` to 200. In 64-bit mode each `push` stores an 8-byte value at the new top of the stack and decreases `RSP` by 8. After `push rax`, `RSP = RSP₀ - 8`; after `push rbx`, `RSP = RSP₀ - 16`. The top item is now 200.

The stack is last-in, first-out. `pop rcx` copies 200 into `RCX` and increases `RSP` by 8. `pop rdx` copies 100 into `RDX` and restores `RSP` to `RSP₀`. Both `nop` instructions do nothing and do not affect the stack. The program then places Linux x86-64 syscall number 60 in `RAX`, status 0 in `RDI`, and executes `syscall` to exit.

## Run observations

From the instructions, it exits successfully with status 0 and produces no output. At exit, `RCX=200`, `RDX=100`, and the two pushes have been balanced by two pops. This result is inferred from the source; the program was not run for this assignment.
