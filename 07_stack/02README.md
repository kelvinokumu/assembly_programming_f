02.asm

In this program _start calls a function work. Inside work a stack frame is set up, 16 bytes are reserved for two local variables, 100 and 200 are stored and read back into RAX and RBX, and then the frame is cleaned up before returning. This is similar to what a C compiler generates for a function with local variables.

running it :
nasm -f elf64 -g -F dwarf 02.asm -o 02.o
ld 02.o -o 02
./02
echo $?    # 0

GDB:
gdb ./02
set disassembly-flavor intel
break _start
run
stepi
info registers rsp rbp rax rbx
x/4gx $rsp

Step by step

Step 1: RSP = 0x7fffffffdaf0, RBP = 0



Step 1:  call work instruction adds a return address onto the stack, and then jumps to work. The return address here will be 0x401005, since this is the next instruction after call. RSP is decremented by 8 to ...dae8. We get:



0x7fffffffdae8: 0x0000000000401005



Step 2: push RBP instruction saves the callers RBP (0) onto the stack. RSP is decremented to ...dae0.



Step 3:  mov RBP, RSP sets RBP to ...dae0. This value is constant during the function, and is used to reference local variables.



Step 4: sub RSP, 16 decrements RSP by 16 bytes to ...dad0. Again we do not write anything here. We are just reserving space for two 8-byte locals.



Step 5: mov qword [RBP - 8], 100 writes the first local variable to 100. RSP hasn't changed here since we are using a mov.



Step 6: mov qword [RBP - 16], 200 writes the second local variable to 200. We now have the following stack frame:

(gdb) x/4gx $rsp
0x7fffffffdad0: 0x00000000000000c8  0x0000000000000064
0x7fffffffdae0: 0x0000000000000000  0x0000000000401005

stack frame inside work

0x...dae8   0x401005   <- return address
0x...dae0   0          <- saved RBP      (RBP)
0x...dad8   100        <- [rbp-8]
0x...dad0   200        <- [rbp-16]       (RSP)

Step 7: mov rax, [rbp-8] and mov rbx, [rbp-16] load the locals, so RAX = 100 and RBX = 200.

Step 8: mov rsp, rbp moves RSP back up to ...dae0, which discards the locals.

Step 9: pop rbp restores the old RBP (0). RSP is now ...dae8, pointing at the return address.

Step 10: ret pops 0x401005 into RIP and execution goes back to _start. RSP is ...daf0, the same as at the start.

Step 11: The program exits. The stack isn't used.

Observations
work used 32 bytes of stack: 8 for the return address, 8 for the saved RBP and 16 for locals.
Locals are at negative offsets from RBP because the stack grows downwards.
mov rsp, rbp has to run before pop rbp. Without it, pop rbp would pop 200 and ret would jump to address 100, which would crash the program.
RAX and RBX still held 100 and 200 after returning, until RAX was overwritten for the exit syscall.