# 01.asm – Basic PUSH and POP (64-bit)

## What the program does
Puts 100 in `rax` and 200 in `rbx`, pushes both onto the stack, then pops them back into `rcx` and `rdx`, and exits.

## How I built and ran it
```bash
nasm -f elf64 01.asm -o 01.o
ld 01.o -o 01
./01          # no output, exits with code 0
gdb ./01      # used to watch RSP and the stack
```

## Key idea
The stack **grows downward** (toward smaller addresses). `push` first subtracts 8 from RSP, then writes the value at the new RSP. `pop` reads the value at RSP, then adds 8 to RSP. RSP always points at the *top* (last pushed) item.

## Step by step (addresses are from my gdb run)

| Instruction | RSP after it | What is on the stack (top first) |
|---|---|---|
| (start of `_start`) | `0x7fffffffd540` | OS data (argc = 1, etc.) |
| `mov rax, 100` | unchanged | – |
| `mov rbx, 200` | unchanged | – |
| `push rax` | `0x...d538` (−8) | 100 |
| `push rbx` | `0x...d530` (−8) | 200, 100 |
| `nop` | `0x...d530` | 200, 100 |
| `pop rcx` | `0x...d538` (+8) | 100 |
| `pop rdx` | `0x...d540` (+8) | (back to original) |
| `mov rax, 60` / `xor rdi, rdi` / `syscall` | `0x...d540` | exit(0) |

1. When the program starts RSP is at `0x7fffffffd540`. The Linux loader already put `argc`, `argv` etc. there, so I must not pop more than I push.
2. `push rax` puts 100 (`0x64`) at `0x...d538`. RSP went down by 8 because a register is 8 bytes (64 bits).
3. `push rbx` puts 200 (`0xc8`) at `0x...d530`. Now 200 is on top and 100 is under it.
4. `pop rcx` takes the **top** value, so `rcx = 200`, not 100. RSP goes up by 8.
5. `pop rdx` takes the next one, so `rdx = 100`.
6. RSP is back at `0x7fffffffd540`, so the push/pop count is balanced.

## Observations
- Final registers: `rax=100`, `rbx=200`, `rcx=200`, `rdx=100` (I checked with `info registers` at the second `nop`).
- The values come out **swapped** compared to the order they went in. This is LIFO (Last In, First Out): the last one pushed (`rbx`) is the first one popped (`rcx`).
- `pop` does not erase the memory. The values 100 and 200 are still physically there below RSP, but they are now free space that the next push will overwrite.
- 2 pushes (−16 bytes) and 2 pops (+16 bytes) cancel out.
