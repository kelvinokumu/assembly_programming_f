# 04.asm – Stack frame in 32-bit mode (EBP / ESP)

## What the program does
Same idea as `02.asm` but written for **32-bit** (`BITS 32`). `_start` calls `work`, which makes a frame, stores 100 and 200 in two local 4-byte variables, loads them into `eax` and `ebx`, removes the frame and returns. Exit is done with `int 0x80` (the 32-bit Linux way).

## How I built and ran it
32-bit needs different flags:
```bash
nasm -f elf32 04.asm -o 04.o
ld -m elf_i386 04.o -o 04
./04          # no output, exit code 0
gdb ./04
```

## What is different from 64-bit
- Registers are `ESP`, `EBP`, `EAX`, `EBX` (32 bits).
- Every push/pop and every return address is **4 bytes**, not 8. So `call` and `push` change ESP by 4.
- Locals are `dword` (4 bytes): `[ebp-4]` and `[ebp-8]`.

## Step by step (addresses from my gdb run)
Start: `ESP = 0xffffc6f0`, `EBP = 0`.

| Instruction | ESP | EBP | Stack (top first) |
|---|---|---|---|
| `call work` | `...c6ec` (−4) | 0 | return address `0x08049005` |
| `push ebp` | `...c6e8` (−4) | 0 | old EBP (0), return addr |
| `mov ebp, esp` | `...c6e8` | `...c6e8` | frame base set |
| `sub esp, 8` | `...c6e0` (−8) | `...c6e8` | 8 bytes reserved for 2 locals |
| `mov dword [ebp-4], 100` | `...c6e0` | `...c6e8` | 100 at `...c6e4` |
| `mov dword [ebp-8], 200` | `...c6e0` | `...c6e8` | 200 at `...c6e0` |
| `mov eax,[ebp-4]` / `mov ebx,[ebp-8]` | same | same | eax=100, ebx=200 |
| `mov esp, ebp` | `...c6e8` (+8) | `...c6e8` | locals released |
| `pop ebp` | `...c6ec` (+4) | 0 | EBP restored |
| `ret` | `...c6f0` (+4) | 0 | back to original |

## Observations
- In gdb the memory at `ESP` showed `0x000000c8 0x00000064` (200 then 100) after the stores. 200 is at the lower address because it has the bigger negative offset.
- ESP went from `0xffffc6f0` and returned to `0xffffc6f0`, balanced.
- `ret` popped `0x08049005`, which is the `mov eax, 1` after the call in `_start`.
- Compared with `02.asm`, the logic is identical. Only the size of each stack slot changed (4 vs 8 bytes), and the exit uses `int 0x80` with `eax = 1` instead of `syscall` with `rax = 60`.
