05.asm

This program puts 0x1122334455667788 in RAX and 0x1234 in RBX, pushes both, and pops them back into the same registers in reverse order, so each register gets its original value back. The large value makes it easy to see how bytes are ordered in memory.

running it :
nasm -f elf64 -g -F dwarf 05.asm -o 05.o
ld 05.o -o 05
./05
echo $?    # 0

GDB:
gdb ./05
break 10          # nop after the pushes
run
x/2gx $rsp
x/16xb $rsp
Step by step

Step 0: RSP is 0x7fffffff94d0, RAX and RBX are 0.

Step 1: mov rax, 0x1122334455667788 loads the 64-bit value. GDB shows it as movabs, the form of mov used for a full 64-bit immediate. The stack doesn't change.

Step 2: mov rbx, 0x1234 sets RBX. The stack doesn't change.

Step 3: push rax moves RSP down 8 to ...94c8 and stores the 64-bit value there.

Step 4: push rbx moves RSP down to ...94c0. Even though 0x1234 is small, it still takes 8 bytes, because push always stores the full register.

Looking at the stack byte by byte:

(gdb) x/16xb $rsp
0x7fffffff94c0: 0x34 0x12 0x00 0x00 0x00 0x00 0x00 0x00
0x7fffffff94c8: 0x88 0x77 0x66 0x55 0x44 0x33 0x22 0x11

bytes on the stack

0x1122334455667788 is stored as 88 77 66 55 44 33 22 11, with the lowest byte at the lowest address. This is little-endian ordering, which x86 uses. x/2gx shows the value in normal order because GDB reads the 8 bytes as one number.

Step 5: pop rbx takes 0x1234 off the top into RBX. RSP is now ...94c8.

Step 6: pop rax takes 0x1122334455667788 into RAX. RSP is back at ...94d0.

Because the pops are in the reverse order of the pushes, both registers get their original values back. In 01.asm the values ended up swapped because they were popped into different registers.

Step 7: The program exits.

Observations
mov rbx, 0x1234 appears as mov ebx, 0x1234 in GDB because the value fits in 32 bits.
After pop rbx, x/2gx $rsp-16 still showed 0x1234 in memory. Pop only moves RSP.
RSP went down 16 bytes in total and came back up 16.