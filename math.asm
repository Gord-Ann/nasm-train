SYS_EXIT  equ 1
SYS_READ  equ 3
SYS_WRITE equ 4
STDIN     equ 0
STDOUT    equ 1

SECTION .data           
    newLine:     DB 0xA, 0xD
    newLineLen:  EQU $-newLine
SECTION .bss
    x resb 1
    y resb 1

SECTION .text
    GLOBAL _start 

_start:
    ; mov eax, SYS_READ ; read
    ; mov ebx, STDIN
    ; mov ecx, x 
    ; mov edx, 10
    ; int 0x80

    mov eax, 12
    mov ebx, 2
    mul ebx
    add eax, '0'
    mov [y], eax

    mov eax, SYS_WRITE ; write
    mov ebx, STDOUT
    mov ecx, y
    mov edx, 10
    int 80h
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newLine
    mov edx, newLineLen
    int 80h

    mov eax, SYS_EXIT
    mov ebx, 0
    int 80h