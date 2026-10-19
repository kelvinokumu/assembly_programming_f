section .data                    ; Begin the section containing initialized data.

    numbers dd 10, 20, 30, 40     ; Define four 32-bit integers, each occupying 4 bytes.

section .text                    ; Begin the section containing executable instructions.
global _start                    ; Export the entry-point label for the linker.

_start:                          ; Program execution begins at this label.

    mov ebx, numbers  
    mov esi, 4

    mov eax, [ebx + esi]         ; Read 4 bytes at the base address plus 8: EAX becomes 30.

    mov ecx, eax                 ; Copy 30 into ECX; this does not print the value.

    mov eax, 1                   ; Replace EAX with 1, the 32-bit Linux sys_exit syscall number.
    int 0x80                     ; Invoke sys_exit with EBX as the status, still the array's address.

; Concept: Array Access and Scaled Indexing
; An array stores its elements consecutively in memory. To locate an element:
;     element address = base address + (zero-based index * bytes per element)
;
; For this array of 4-byte values:
;     Index:        0    1    2    3
;     Byte offset:  0    4    8   12
;     Value:       10   20   30   40
;
; EBX holds the base address, and ESI holds a precomputed byte offset of 8.
; The brackets in [ebx + esi] mean "read memory at this computed address."
; The 32-bit destination EAX determines that the load reads 4 bytes, yielding 30.
;
; Despite the filename, the current instruction has no explicit scale factor.
; To demonstrate scaled indexing for the same element, replace the offset/load
; pair with these instructions:
;     mov esi, 2                  ; Use the element index instead of a byte offset.
;     mov eax, [ebx + esi*4]      ; The CPU scales the index by the 4-byte element size.
; x86 supports address scale factors of 1, 2, 4, or 8.
;
; Nothing is printed. The loaded value is kept in ECX for debugger inspection.
; sys_exit takes its status from EBX, not ECX; here EBX still holds an address.
; To return 30 as the exit status, insert mov ebx, ecx before mov eax, 1.
; After running that version, the shell command echo $? would show 30.