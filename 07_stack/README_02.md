# 02.asm – Stack frame with CALL, RBP and local variables (64-bit)

## What the program does
`_start` calls a procedure `work`. `work` builds a **stack frame**, stores two local variables (100 and 200) on the stack, loads them into `rax` and `rbx`, tears the frame down and returns. Then the program exits.

## How I built and ran it
```bash
nasm -f elf64 02.asm -o 02.o
ld 02.o -o 02
./02          # no output, exit code 0
gdb ./02
```

## Step by step (addresses from my gdb run)
Start: `RSP = 0x7fffffffd540`, `RBP = 0`.

| Instruction | RSP | RBP | Stack (top first) |
|---|---|---|---|
| `call work` | `...d538` (−8) | 0 | return address `0x401005` |
| `push rbp` | `...d530` (−8) | 0 | old RBP (0), return addr |
| `mov rbp, rsp` | `...d530` | `...d530` | same, RBP now marks the frame base |
| `sub rsp, 16` | `...d520` (−16) | `...d530` | 16 bytes of space reserved for locals |
| `mov qword [rbp-8], 100` | `...d520` | `...d530` | 100 stored at `...d528` |
| `mov qword [rbp-16], 200` | `...d520` | `...d530` | 200 stored at `...d520` |
| `mov rax,[rbp-8]` / `mov rbx,[rbp-16]` | same | same | rax=100, rbx=200 |
| `mov rsp, rbp` | `...d530` (+16) | `...d530` | locals are thrown away |
| `pop rbp` | `...d538` (+8) | 0 (restored) | return address on top |
| `ret` | `...d540` (+8) | 0 | back to original |

## Explanation
1. **`call work`** pushes the address of the next instruction (`0x401005`, the `mov rax, 60`) onto the stack and jumps to `work`. That is why RSP dropped by 8 even though I never wrote `push`.
2. **`push rbp`** saves the caller's RBP so I can restore it later.
3. **`mov rbp, rsp`** makes RBP a fixed reference point. RSP can move, RBP will not, so locals can always be found at `[rbp - something]`.
4. **`sub rsp, 16`** allocates space for two 8-byte locals. Subtracting is how you "allocate" because the stack grows down. Nothing is written yet (the memory was all zeros in my run).
5. The two `mov qword [...]` instructions write into that space using RBP offsets. In gdb I saw `0x64` appear at `...d528` and then `0xc8` at `...d520`. RSP does not change here, since I am not using push/pop.
6. **`mov rsp, rbp`** frees the locals in one step by moving RSP back up to the frame base.
7. **`pop rbp`** restores the caller's RBP (it went back to 0).
8. **`ret`** pops the return address into RIP, so execution continues at `0x401005` in `_start`.

## Observations
- RSP at the end (`0x7fffffffd540`) is the same as at the start, so the stack is balanced.
- If I forgot `mov rsp, rbp` or `pop rbp`, `ret` would pop the wrong value and the program would crash (jump to a bad address).
- The local variables are at **negative offsets from RBP**, and the saved RBP and return address are at **RBP+0** and **RBP+8**.
- After `ret`, the old values 100 and 200 are still sitting in memory below RSP but they are no longer part of the stack.
