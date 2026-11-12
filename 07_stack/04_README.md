# 04.asm — 32-bit stack frame and local variables

## Execution and stack flow

This file declares `BITS 32`, so stack values and pointers are 4 bytes. At `_start`, `call work` pushes its return address, decreasing `ESP` by 4. The called function saves the caller's frame pointer with `push ebp`, decreasing `ESP` by another 4, then sets `EBP=ESP` as a stable frame base. `sub esp, 8` reserves two 4-byte local slots and decreases `ESP` by 8.

The function writes 100 to `[ebp-4]` and 200 to `[ebp-8]`, then reads them into `EAX` and `EBX`. The memory accesses do not change `ESP`. `mov esp, ebp` releases the 8-byte local area. `pop ebp` restores the old frame pointer and raises `ESP` by 4. `ret` pops the call's saved return address, raises `ESP` by 4, and returns to the caller with the original stack position restored.

The caller exits through the Linux i386 system-call interface: `EAX=1` selects `exit`, `EBX=0` supplies status 0, and `int 0x80` enters the kernel.

## Run observations

From the source, the function reads 100 and 200 into `EAX` and `EBX`, respectively, and the process exits with status 0 without printing. The call address, saved frame pointer, and two local slots are all removed/released. This is a source-based observation; the program was not run.
