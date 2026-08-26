section .data
    msg db "Hello, World!", 10   ; the string, with a newline (10 = \n) at the end
    msg_len equ $ - msg          ; calculates the length of msg automatically

section .text
    global _start

_start:
    ; write(1, msg, msg_len)
    mov rax, 1        ; syscall number for write
    mov rdi, 1        ; file descriptor 1 = stdout
    mov rsi, msg      ; pointer to the string
    mov rdx, msg_len  ; number of bytes to write
    syscall

    ; exit(0)
    mov rax, 60       ; syscall number for exit
    mov rdi, 0        ; exit code 0
    syscall