SYS_EXIT	EQU 1
SYS_READ	EQU 3
SYS_WRITE	EQU 4
SYS_OPEN	EQU 5
SYS_CLOSE	EQU 6
SYS_CREATE	EQU 8
STDIN EQU 0
STDOUT EQU 1

SECTION .data

enterNameMsg DB "Введите имя:", 0xA,0xD
enterNameLen EQU $- enterNameMsg

userStartMsg DB "Пользователю "
userStartLen EQU $- userStartMsg

userEndMsg	DB " разрешены действия в системе"
userEndLen	EQU $- userEndMsg

dot DB "."
semicolon DB ":"
space DB " "

file DB "file.txt", 0

endLine	DB 0xA,0xD
endLineLen EQU $- endLine

SECTION .bss

name RESB 40
desc RESB 4
sec RESB 4
min RESB 4
hour RESB 4
day RESB 4
month RESB 4
year RESB 4

date RESB 21

termios resb 36

ICANON equ 1<<1
ECHO equ 1<<3

SECTION .text
global _start

_start:
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, enterNameMsg
	mov edx, enterNameLen
	int 80h

	mov eax, SYS_READ
	mov ebx, STDIN
	mov ecx, name
	mov edx, 40
	int 80h
	call delENDL

	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, userStartMsg
	mov edx, userStartLen
	int 80h

	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, name
	mov edx, 20
	int 80h

	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, userEndMsg
	mov edx, userEndLen
	int 80h

	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, endLine
	mov edx, endLineLen
	int 80h

	mov eax, SYS_CREATE ; create file
	mov ebx, file
	mov ecx, 0777 ; 
	int 80h
	mov [desc], eax

	xor ebx, ebx ; call time function
	mov eax, 13 
	int 80h

	xor ebx, ebx
	mov ebx, 60
	xor edx, edx
	div ebx	
	mov [sec], edx

	xor edx, edx
	div ebx
	mov [min], edx

	mov ebx, 24
	xor edx, edx
	div ebx
	add edx, 3 ; +3 utc

	CMP edx, 24
	JL .utcFix
	add eax, 1
	sub edx, 24

.utcFix:
	mov [hour], edx
	mov ebx, 365
	xor edx, edx
	div ebx
	add eax, 1970
	mov [year], eax	
	mov [day], edx
	call is_Leap
	mov ebx, [day]
	sub ebx, ecx
	test eax, 1
	mov eax, ebx 
	mov ebx, 0
	jnz .notLeap
	mov ebx, 1
.notLeap:
	sub eax, 31
	jc .january
	sub eax, 28
	sub eax, ebx
	jc .february
	sub eax, 31
	jc .march
	sub eax, 30
	jc .april
	sub eax, 31
	jc .may
	sub eax, 30
	jc .june
	sub eax, 31
	jc .july
	sub eax, 31
	jc .august
	sub eax, 30
	jc .september
	sub eax, 31
	jc .october
	sub eax, 30
	jc .november
	sub eax, 31
	jc .december

.january:
	add eax, 31
	mov ebx, "01"
	mov [month], bx
	JMP .day
.february:
	add eax, 28
	add eax, ebx
	mov ebx, "02"
	mov [month], bx
	JMP .day
.march:
	add eax, 31
	mov ebx, "03"
	mov [month], bx
	JMP .day
.april:
	add eax, 30
	mov ebx, "04"
	mov [month], bx
	JMP .day
.may:
	add eax, 31
	mov ebx, "05"
	mov [month], bx
	JMP .day
.june:
	add eax, 30
	mov ebx, "06"
	mov [month], bx
	JMP .day
.july:
	add eax, 31
	mov ebx, "07"
	mov [month], bx
	JMP .day
.august:
	add eax, 31
	mov ebx, "08"
	mov [month], bx
	JMP .day
.september:
	add eax, 30
	mov ebx, "09"
	mov [month], bx
	JMP .day
.october:
	add eax, 31
	mov ebx, "10"
	mov [month], bx
	JMP .day
.november:
	add eax, 30
	mov ebx, "11"
	mov [month], bx
	JMP .day
.december:
	add eax, 31
	mov ebx, "12"
	mov [month], bx
	JMP .day

.day:
	mov [day], eax

	mov ebx, 4
	LEA esi,[sec]
	call int_to_string

	mov ebx, 4
	LEA esi,[min]
	call int_to_string

	mov ebx, 4
	LEA esi,[hour]
	call int_to_string

	mov ebx, 4
	LEA esi,[day]
	call int_to_string

	mov ebx, 4
	LEA esi,[year]
	call int_to_string
	

	mov eax, SYS_WRITE ; write
	mov ebx, [desc]
	LEA ecx, [day+2]
	mov edx, 2
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, dot
	mov edx, 1
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, month
	mov edx, 2
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, dot
	mov edx, 1
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, year
	mov edx, 4
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, space
	mov edx, 1
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	LEA ecx, [hour+2]
	mov edx, 2
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, semicolon
	mov edx, 1
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	LEA ecx, [min+2]
	mov edx, 2
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	mov ecx, semicolon
	mov edx, 1
	int 80h

	mov eax, SYS_WRITE
	mov ebx, [desc]
	LEA ecx, [sec+2]
	mov edx, 2
	int 80h

	mov eax, SYS_CLOSE ; close file
	mov ebx, [desc]
	int 80h

	mov eax, SYS_OPEN ; open file
	mov ebx, file
	mov ecx, 2
	mov edx, 0666o
	int  80h

	mov eax, SYS_READ ; read from file
	mov ebx, [desc]
	mov ecx, name
	mov edx, 40
	int 80h

	mov eax, SYS_WRITE ; write to console
	mov ebx, STDOUT
	mov ecx, name
	mov edx, 20
	int 80h

	mov eax, SYS_CLOSE
	mov ebx, [desc]
	int 80h
	
; listening for the esc key 
	call canonical_off
	call echo_off
.esc:
	mov eax, SYS_READ
	mov ebx, STDIN
	mov ecx, name
	mov edx, 1
	int 80h
	movZX eax, byte [name]
	CMP eax, 0x1B
	JNE .esc
exit:    
	call canonical_on
	call echo_on
; printing the endline symbols
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, endLine
	mov edx, endLineLen
	int 80h
	mov eax, SYS_EXIT
	xor ebx, ebx
	int 80h

int_to_string:
	mov eax,[esi]
	mov byte [esi], 0
	add esi, ebx
	mov ecx, ebx
	mov ebx, 10
.next_digit:
	dec ecx
	xor edx, edx
	div ebx
	add dl,'0'
	dec esi
	mov [esi], dl
	test eax, eax
	jnz .next_digit
.test:
	CMP ecx, 0
	JNE .addZero
	RET
.addZero:
	dec ecx
	dec esi
	mov byte [esi], '0'
	JMP .test

is_Leap:
	mov ebx,4
	xor edx, edx
	div ebx
	test edx,edx
	mov ecx, eax
	jnz .NO1
	mov ebx, 400
	mov eax, [year]
	xor edx, edx
	div ebx
	test edx,edx
	add ecx,eax
	jnz .NO2
	mov ebx, 100
	mov eax, [year]
	xor edx, edx
	div ebx
	test edx,edx
	sub ecx, eax
	JZ .NO3
	mov eax, 0
	RET
.NO1:
	mov ebx, 400
	mov eax, [year]
	xor edx, edx
	div ebx
	add ecx,eax
.NO2:
	mov ebx, 100
	mov eax, [year]
	xor edx, edx
	div ebx
	sub ecx, eax
.NO3:
	sub ecx, 478
	mov eax, 1
	RET
delENDL: 
	xor eax, eax
	mov ebx, name
.top:
	movZX eax, byte [ebx]
	CMP eax, 'A'
	JB .done
	CMP eax, 'z'
	JA .done
	INC ebx
	JMP .top
.done:
	mov byte [ebx], 0
	RET

canonical_off:
	call read_STDIN_termios

	; clear canonical bit in local mode flags
	AND dword [termios+12], ~ICANON

	call write_STDIN_termios
	RET

echo_off:
	call read_STDIN_termios

	; clear echo bit in local mode flags
	AND dword [termios+12], ~ECHO

	call write_STDIN_termios
	RET

canonical_on:
	call read_STDIN_termios

	; set canonical bit in local mode flags
	OR dword [termios+12], ICANON

	call write_STDIN_termios
	RET

echo_on:
	call read_STDIN_termios

	; set echo bit in local mode flags
	OR dword [termios+12], ECHO

	call write_STDIN_termios
	RET

read_STDIN_termios:
	PUSH rbx

	mov eax, 36h
	mov ebx, STDIN
	mov ecx, 5401h
	mov edx, termios
	int 80h            ; ioctoberl(0, 5401h, termios)

	POP rbx
	RET

write_STDIN_termios:
	PUSH rbx

	mov eax, 36h
	mov ebx, STDIN
	mov ecx, 5402h
	mov edx, termios
	int 80h            ; ioctoberl(0, 5402h, termios)

	POP rbx
	RET