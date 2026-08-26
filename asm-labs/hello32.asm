section .text
    global _start

_start:
    mov eax, 1       ; syscall: exit (32-bit syscall number)
    mov ebx, 42      ; exit code 42
    int 0x80         ; 32-bit syscalls use interrupt, not `syscall`
