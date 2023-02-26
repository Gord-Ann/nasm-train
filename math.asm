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
    mov eax, SYS_READ ; read
    mov ebx, STDIN
    mov ecx, x 
    mov edx, 10
    int 0x80
    
    lea edx, [x] ; convert input string to number
    call atoi
    mov [x], eax

    mov eax, 12 ; 12*2 + x
    mov ebx, 2
    mul ebx
    add eax, [x]

    mov ebx, 2 ; eax/(2 + 3)
    add ebx, 3
    div ebx
    push rax

    mov eax, 12 ; 12/6
    mov ebx, 6
    xor edx, edx ; zero the edx register so the remainder from prevoius division won't trash arithmetic operation
    div ebx
    pop rbx ; ebx - 12/6
    sub ebx, eax
    push rbx

    mov eax, 13 ; 13*x
    mov ebx, [x]
    mul ebx
    pop rbx ; ebx + 13*x
    add eax, ebx

    mov [y], eax ; mov final answer to y
    
    ; convert number to output string
    mov eax, [y]
    mov [y], byte 0 ; zero the answer
    lea esi, [y]
    call int_to_string

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

atoi:
    xor eax, eax ; zero a "result so far"
    .top:
    movzx ecx, byte [edx] ; get a character
    inc edx ; ready for next one
    cmp ecx, '0' ; valid?
    jb .done
    cmp ecx, '9'
    ja .done
    sub ecx, '0' ; "convert" character to number
    imul eax, 10 ; multiply "result so far" by ten
    add eax, ecx ; add in current digit
    jmp .top ; until done
.done:
    ret

int_to_string:
    add esi, 9
    mov byte [esi], 0

    mov ebx,10         
.next_digit:
    xor edx, edx         ; Clear edx prior to dividing edx:eax by ebx
    div ebx             ; eax /= 10
    add dl, '0'          ; Convert the remainder to ASCII 
    dec esi             ; store characters in reverse order
    mov [esi], dl
    test eax, eax            
    jnz .next_digit     ; Repeat until eax==0
    mov eax, esi
    ret