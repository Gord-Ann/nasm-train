STDIN      equ 0
STDOUT     equ 1
SYS_EXIT   equ 1
SYS_READ   equ 3
SYS_WRITE  equ 4
SYS_OPEN   equ 5
SYS_CLOSE  equ 6
SYS_CREATE equ 8
SYS_TIME equ 13
RWRWRW equ 666o
USERNAME_LEN equ 32 ; 32 is max username lenght in linux [useradd man]
TIMESTR_LEN equ 20 ; result length

;;
segment .rodata ; for constant data
dot        db "."
colon      db ":"
space      db " "

msg1       db "Пожалуйста, введите ваше имя:", 0xA,0xD
len1       equ $- msg1

msg2       db "Пользователю "
len2       equ $- msg2

msg3       db " разрешены действия в системе"
len3       equ $- msg3

endl         db 0xA,0xD
lendl      equ $- endl
outputFile      db  "file.txt", 0
;;

;;
segment .bss ; used wariables
time_str resb TIMESTR_LEN;
username    resb USERNAME_LEN ; 32 is max username lenght in linux [man useradd]
ticks   resb 4
time    resb 4
date    resb 4

fd      resb 4 ; file descriptor 

sec     resb 4
min     resb 4
hour    resb 4
day     resb 4
days    resb 4
month   resb 4
year    resb 4

res resb 4

termios resb 36

ICANON  equ 1<<1 ;;
ECHO    equ 1<<3 ;;
;;



section .text
    global _start ; GNU ld compatability

_start:
; Prologue
    mov rbp, rsp 

; I/O work
    mov eax, SYS_WRITE ; printing "Пожалуйста, введите ваше имя:"
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, len1
    int 0x80

    mov eax, SYS_READ  ; reading username
    mov ebx, STDIN
    mov ecx, username
    mov edx, USERNAME_LEN
    int 0x80
    
    call removeZeroTail ; cleaning username

    mov eax, SYS_WRITE  ; printing "Пользователю "
    mov ebx, STDOUT
    mov ecx, msg2
    mov edx, len2
    int 0x80

    mov eax, SYS_WRITE ; printing username
    mov ebx, STDOUT
    mov ecx, username
    mov edx, USERNAME_LEN
    int 0x80

    mov eax, SYS_WRITE  ; printing " разрешены действия в системе"
    mov ebx, STDOUT
    mov ecx, msg3
    mov edx, len3
    int 0x80

    mov eax, SYS_WRITE  ; printing "\n"
    mov ebx, STDOUT
    mov ecx, endl
    mov edx, lendl
    int 0x80

; Creating file outputFile.txt
    mov eax, SYS_CREATE
    mov ebx, outputFile
    mov ecx, RWRWRW       ; chmod 666 for right privileges
    int 0x80
    mov [fd], eax       ; Сохранение дескриптора файла

; get time
    call getTime

; leap year calculation
    call leap_year_calc
 
; conversion
    call conv_date_to_str
    call conv_time_to_str

; writing to file
    call print_date
    call print_time

; closing write descriptor
    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80

; opening file for reading
    mov eax, SYS_OPEN
    mov ebx, outputFile
    mov ecx, 2
    mov edx, RWRWRW     ; chmod 666
    int  0x80

; reading from file 
    mov eax, SYS_READ
    mov ebx, [fd]
    mov ecx, time_str
    mov edx, 32
    int 0x80

; printing time
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, time_str
    mov edx, TIMESTR_LEN
    int 0x80

; closing file descriptor
    mov eax, SYS_CLOSE
    mov ebx, [fd]
    int 0x80


; listening for the esc key 
    call canonical_off
    call echo_off
.esc:
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, username
    mov edx, 1
    int 0x80
    movzx eax, byte [username]
    cmp eax, 0x1B
    jne .esc

  jmp exit
;; end of program


; Remove endl symbol
removeZeroTail:  
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
    ret


; Get days in month
; Leap year February is checked in leap_year_calc
days_in_this_month:
                    ; check if we have more than 28 days
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



canonical_off:
    call read_stdin_termios
    and dword [termios+12], ~ICANON ; clear canonical bit

    call write_stdin_termios
    ret

echo_off:
    call read_stdin_termios

    and dword [termios+12], ~ECHO ; clear echo bit

    call write_stdin_termios
    ret

canonical_on:
    call read_stdin_termios

    or dword [termios+12], ICANON ; set canonical bit

    call write_stdin_termios
    ret

echo_on:
    call read_stdin_termios

    or dword [termios+12], ECHO ; set echo bit

    call write_stdin_termios
    ret

read_stdin_termios:
    push rbx

    mov eax, 36h
    mov ebx, STDIN
    mov ecx, 5401h
    mov edx, termios
    int 0x80

    pop rbx
    ret

write_stdin_termios:
    push rbx

    mov eax, 36h
    mov ebx, STDIN
    mov ecx, 5402h
    mov edx, termios
    int 0x80

    pop rbx
    ret

; SYS_EXIT
exit:    
    call canonical_on
    call echo_on
; printing the endl symbols
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, endl
    mov edx, lendl
    int 0x80
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

getTime:
; Getting time and date
    xor ebx, ebx        ; cleaning reg EBX
    mov eax, SYS_TIME   ; SYS_TIME
    int 0x80

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

print_time:
    mov eax, SYS_WRITE
    mov ebx, [fd]
    lea ecx, [hour+2]
    mov edx, 2
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, colon   
    mov edx, 1
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    lea ecx, [min+2]
    mov edx, 2
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, colon   
    mov edx, 1
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    lea ecx, [sec+2]
    mov edx, 2
    int 0x80
    ret

print_date:
    mov eax, SYS_WRITE
    mov ebx, [fd]
    lea ecx, [day+2]
    mov edx, 2
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, dot
    mov edx, 1
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    lea ecx, [month+2]
    mov edx, 2
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, dot
    mov edx, 1
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, year
    mov edx, 4
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, [fd]
    mov ecx, space
    mov edx, 1
    int 0x80
    ret

; Convert int to string
stoi:
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

conv_date_to_str:
    mov ebx, 4
    lea esi,[year]
    call stoi

    mov ebx, 4
    lea esi,[day]
    call stoi

    mov ebx, 4
    lea esi,[month]
    call stoi
    ret

conv_time_to_str:
    mov ebx, 4
    lea esi,[hour]
    call stoi

    mov ebx, 4
    lea esi,[min]
    call stoi

    mov ebx, 4
    lea esi,[sec]
    call stoi
    ret

leap_year_calc:
.loop1:
    mov edi, r9d ; prep to call
    call leap_year

    test eax, eax 
    jnz .leap
    mov r10d, 0
    sub r8d, 365
    inc r9d
    jmp .loop1done
 .leap:
    mov r10d, 1
    sub r8d, 366
    inc r9d
 .loop1done:
    test r10d, r10d
    jz .nl
    cmp r8d, 366 ;
    jmp .loop1end
    .nl:
    cmp r8d, 365
 .loop1end:
    jg .loop1

    mov [year], r9d

    xor r9d, r9d ; zero counter

 .loop2:
    ; precondition: r8d - days in year
    inc r9d ; r9d = month
    cmp r9d, 2
    jne .notFebruary
    mov edi, [year]
    call leap_year
    test eax, eax 
    jz .notFebruary
    mov ebx, 29 ; Leap year and February means 29
    jmp .mainline
.notFebruary:
    mov edi, r9d
    call days_in_this_month
    movzx ebx, al
.mainline:
    sub r8d, ebx
    cmp r8d, 0
    jg .loop2
    add r8d, ebx

    mov [month], r9d
    mov [day], r8d
    ret

; Check if current year is leap
leap_year:
    ; precondition: rdi = year

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
