03.asm

This program sets RAX to 10, calls calculate which adds 5, and returns to after_call where RAX should be 15. There are no push or pop instructions, but the stack is still used by call and ret to store the return address.

runNING IT :
nasm -f elf64 -g -F dwarf 03.asm -o 03.o
ld 03.o -o 03
./03
echo $?    # 0

GDB:
gdb ./03
break _start
run
stepi
info registers rip rsp rax
x/2gx $rsp
Step by step

Step 0: RIP is 0x401000, RSP is 0x7fffffffdaf0 and RAX is 0.

Step 1: mov rax, 10 sets RAX to 10. The stack doesn't change.

Step 2: call calculate pushes the address of the next instruction, 0x40100a (the after_call label), and jumps to calculate at 0x401015. RSP goes down 8 to ...dae8. In GDB:

(gdb) x/2gx $rsp
0x7fffffffdae8: 0x000000000040100a  0x0000000000000001
(gdb) info symbol 0x40100a
after_call in section .text

return address inside calculate

Step 3: add rax, 5 changes RAX from 10 to 15. The stack isn't used and RSP stays at ...dae8.

Step 4: ret pops the return address 0x40100a into RIP and adds 8 to RSP. RSP is back at ...daf0 and execution continues at after_call.

Step 5: At the nop, RAX is 0xf (15), as the comment in the code expects.

Step 6: The program exits.

Observations
RSP went down 8 on call and back up 8 on ret.
ret simply jumps to whatever address is on top of the stack. If calculate had pushed something without popping it, ret would jump to the wrong place.
calculate doesn't need a push rbp / mov rbp, rsp prologue because it has no locals and doesn't move RSP.
The result is returned in RAX.