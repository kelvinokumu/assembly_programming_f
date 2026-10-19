# RFLAGS Tests (x86-64 Linux)

## Build and Run

From this directory, with NASM and GNU binutils installed:

```bash
nasm -f elf64 -g -F dwarf flags.asm -o flags.o
ld -m elf_x86_64 flags.o -o flags
./flags
echo $?
```

The debug information enables the GDB examples below. A normal run prints 14
result lines and exits with status `0`. Failed flag or copy checks print `[FAIL]`
and exit with status `1`. IF and TF are observations, not fixed-value assertions.

## Flags Covered

| Flag | Bit | Demonstration |
| --- | --- | --- |
| CF: Carry | 0 | Unsigned subtraction borrows; `CLC`, `STC`, and `CMC` clear, set, and toggle CF. |
| PF: Parity | 2 | Even and odd parity of the low byte. `0x0103` has PF=1 despite having three set bits across the whole word. |
| AF: Auxiliary Carry | 4 | `0x0F + 1` carries from bit 3 to bit 4; `0x10 + 1` does not. |
| ZF: Zero | 6 | Testing zero sets ZF; `1 + 1` clears it. |
| SF: Sign | 7 | An 8-bit `0 - 1` sets SF; testing positive `1` clears it. |
| TF: Trap | 8 | Observe the single-step flag; use GDB for the active test below. |
| IF: Interrupt Enable | 9 | Observe whether maskable interrupts are enabled. |
| DF: Direction | 10 | `CLD` and `STD` select forward and backward string traversal. |
| OF: Overflow | 11 | Signed 8-bit `127 + 1` overflows; `1 + 1` does not. |

Additional scenarios compare unsigned and signed branches using the same flags:
after `CMP AL, 1` with `AL=0xFF`, both `JA` (unsigned 255 > 1) and `JL` (signed
-1 < 1) are true. Another scenario verifies that `INC` preserves CF, even when
`0xFF` wraps to zero.

Flags are checked before printing. For flags without a dedicated conditional
jump, `PUSHFQ` / `POP R8` captures RFLAGS, then `BT` copies the selected saved bit
into CF for `JC` or `JNC` to test. `BT` itself changes CF, so test the saved value,
not the live flags after other instructions have changed them.

## Control Flag Safety

- **DF:** Both `REP MOVSB` tests verify the resulting buffer and that RCX reaches
  zero. The backward test starts both pointers at their last bytes, so the
  destination still contains `ABCD`, not `DCBA`. It verifies DF=1 during the copy
  and restores and checks DF=0 before printing. Failure paths also run `CLD`.
- **IF:** Normally set in an ordinary Linux process. This program reads it but
  does not execute `CLI` or `STI`: these instructions fault in ordinary user mode.
  Running the executable with `sudo` does not make it kernel-mode code.
- **TF:** Setting it causes a single-step debug exception after the following
  instruction. Linux delivers `SIGTRAP`; without a debugger or signal handler,
  the program normally terminates. The normal run therefore only reads TF.

Other system flags, including IOPL, NT, VM, VIF/VIP, and AC, are intentionally not
modified here. Their behavior depends on privilege and execution mode, and
enabling AC can cause alignment faults.

## Test TF with GDB

Start GDB after building with the debug options above:

```bash
gdb ./flags
```

Then enter:

```gdb
break trap_flag_demo
run
x/3i $pc
stepi
stepi
info registers eflags
continue
```

`trap_flag_demo` contains two `NOP` instructions followed by `RET`. Each `stepi`
executes one instruction using debugger-managed single stepping. GDB handles the
debug exceptions so the program can continue normally. Linux/GDB manages TF, so
it may appear cleared in `info registers eflags` while the process is stopped.
Do not expect the normal output to change to TF=1 just because GDB is attached.