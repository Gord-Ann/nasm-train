SECTION .data
    hellomyname:      DB 'Hello, Sergey',10
    newLineMsg 	      DB  0xA, 0xD
    newLineLen equ $-newLineMsg

SECTION .text
    GLOBAL _start

_start:
    mov eax,4
    mov ebx,1
    mov ecx,hellomyname
    mov edx,13
    int 80h
    mov edx, newLineLen
    mov ecx, newLineMsg
    mov eax, 4
    mov ebx, 1
    int 80h;
    mov eax,1
    mov ebx,0
    int 80h
