# 06.asm — 32-bit values and LIFO order

## Execution and stack flow

`BITS 32` selects 32-bit instructions and 4-byte stack slots. At `_start`, `EAX` is loaded with `0x11223344` and `EBX` with `0x1234`. `push eax` stores the first value and decreases `ESP` by 4. `push ebx` stores the second value on top and decreases `ESP` by 4 again. `ESP` is now `ESP₀-8`, and the top item is `0x1234`.

`pop ebx` retrieves the most recently pushed value (`0x1234`) and increases `ESP` by 4. `pop eax` retrieves `0x11223344` and increases `ESP` by 4, restoring `ESP₀`. `nop` does not change machine state. Finally, `EAX=1` selects Linux i386 `exit`, `EBX=0` provides the successful status, and `int 0x80` performs the system call.

## Run observations

The source implies no printed output and a successful exit with status 0. Both pops reverse the push order and balance the two 4-byte stack allocations. This is an observation from reading the instructions; the program was not run.
