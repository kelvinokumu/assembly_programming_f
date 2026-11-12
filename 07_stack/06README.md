06.asm

This is the 32-bit version of 05.asm. EAX is set to 0x11223344 and EBX to 0x1234, both are pushed and then popped back in reverse order, and the program exits with int 0x80.

running it :
nasm -f elf32 -g -F dwarf 06.asm -o 06.o
ld -m elf_i386 06.o -o 06
./06
echo $?    # 0

GDB:
gdb ./06
break 11          # nop after the pushes
run
info registers esp eax ebx
x/2wx $esp
x/8xb $esp
Step by step

Step 0: ESP is 0xffff8950, EAX and EBX are 0.

Step 1: mov eax, 0x11223344 sets EAX. The stack doesn't change.

Step 2: mov ebx, 0x1234 sets EBX. The stack doesn't change.

Step 3: push eax moves ESP down 4 to 0xffff894c and stores 0x11223344. The step is 4 bytes because these are 32-bit registers.

Step 4: push ebx moves ESP down to 0xffff8948 and stores 0x1234.

(gdb) x/2wx $esp
0xffff8948: 0x00001234  0x11223344

stack after the pushes

0xffff8950   1            <- argc
0xffff894c   0x11223344   <- from EAX
0xffff8948   0x00001234   <- from EBX   (ESP)

The raw bytes show the same little-endian ordering as in 05.asm:

(gdb) x/8xb $esp
0xffff8948: 0x34 0x12 0x00 0x00 0x44 0x33 0x22 0x11

Step 5: pop ebx loads 0x1234 into EBX. ESP is now 0xffff894c.

Step 6: pop eax loads 0x11223344 into EAX. ESP is back at 0xffff8950.

Step 7: mov eax, 1 and xor ebx, ebx set up the exit call, and int 0x80 ends the program.

Comparison with 05.asm

Both programs follow the same steps, but here each push is 4 bytes instead of 8. The two values take 8 bytes of stack instead of 16, and 0x1234 is stored as 34 12 00 00 instead of 34 12 00 00 00 00 00 00.

Observations
ESP always moved by 4 bytes.
0x1234 was still in memory after the pop (x/2wx $esp-8).
The program has to be built with -f elf32 and ld -m elf_i386. With -f elf64 it still assembles because of BITS 32, but it runs as a 64-bit program, so the pushes become 8 bytes.
ESP ends at its starting value, so the stack is balanced.