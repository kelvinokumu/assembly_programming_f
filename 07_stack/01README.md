01.asm

This program places 100 in the RAX register, 200 in the RBX register and pushes the values to the stack. Then we pop them into RCX and RDX. This is just to give us a basic understanding of how the push and pop instructions affect the RSP register and the Last In First Out nature of the stack.

running it :
nasm -f elf64 -g -F dwarf 01.asm -o 01.o
ld 01.o -o 01
./01
echo $?    # 0

The program doesn't print anything, so I used GDB to step through it:
GDB:
gdb ./01
break _start
run
stepi
info registers rsp rax rbx rcx rdx
x/3gx $rsp
Step by step

Step 0: When the program starts, RSP was at 0x7fffffffdaf0. The kernel has already put some values on the stack before our code runs. The value on top is 1, which is argc.

Step 1: mov rax, 100 sets RAX to 0x64. The stack is not touched, so RSP stays the same.

Step 2: mov rbx, 200 sets RBX to 0xc8. RSP still doesn't change.

Step 3: push rax subtracts 8 from RSP and then stores RAX at the new address. RSP goes from ...daf0 to ...dae8. The stack grows downwards, toward lower addresses.

Step 4: push rbx does the same thing. RSP goes down to ...dae0 and 200 is now on top of the stack. In GDB the stack looked like this:

(gdb) x/3gx $rsp
0x7fffffffdae0: 0x00000000000000c8  0x0000000000000064
0x7fffffffdaf0: 0x0000000000000001

200 is on top, 100 is below it, and argc is still above both.

after the two pushes

Step 5: pop rcx reads the value at RSP into RCX, then adds 8 to RSP. Since 200 was pushed last, it comes out first, so RCX = 0xc8. RSP goes back to ...dae8.

Step 6: pop rdx takes the next value, so RDX = 0x64 (100). RSP is back at ...daf0, the same as at the start.

So the values come out in reverse order. RAX's value ends up in RDX and RBX's value ends up in RCX.

after the pops

Step 7: The program exits with mov rax, 60, xor rdi, rdi, syscall. The stack isn't used here.

Observations

Every push and pop instruction moves the RSP by 8 bytes. As the registers are 64 bits.

The pop instruction doesn't empty the memory. Using x/2gx 0x7fffffffdae0 after popping both values shows the values still exist (0xc8 and 0x64). They are now just below RSP and will be overwritten by the next push.

The value is copied. RAX is still 100 after the push.

mov RAX, 100 was shown as mov EAX, 0x64 in GDB. NASM uses the shorter version as when writing to EAX it will clear the upper half of RAX.

The addresses will vary between different machines but will always move in 8 byte increments.