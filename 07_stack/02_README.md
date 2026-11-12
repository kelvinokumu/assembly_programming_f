# 02.asm — 64-bit stack frame and local variables

## Execution and stack flow

At `_start`, `call work` pushes the address of the instruction immediately after the call onto the stack (8 bytes in 64-bit mode), so `RSP` decreases by 8 before control transfers to `work`. This saved return address is what `ret` will use to resume the caller.

The function saves its caller's frame pointer with `push rbp`, decreasing `RSP` by another 8, then copies the resulting stack pointer to `RBP`. This establishes a stable frame base. `sub rsp, 16` reserves 16 bytes for two 8-byte local slots; `RSP` decreases by 16. The function stores 100 at `[rbp-8]` and 200 at `[rbp-16]`. These are local stack memory locations, so the stores do not further change `RSP`. It loads them into `RAX` and `RBX`, respectively.

`mov rsp, rbp` discards the 16-byte local area by restoring the stack pointer to the saved-frame-pointer slot. `pop rbp` restores the caller's old frame pointer and increases `RSP` by 8. `ret` removes the saved return address, increases `RSP` by 8, and resumes after `call work` with the caller's stack pointer restored. The caller exits with Linux x86-64 syscall 60 and status 0.

## Run observations

The source implies a successful exit with no output. During `work`, `RAX=100` and `RBX=200`; the local slots are discarded on return. The call's return address, saved `RBP`, and local allocation are each accounted for and the stack is balanced. This is a source-based observation, not a runtime test.
