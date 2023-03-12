SYS_EXIT    EQU 1
SYS_READ    EQU 3
SYS_WRITE   EQU 4
STDIN EQU   0
STDOUT EQU  1

SECTION .data

msg1        DB "Enter a x for 13 var", 0xA,0xD
len1        EQU $- msg1

msg2        DB "The answer is: "
len2        EQU $- msg2

next_line   DB 0xA,0xD
len3        EQU $- next_line

SECTION .bss

num         RESB 1
res         RESB 1

SECTION .text
            global _start

_start:
; printing: "Enter a x for 13 var"
            MOV eax, SYS_WRITE
            MOV ebx, STDOUT
            MOV ecx, msg1
            MOV edx, len1
            INT 0x80
; reading a x into num variable
            MOV eax, SYS_READ
            MOV ebx, STDIN
            MOV ecx, num
            MOV edx, 2
            INT 0x80
; converting input string to int
            LEA edx, [num]
            CALL string_to_int
            MOV [num], eax
; printing: "The answer is: "
            MOV eax, SYS_WRITE
            MOV ebx, STDOUT
            MOV ecx, msg2
            MOV edx, len2
            INT 0x80
; comparing
            MOV eax, [num]
            CMP eax,7
            JE exit
            JL .less
            JG .bigger

.bigger
            MOV ebx,2
            MUL ebx
            MOV ecx, [num]
            SUB ecx,3
            ADD eax,ecx
            JMP exit
.less
            MOV ebx,2
            MUL ebx
            ADD eax,5
            SUB eax,2

exit:
; converting int to string
            MOV [res],eax
            MOV [res],byte 0
            LEA esi,[res]
            CALL int_to_string
; printing the answer
            MOV eax, SYS_WRITE
            MOV ebx, STDOUT
            MOV ecx, res
            MOV edx, 10
            INT 0x80
; printing the endline symbols
            MOV eax, SYS_WRITE
            MOV ebx, STDOUT
            MOV ecx, next_line
            MOV edx, len3
            INT 0x80
            MOV eax, SYS_EXIT
            XOR ebx, ebx
            INT 0x80

string_to_int:
            XOR eax, eax
.top:
            MOVZX ecx, byte [edx]
            INC edx
            CMP ecx, '0'
            JB .done
            CMP ecx, '9'
            JA .done
            SUB ecx, '0'
            IMUL eax, 10
            ADD eax, ecx
            JMP .top
.done:
            RET

int_to_string:
            ADD esi, 9
            MOV byte [esi], 0
            MOV ebx,10
.next_digit:
            XOR edx, edx
            DIV ebx
            ADD dl,'0'
            DEC esi
            MOV [esi], dl
            TEST eax, eax
            JNZ .next_digit
            MOV eax, esi
            RET
