section .data

    num1 dd 10
    num2 dd 20

section .text
global _start

_start:

    mov eax, [num1]
    add eax, [num2]

    mov ebx, eax

    mov eax, 1
    int 0x80
    