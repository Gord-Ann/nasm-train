SECTION .data           
    vasilii:     DB 'Hello, Vasilii',10
    vasiliiLen:  EQU $-vasilii
SECTION .text
    GLOBAL _start 
_start:
    mov eax,4
    mov ebx,1
    mov ecx,vasilii
    mov edx,vasiliiLen
    int 80h
    mov eax,1
    mov ebx,0
    int 80h