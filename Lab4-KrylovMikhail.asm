STDIN      equ 0
STDOUT     equ 1
SYS_EXIT   equ 1
SYS_READ   equ 3
SYS_WRITE  equ 4
SYS_OPEN   equ 5
SYS_CLOSE  equ 6
SYS_CREATE equ 8
SYS_TIME equ 13
USERNAME_lenght equ 40
TIMESTR_lenght equ 20

segment .data
message1       db "Пожалуйста, введите ваше имя:", 0xA,0xD
lenght1       equ $- message1

message2       db "Пользователю "
lenght2       equ $- message2

message3       db " разрешены действия в системе"
lenght3       equ $- message3

newline         db 0xA,0xD
lenghtnewline      equ $- newline
file      db  "file.txt", 0

dot        db "."
colon      db ":"
space      db " "

segment .bss
ticks   resb 4
time    resb 4
date    resb 4
sec     resb 4
min     resb 4
hour    resb 4
day     resb 4
days    resb 4
month   resb 4
year    resb 4

time_str resb TIMESTR_lenght
username resb USERNAME_lenght

file_desc resb 4 

termios resb 36

ICANON  equ 1<<1
ECHO    equ 1<<3



section .text
    global _start

_start:
; prep
    mov rbp, rsp 

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, message1
    mov edx, lenght1
    int 80h

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, username
    mov edx, USERNAME_lenght
    int 80h
    
; trim username
    xor eax, eax
    mov ebx, username
    .begin:
    movzx eax, byte [ebx]
    cmp eax, '0'
    JB .done
    cmp eax, 'z'
    JA .done
    INC ebx
    jmp .begin
    .done:
    mov byte [ebx], 0

; print messages
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, message2
    mov edx, lenght2
    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, username
    mov edx, USERNAME_lenght
    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, message3
    mov edx, lenght3
    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newline
    mov edx, lenghtnewline
    int 80h

; create file.txt
    mov eax, SYS_CREATE
    mov ebx, file
    mov ecx, 666o       ; chmod 666
    int 80h
    mov [file_desc], eax

    call Timer
    call check_case_leap_year
    call convert_data_to_str
    call writeData

    mov eax, SYS_CLOSE
    mov ebx, [file_desc]
    int 80h

    mov eax, SYS_OPEN
    mov ebx, file
    mov ecx, 2
    mov edx, 666o     ; chmod 666
    int  80h

    mov eax, SYS_READ
    mov ebx, [file_desc]
    mov ecx, time_str
    mov edx, 32
    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, time_str
    mov edx, TIMESTR_lenght
    int 80h

    mov eax, SYS_CLOSE
    mov ebx, [file_desc]
    int 80h

    call input_off

.escape_callback:
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, username
    mov edx, 1
    int 80h
    movzx eax, byte [username]
    cmp eax, 0x1B
    jne .escape_callback
    jmp exit


day_counter:
    mov rax, rdi
    mov ah, al
    shr ah, 3        
    xor ah, al      ; xor with month number
    and ah, 1       ; mask bit 0 from temp result
                    ; we got now 0 or 1 in ah, indicating that a month has 31 or 30 days
    or  ah, 28      ; adjust to number of days, ah has 29 or 28
                    ; phase two: find out if we need to add two more days or not
    dec al          ; decrement month with two
    dec al
    or  al, 0xF0    ; erase lowest nibble
    dec al          ; decrement al
    shr al, 3       ; bit 4 of al in postion 0
    and al, 2       ; eliminate all bits except the one on position 1
    or  ah, al      ; or this bit in number of days
                    ; ah has now 28,30 or 31 for number of days
    shr ax, 8       ; shift result in al
    ret             ; return number of days in al

r_termios:
    push rbx
    mov eax, 36h
    mov ebx, STDIN
    mov ecx, 5401h
    mov edx, termios
    int 80h
    pop rbx
    ret

w_termios:
    push rbx
    mov eax, 36h
    mov ebx, STDIN
    mov ecx, 5402h
    mov edx, termios
    int 80h
    pop rbx
    ret

input_off:
    call r_termios
    and dword [termios+12], ~ICANON ; clear canonical bit
    call w_termios

    call r_termios
    and dword [termios+12], ~ECHO ; clear echo bit
    call w_termios
    ret

input_on:
    call r_termios
    or dword [termios+12], ICANON ; set canonical bit
    call w_termios
    
    call r_termios
    or dword [termios+12], ECHO ; set echo bit
    call w_termios
    ret

; SYS_EXIT
exit:    
    call input_on

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newline
    mov edx, lenghtnewline
    int 80h
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 80h

Timer:
    xor ebx, ebx        ; cleaning reg EBX
    mov eax, SYS_TIME   ; SYS_TIME
    int 80h

    xor ebx, ebx        ; seconds
    xor edx, edx
    mov ebx, 60
    div ebx
    mov [sec], edx      ; seconds = time % 60

    xor edx, edx        ; minutes
    div ebx
    mov [min], edx

    xor ebx, ebx        ; hours
    xor edx, edx
    mov ebx, 24
    div ebx
    add edx, 3          ; UTC+3

;; if hours >= 24, then we should take it by mod 24
    cmp edx, 24
    jl .noOverflow
    add eax, 1
    sub edx, 24
 .noOverflow:
    mov [hour], edx
    inc eax
    mov [days], eax

    ; only days left since 1970
    xor r10d, r10d
    xor r8d, r8d ; Store days after 1970
    mov r8d, [days] ; r8 won't change on its own
    mov r9d, 1970 ; Store current year
    ret

check_case_leap_year:
.cycle1:
    mov edi, r9d ; prep to call
    call check_leap_year

    test eax, eax 
    jnz .leap
    mov r10d, 0
    sub r8d, 365
    inc r9d
    jmp .cycle1d
.leap:
    mov r10d, 1
    sub r8d, 366
    inc r9d
 .cycle1d:
    test r10d, r10d
    jz .nl
    cmp r8d, 366 ;
    jmp .cycle1e
    .nl:
    cmp r8d, 365
.cycle1e:
    jg .cycle1

    mov [year], r9d

    xor r9d, r9d ; zero counter

.cycle2:
    ; precondition: r8d - days in year
    inc r9d ; r9d = month
    cmp r9d, 2
    jne .notFebruary
    mov edi, [year]
    call check_leap_year
    test eax, eax 
    jz .notFebruary
    mov ebx, 29 ; Leap year and February means 29
    jmp .main
.notFebruary:
    mov edi, r9d
    call day_counter
    movzx ebx, al
.main:
    sub r8d, ebx
    cmp r8d, 0
    jg .cycle2
    add r8d, ebx

    mov [month], r9d
    mov [day], r8d
    ret
    
int_conv:
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
    cmp ecx, 0
    jne .addZero
    ret
 .addZero:
    dec ecx
    dec esi
    mov byte [esi], '0'
    jmp .test
    ret

convert_data_to_str:
    mov ebx, 4
    lea esi,[year]
    call int_conv

    mov ebx, 4
    lea esi,[day]
    call int_conv

    mov ebx, 4
    lea esi,[month]
    call int_conv

    mov ebx, 4
    lea esi,[hour]
    call int_conv

    mov ebx, 4
    lea esi,[min]
    call int_conv

    mov ebx, 4
    lea esi,[sec]
    call int_conv
    ret

check_leap_year:
    ; req: rdi = year

    ; divisor of 4
    mov rcx, rdi
    and rcx, 0x03  ; 
    xor rax, rax   ; ret value = false
    test rcx, rcx
    jne .done ; jne if year % 4 != 0

    ; divisor of 100
    mov rax, rdi
    xor rdx, rdx
    mov rcx, 100
    div rcx       ; remainder in RDX
    not rax       ; ret rax = true
    test rdx, rdx
    jne .done     ; jne if year % 100 != 0

    ; divisor of 400
    mov rax, rdi
    xor rdx, rdx
    mov rcx, 400
    div rcx       ; remainder in RDX
    xor rax, rax
    test rdx, rdx ; leap year <=> rdx == 0
    jnz .done     ; ret rax = false if rdx != 0
    not rax       ; ret rax = true otherwise
 .done:
    ret

writeData:
    ;time
    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    lea ecx, [hour+2]
    mov edx, 2
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, colon   
    mov edx, 1
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    lea ecx, [min+2]
    mov edx, 2
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, colon   
    mov edx, 1
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    lea ecx, [sec+2]
    mov edx, 2
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, space
    mov edx, 1 
    int 80h
    ;date
    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    lea ecx, [day+2]
    mov edx, 2
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, dot
    mov edx, 1
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    lea ecx, [month+2]
    mov edx, 2
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, dot
    mov edx, 1
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, year
    mov edx, 4
    int 80h

    mov eax, SYS_WRITE
    mov ebx, [file_desc]
    mov ecx, space
    mov edx, 1
    int 80h
    ret
    
