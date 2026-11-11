; ==============================================================================
; Architecture: x86-64 NASM Linux
; Description:  Arithmetic flag demonstrations and user-space-safe tests of
;               Direction Flag (DF), Interrupt Flag (IF), and Trap Flag (TF).
; ==============================================================================

section .data
    msg_carry       db "[STATE] Carry Flag (CF) activated: Unsigned Wrap-around.", 10
    len_carry       equ $ - msg_carry

    msg_overflow    db "[STATE] Overflow Flag (OF) activated: Signed Wrap-around.", 10
    len_overflow    equ $ - msg_overflow

    msg_zero        db "[STATE] Zero Flag (ZF) activated: Perfect Equality.", 10
    len_zero        equ $ - msg_zero

    msg_sign        db "[STATE] SF: 0 - 1 sets SF; TEST of +1 clears SF.", 10
    len_sign        equ $ - msg_sign

    msg_parity      db "[STATE] PF: 0x0103 has even low-byte parity; 0x01 has odd parity.", 10
    len_parity      equ $ - msg_parity

    msg_auxiliary   db "[STATE] AF: 0x0F + 1 sets nibble carry; 0x10 + 1 clears it.", 10
    len_auxiliary   equ $ - msg_auxiliary

    msg_carry_ops   db "[STATE] CF: CLC clears, STC sets, and CMC toggles the carry flag.", 10
    len_carry_ops   equ $ - msg_carry_ops

    msg_clear       db "[STATE] CF=0, OF=0, ZF=0: 1 + 1 has no carry, overflow, or zero result.", 10
    len_clear       equ $ - msg_clear

    msg_comparison  db "[BRANCH] CMP 0xFF, 1: JA is true for unsigned 255; JL is true for signed -1.", 10
    len_comparison  equ $ - msg_comparison

    msg_increment   db "[STATE] INC preserves CF: CF=1 stays set; 0xFF -> 0x00 keeps CF=0 and sets ZF.", 10
    len_increment   equ $ - msg_increment

    msg_forward     db "[CONTROL] DF=0: CLD + REP MOVSB copied ABCD forward.", 10
    len_forward     equ $ - msg_forward

    msg_backward    db "[CONTROL] DF=1: STD + REP MOVSB copied ABCD backward; CLD restored DF=0.", 10
    len_backward    equ $ - msg_backward

    msg_if_set      db "[CONTROL] IF=1: Maskable interrupts enabled (read-only test; CLI/STI are privileged).", 10
    len_if_set      equ $ - msg_if_set

    msg_if_clear    db "[CONTROL] IF=0: Maskable interrupts disabled (read-only test; CLI/STI are privileged).", 10
    len_if_clear    equ $ - msg_if_clear

    msg_tf_clear    db "[CONTROL] TF=0: Single-step mode disabled; use GDB at trap_flag_demo to test it.", 10
    len_tf_clear    equ $ - msg_tf_clear

    msg_tf_set      db "[CONTROL] TF=1: Single-step mode enabled; a debugger or SIGTRAP handler is required.", 10
    len_tf_set      equ $ - msg_tf_set

    msg_failed      db "[FAIL] A flag or copy check did not match the expected result.", 10
    len_failed      equ $ - msg_failed

    copy_source     db "ABCD"
    copy_length     equ $ - copy_source

section .bss
    forward_copy    resb copy_length
    backward_copy   resb copy_length

section .text
    global _start
    global trap_flag_demo

_start:
    ; --------------------------------------------------------------------------
    ; Scenario 1: Triggering the Carry Flag (CF) via Unsigned Subtraction
    ; --------------------------------------------------------------------------
    ; We load a small unsigned number and subtract a larger number.
    ; This forces the ALU to "borrow" mathematically, setting the Carry Flag.
    mov rax, 10
    sub rax, 20

    ; The 'jc' (Jump if Carry) instruction specifically checks if CF == 1.
    jc .carry_detected
    jmp .failed

.carry_detected:
    ; Print the Carry Flag message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg_carry
    mov rdx, len_carry
    syscall

.scenario_2:
    ; --------------------------------------------------------------------------
    ; Scenario 2: Triggering the Overflow Flag (OF) via Signed Addition
    ; --------------------------------------------------------------------------
    ; We load the absolute maximum positive value an 8-bit signed byte can hold.
    ; Decimal 127 is 01111111 in binary.
    mov al, 127

    ; We add 1. The binary becomes 10000000. 
    ; The Most Significant Bit (the sign bit) flips to 1.
    ; The processor realizes two positive numbers yielded a negative result.
    ; The Overflow Flag is immediately set.
    add al, 1

    ; The 'jo' (Jump if Overflow) instruction specifically checks if OF == 1.
    jo .overflow_detected
    jmp .failed

.overflow_detected:
    ; Print the Overflow Flag message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg_overflow
    mov rdx, len_overflow
    syscall

.scenario_3:
    ; --------------------------------------------------------------------------
    ; Scenario 3: Triggering the Zero Flag (ZF) via Logical Testing
    ; --------------------------------------------------------------------------
    ; We reset a register to zero using the highly optimized XOR method.
    ; XORing a register against itself forces all bits to 0.
    xor rbx, rbx

    ; We use the non-destructive TEST instruction to evaluate the register.
    ; 0 AND 0 equals 0, so the ALU sets the Zero Flag.
    test rbx, rbx

    ; The 'jz' (Jump if Zero) instruction specifically checks if ZF == 1.
    jz .zero_detected
    jmp .failed

.zero_detected:
    ; Print the Zero Flag message
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rsi, msg_zero
    mov rdx, len_zero
    syscall

.sign_flag:
    mov al, 0
    sub al, 1
    jns .failed
    mov al, 1
    test al, al
    js .failed

    lea rsi, [rel msg_sign]
    mov edx, len_sign
    call print_message

.parity_flag:
    mov ax, 0x0103
    test ax, ax
    jnp .failed
    mov al, 0x01
    test al, al
    jp .failed

    lea rsi, [rel msg_parity]
    mov edx, len_parity
    call print_message

.auxiliary_carry:
    mov al, 0x0F
    add al, 1
    pushfq
    pop r8
    bt r8, 4
    jnc .failed
    mov al, 0x10
    add al, 1
    pushfq
    pop r8
    bt r8, 4
    jc .failed

    lea rsi, [rel msg_auxiliary]
    mov edx, len_auxiliary
    call print_message

.carry_instructions:
    clc
    jc .failed
    stc
    jnc .failed
    cmc
    jc .failed
    cmc
    jnc .failed
    clc

    lea rsi, [rel msg_carry_ops]
    mov edx, len_carry_ops
    call print_message

.cleared_flags:
    mov al, 1
    add al, 1
    jc .failed
    jo .failed
    jz .failed

    lea rsi, [rel msg_clear]
    mov edx, len_clear
    call print_message

.signed_unsigned_comparison:
    mov al, 0xFF
    cmp al, 1
    ja .unsigned_above
    jmp .failed

.unsigned_above:
    jl .signed_below
    jmp .failed

.signed_below:
    lea rsi, [rel msg_comparison]
    mov edx, len_comparison
    call print_message

.increment_preserves_carry:
    stc
    mov al, 1
    inc al
    jnc .failed
    clc
    mov al, 0xFF
    inc al
    jc .failed
    jnz .failed

    lea rsi, [rel msg_increment]
    mov edx, len_increment
    call print_message

.direction_forward:
    cld
    pushfq
    pop r8
    bt r8, 10
    jc .failed

    lea rsi, [rel copy_source]
    lea rdi, [rel forward_copy]
    mov ecx, copy_length
    rep movsb
    test rcx, rcx
    jnz .failed
    cmp dword [rel forward_copy], 'ABCD'
    jne .failed

    lea rsi, [rel msg_forward]
    mov edx, len_forward
    call print_message

.direction_backward:
    lea rsi, [rel copy_source + copy_length - 1]
    lea rdi, [rel backward_copy + copy_length - 1]
    mov ecx, copy_length
    std
    pushfq
    pop r8
    rep movsb
    cld

    bt r8, 10
    jnc .failed
    test rcx, rcx
    jnz .failed
    cmp dword [rel backward_copy], 'ABCD'
    jne .failed
    pushfq
    pop r8
    bt r8, 10
    jc .failed

    lea rsi, [rel msg_backward]
    mov edx, len_backward
    call print_message

.interrupt_flag:
    pushfq
    pop r8
    lea rsi, [rel msg_if_set]
    mov edx, len_if_set
    bt r8, 9
    jc .report_interrupt
    lea rsi, [rel msg_if_clear]
    mov edx, len_if_clear

.report_interrupt:
    call print_message

.trap_flag:
    call trap_flag_demo
    pushfq
    pop r8
    lea rsi, [rel msg_tf_clear]
    mov edx, len_tf_clear
    bt r8, 8
    jnc .report_trap
    lea rsi, [rel msg_tf_set]
    mov edx, len_tf_set

.report_trap:
    call print_message

.termination:
    ; --------------------------------------------------------------------------
    ; Graceful System Exit
    ; --------------------------------------------------------------------------
    cld
    mov rax, 60             ; sys_exit
    mov rdi, 0              ; success
    syscall

.failed:
    cld
    lea rsi, [rel msg_failed]
    mov edx, len_failed
    call print_message
    mov eax, 60
    mov edi, 1
    syscall

print_message:
    mov eax, 1
    mov edi, 1
    syscall
    ret

trap_flag_demo:
    nop
    nop
    ret
