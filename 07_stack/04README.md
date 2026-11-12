04.asm

This is the 32-bit version of 02.asm. _start calls work, which sets up a stack frame with EBP, reserves 8 bytes for two 4-byte locals, stores 100 and 200, loads them into EAX and EBX, and returns. It uses ESP and EBP instead of RSP and RBP, every stack slot is 4 bytes, and it exits with int 0x80.

 running it :
nasm -f elf32 -g -F dwarf 04.asm -o 04.o
ld -m elf_i386 04.o -o 04
./04
echo $?    # 0

-m elf_i386 is needed because ld produces 64-bit output by default. Without it, linking fails with an "incompatible with i386:x86-64 output" error. For the exit, 32-bit Linux uses EAX = 1 with int 0x80 instead of RAX = 60 with syscall.

GDB:
gdb ./04
set disassembly-flavor intel
break _start
run
stepi
info registers esp ebp eax ebx
x/4wx $esp

x/4wx shows 4-byte words, which fits the 32-bit stack better than x/4gx.

Step by step

Step 0: ESP is 0xffff8950 and EBP is 0.

Step 1: call work pushes the return address 0x08049005 and jumps to work. ESP goes down 4 to 0xffff894c.

Step 2: push ebp saves the old EBP (0). ESP is now 0xffff8948.

Step 3: mov ebp, esp sets EBP to 0xffff8948, the base of the frame.

Step 4: sub esp, 8 reserves space for two 4-byte locals. ESP is now 0xffff8940.

Step 5: mov dword [ebp - 4], 100 stores 100 in the first local.

Step 6: mov dword [ebp - 8], 200 stores 200 in the second local. The frame now looks like this:

(gdb) x/4wx $esp
0xffff8940: 0x000000c8  0x00000064  0x00000000  0x08049005

32-bit stack frame

0xffff894c   0x08049005   <- return address
0xffff8948   0            <- saved EBP   (EBP)
0xffff8944   100          <- [ebp-4]
0xffff8940   200          <- [ebp-8]     (ESP)

Step 7: mov eax, [ebp-4] and mov ebx, [ebp-8] load the locals, so EAX = 100 and EBX = 200.

Step 8: mov esp, ebp moves ESP back up to 0xffff8948, which discards the locals.

Step 9: pop ebp restores EBP to 0. ESP is now 0xffff894c.

Step 10: ret pops 0x08049005 into EIP. ESP is back at 0xffff8950 and execution continues in _start.

Step 11: mov eax, 1, xor ebx, ebx, int 0x80 exits the program.

Comparison with 02.asm

The steps are the same as in 02.asm. The only difference is size: each push and pop is 4 bytes instead of 8, so the function uses 16 bytes of stack instead of 32. The locals are at [ebp-4] and [ebp-8] instead of [rbp-8] and [rbp-16].

Observations
ESP always moved in multiples of 4.
The return address 0x08049005 is in a different range from the 64-bit 0x401005. That's because 32-bit programs are loaded at a different default address.
ESP ends at the same value it started with, so the stack is balanced.