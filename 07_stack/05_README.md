# 05.asm — 64-bit values and LIFO order

## Execution and stack flow

At `_start`, `RAX` receives `0x1122334455667788` and `RBX` receives `0x1234`. `push rax` places the 8-byte value from `RAX` on the stack and decreases `RSP` by 8. `push rbx` places `0x1234` above it and decreases `RSP` by another 8. The top of the stack is therefore `0x1234`.

The pops intentionally reverse the register order: `pop rbx` retrieves `0x1234` and adds 8 to `RSP`; `pop rax` retrieves `0x1122334455667788` and adds another 8, restoring the original stack pointer. `nop` has no effect. The code then overwrites `RAX` with syscall number 60, sets `RDI` to exit status 0, and uses `syscall` to terminate under Linux x86-64.

## Run observations

The program prints nothing and exits successfully according to its instructions. The two values return to their original registers before `RAX` is repurposed for the exit syscall. The LIFO order is visible in the matching `push rax`, `push rbx`, `pop rbx`, `pop rax` sequence. No runtime test was performed.
