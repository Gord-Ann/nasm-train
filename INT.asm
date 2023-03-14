SYS_EXIT	EQU 1
SYS_READ	EQU 3
SYS_WRITE	EQU 4
STDIN		EQU 0
STDOUT		EQU 1
SYS_CREATE	EQU 8
SYS_OPEN	EQU 5

SECTION .data

msg1		DB "Please, enter your name:", 0xA,0xD
len1		EQU $- msg1

msg2		DB "Пользователю "
len2		EQU $- msg2

dot 		DB "."
doubleDot 	DB ":"
space 		DB " "

msg3		DB " разрешены действия в системе"
len3		EQU $- msg3

file		DB "/home/nikita/Рабочий стол/Лабы по NASM/4/file.txt", 0

next_line	DB 0xA,0xD
lenNL		EQU $- next_line

SECTION .bss

name		RESB 40
time		RESB 4
desc		RESB 4
sec			RESB 4
min			RESB 4
hour		RESB 4
day			RESB 4
mon			RESB 4
year		RESB 4

termios        resb 36

stdin_fd       equ 0           ; STDIN_FILENO
ICANON         equ 1<<1
ECHO           equ 1<<3

SECTION .text
global main

main:
    		MOV rbp, rsp; for correct debugging
    		MOV ebp, esp; for correct debugging
			XOR eax, eax
; printing: "Enter a x for 13 var"
			MOV eax, SYS_WRITE
			MOV ebx, STDOUT
			MOV ecx, msg1
			MOV edx, len1
			INT 0x80
; reading a name into the name variable
			MOV eax, SYS_READ
			MOV ebx, STDIN
			MOV ecx, name
			MOV edx, 40
			INT 0x80
			CALL delSpace
; printing: "Пользователю "
			MOV eax, SYS_WRITE
			MOV ebx, STDOUT
			MOV ecx, msg2
			MOV edx, len2
			INT 0x80
; printing the name
			MOV eax, SYS_WRITE
			MOV ebx, STDOUT
			MOV ecx, name
			MOV edx, 20
			INT 0x80
; printing: " разрешены действия в системе"
			MOV eax, SYS_WRITE
			MOV ebx, STDOUT
			MOV ecx, msg3
			MOV edx, len3
			INT 0x80
; printing the endline symbols
			MOV eax, SYS_WRITE
			MOV ebx, STDOUT
			MOV ecx, next_line
			MOV edx, lenNL
			INT 0x80
; creating file.txt
			MOV eax, SYS_CREATE
			MOV ebx, file
			MOV ecx, 0777       ;read-write-ex
			INT 0x80
			MOV [desc], edx
; getting time
			MOV eax, 13
			INT 0x80
			MOV [time], eax
			XOR ebx, ebx     ;cleaning reg EBX
			MOV ebx, 60
			XOR edx, edx     ;cleaning reg EDX
			DIV ebx
			MOV [sec], edx
			XOR edx, edx     ;cleaning reg EDX
			DIV ebx
			MOV [min], edx

			MOV ebx, 24
			XOR edx, edx     ;cleaning reg EDX
			DIV ebx
			ADD edx, 3       ;UTC+3 - Moscow time
			MOV [hour], edx
			MOV ebx, 365
			XOR edx, edx     ;cleaning reg EDX
			DIV ebx
			ADD eax, 1970
			MOV [year], eax	
			MOV [day], edx
			CALL is_Leap
			MOV ebx, [day]
			SUB ebx, ecx
			TEST eax, 1
			MOV eax, ebx 
			MOV ebx, 0
			JNZ .notLeap
			MOV ebx, 1
.notLeap:
			;IMUL ecx, 24
			;MOV eax, [time]
			;SUB eax, ecx
			;MOV ebx, 86400
			;XOR edx, edx
			;DIV ebx


			;ADD edx, ecx
			;MOV [hour], edx
			;MOV ebx, 365
			;XOR edx, edx     ;cleaning reg EDX
			;DIV ebx
			;SUB edx, ecx
			SUB eax, 31
			JC .JAN
			SUB eax, 28
			SUB eax, ebx
			JC .FEB
			SUB eax, 31
			JC .MAR
			SUB eax, 30
			JC .APR
			SUB eax, 31
			JC .MAY
			SUB eax, 30
			JC .JUN
			SUB eax, 31
			JC .JUL
			SUB eax, 31
			JC .AUG
			SUB eax, 30
			JC .SEP
			SUB eax, 31
			JC .OCT
			SUB eax, 30
			JC .NOV
			SUB eax, 31
			JC .DEC

.JAN:
			ADD eax, 31
			MOV ebx, "01"
			MOV [mon], bx
			JMP .day
.FEB:
			ADD eax, 28
			ADD eax, ebx
			MOV ebx, "02"
			MOV [mon], bx
			JMP .day
.MAR:
			ADD eax, 31
			MOV ebx, "03"
			MOV [mon], bx
			JMP .day
.APR:
			ADD eax, 30
			MOV ebx, "04"
			MOV [mon], bx
			JMP .day
.MAY:
			ADD eax, 31
			MOV ebx, "05"
			MOV [mon], bx
			JMP .day
.JUN:
			ADD eax, 30
			MOV ebx, "06"
			MOV [mon], bx
			JMP .day
.JUL:
			ADD eax, 31
			MOV ebx, "07"
			MOV [mon], bx
			JMP .day
.AUG:
			ADD eax, 31
			MOV ebx, "08"
			MOV [mon], bx
			JMP .day
.SEP:
			ADD eax, 30
			MOV ebx, "09"
			MOV [mon], bx
			JMP .day
.OCT:
			ADD eax, 31
			MOV ebx, "10"
			MOV [mon], bx
			JMP .day
.NOV:
			ADD eax, 30
			MOV ebx, "11"
			MOV [mon], bx
			JMP .day
.DEC:
			ADD eax, 31
			MOV ebx, "12"
			MOV [mon], bx
			JMP .day
.day:
			MOV [day], eax

			MOV ebx, 4
			LEA esi,[sec]
			CALL int_to_string

			MOV ebx, 4
			LEA esi,[min]
			CALL int_to_string

			MOV ebx, 4
			LEA esi,[hour]
			CALL int_to_string

			MOV ebx, 4
			LEA esi,[day]
			CALL int_to_string

			MOV ebx, 4
			LEA esi,[year]
			CALL int_to_string


; writing in file.txt
			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			LEA ecx, [day+2]
			MOV edx, 2
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, dot
			MOV edx, 1
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, mon
			MOV edx, 2
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, dot
			MOV edx, 1
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, year
			MOV edx, 4
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, space
			MOV edx, 1
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			LEA ecx, [hour+2]
			MOV edx, 2
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, doubleDot
			MOV edx, 1
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			LEA ecx, [min+2]
			MOV edx, 2
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			MOV ecx, doubleDot
			MOV edx, 1
			INT 0x80

			MOV eax, SYS_WRITE
			MOV ebx, [desc]
			LEA ecx, [sec+2]
			MOV edx, 2
			INT 0x80

; closing the file.txt
			MOV eax, 6
			MOV ebx, [desc]
			INT 0x80
;open the file for reading
			MOV eax, 5
			MOV ebx, file
			MOV ecx, 0             ;for read only access
			MOV edx, 0777          ;read, write and execute by all
			INT  0x80
; reading from file.txt		
			MOV eax, SYS_READ
			MOV ebx, [desc]
			MOV ecx, name
			MOV edx, 40
			INT 0x80
; closing the file.txt
			MOV eax, 6
			MOV ebx, [desc]
			INT 0x80
; Listening for the esc key 
			CALL canonical_off
			CALL echo_off
.esc:
			MOV eax, SYS_READ
			MOV ebx, STDIN
			MOV ecx, name
			MOV edx, 1
			INT 0x80
			MOVZX eax, byte [name]
			CMP eax, 0x1B
			JNE .esc
exit:    
			CALL canonical_on
			CALL echo_on
; printing the endline symbols
			MOV eax, SYS_WRITE
			MOV ebx, STDOUT
			MOV ecx, next_line
			MOV edx, lenNL
			INT 0x80
			MOV eax, SYS_EXIT
			XOR ebx, ebx
			INT 0x80

int_to_string:
			MOV eax,[esi]
			MOV byte [esi], 0
			ADD esi, ebx
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
is_Leap:
			MOV ebx,4
			XOR edx, edx
			DIV ebx
			TEST edx,edx
			MOV ecx, eax
			JNZ .NO1
			MOV ebx, 400
			MOV eax, [year]
			XOR edx, edx
			DIV ebx
			TEST edx,edx
			ADD ecx,eax
			JNZ .NO2
			MOV ebx, 100
			MOV eax, [year]
			XOR edx, edx
			DIV ebx
			TEST edx,edx
			SUB ecx, eax
			JZ .NO3
			MOV eax, 0
			RET
.NO1:
			MOV ebx, 400
			MOV eax, [year]
			XOR edx, edx
			DIV ebx
			ADD ecx,eax
.NO2:
			MOV ebx, 100
			MOV eax, [year]
			XOR edx, edx
			DIV ebx
			SUB ecx, eax
.NO3:
			SUB ecx, 478
			MOV eax, 1
			RET
delSpace:		
			XOR eax, eax
			MOV ebx, name
.top:
			MOVZX eax, byte [ebx]
			CMP eax, 'A'
			JB .done
			CMP eax, 'z'
			JA .done
			INC ebx
			JMP .top
.done:
			MOV byte [ebx], 0
    		RET
    
canonical_off:
        call read_stdin_termios

        ; clear canonical bit in local mode flags
        and dword [termios+12], ~ICANON

        call write_stdin_termios
        ret

echo_off:
        call read_stdin_termios

        ; clear echo bit in local mode flags
        and dword [termios+12], ~ECHO

        call write_stdin_termios
        ret

canonical_on:
        call read_stdin_termios

        ; set canonical bit in local mode flags
        or dword [termios+12], ICANON

        call write_stdin_termios
        ret

echo_on:
        call read_stdin_termios

        ; set echo bit in local mode flags
        or dword [termios+12], ECHO

        call write_stdin_termios
        ret

; clobbers RAX, RCX, RDX, R8..11 (by int 0x80 in 64-bit mode)
; allowed by x86-64 System V calling convention    
read_stdin_termios:
        push rbx

        mov eax, 36h
        mov ebx, stdin_fd
        mov ecx, 5401h
        mov edx, termios
        int 80h            ; ioctl(0, 0x5401, termios)

        pop rbx
        ret

write_stdin_termios:
        push rbx

        mov eax, 36h
        mov ebx, stdin_fd
        mov ecx, 5402h
        mov edx, termios
        int 80h            ; ioctl(0, 0x5402, termios)

        pop rbx
        ret