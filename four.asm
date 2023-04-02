section .data
  prompt:               db "Please enter your name: ", 0
  msg:                  db "User ", 0
  allowed:              db " is allowed to perform actions in the system", 10, 0
  filename:             db "file.txt", 0
  days_per_month:       dq 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ; days per month


section .bss
  termios_original: resb 24 ; original terminal settings
  termios_raw:      resb 24 ; raw terminal settings
  char_buffer:      resb 1  ; buffer for the putchar function
  buf:              resb 64 ; buffer for the read/write functions

section .text
  global _start

_start:
  ; Print prompt "please enter your name"
  mov rax, 1            ;writing
  mov rdi, 1            ;stdout
  lea rsi, [prompt]     ;line with text
  mov rdx, 24           ;how many characterts to print
  syscall               ;execute

  ; Read user input
  mov rax, 0            ;reading
  mov rdi, 0            ;stdin
  lea rsi, [buf]        ;adress for buffer
  mov rdx, 64           ;length (size of buffer)
  syscall               ;execute
  mov r8, rax           ;r8 = number of bytes read
  dec r8                ;remove last character

  ; Print msg
  mov rax, 1            ;writing
  mov rdi, 1            ;stdout
  lea rsi, [msg]        ;adress for line to output
  mov rdx, 5            ;how many characters to print
  syscall               ;execute

  ; Print user input
  mov rax, 1            ;writing
  mov rdi, 1            ;stdout
  lea rsi, [buf]        ;buffer address
  mov rdx, r8           ;amount of characters to print from buffer
  syscall               ;execute

  ; Print allowed
  mov rax, 1            ;writing
  mov rdi, 1            ;stdout
  lea rsi, [allowed]    ;adress for line
  mov rdx, 45           ;length of line to print
  syscall               ;execute

  ; Get current time
  mov rax, 201          ;syscall for sys_time
  lea rdi, [buf]        ;moving time to buffer
  syscall               ;execute

  ; Convert timestamp
  mov rdi, rax              ; rdi = timestamp
  call breakdown_timestamp  ; r10 = year, r11 = month, r12 = day, r13 = hour, r14 = minute, r15 = second

  push r11                  ; Save r11
  mov rax, 2                ; Open file
  lea rdi, [filename]       ; file name i want to open
  mov rsi, 0102             ; O_RDWR | O_CREAT
  mov rdx, 0666o            ; file permission mode, -rw-rw-rw-
  syscall
  pop r11                   ; Restore r11

  mov rsi, rax              ; save id of opened file
  mov rdi, r12              ; day
  call print_number         ; print day
  mov rdi, '.'
  call putchar
  mov rdi, r11
  call print_number         ; print month
  mov rdi, '.'
  call putchar
  mov rdi, r10
  call print_number         ; print year

  mov rdi, ' '
  call putchar

  mov rdi, r13
  call print_number         ; print hour
  mov rdi, ':'
  call putchar
  mov rdi, r14
  call print_number         ; print minute
  mov rdi, ':'
  call putchar
  mov rdi, r15
  call print_number         ; print second

  ; Close file
  push r11                  ; Save r11
  mov rax, 3                ;sys close
  mov rdi, rsi              ;id of opened file
  syscall
  pop r11                   ; Restore r11

  ; print on stdout
  mov rax, 1
  mov rdi, r12              ; day
  call print_number         ; print day
  mov rdi, '.'
  call putchar
  mov rdi, r11
  call print_number         ; print month
  mov rdi, '.'
  call putchar
  mov rdi, r10
  call print_number         ; print year

  mov rdi, ' '
  call putchar

  mov rdi, r13
  call print_number         ; print hour
  mov rdi, ':'
  call putchar
  mov rdi, r14
  call print_number         ; print minute
  mov rdi, ':'
  call putchar
  mov rdi, r15
  call print_number         ; print second


; Disable canonical mode (no buffering)
  ; Save original terminal settings
  mov rax, 16               ; sys_ioctl
  mov rdi, 0                ; stdin
  mov rsi, 0x5401           ; TCGETS
  lea rdx, [termios_original]
  syscall

  ; Copy original settings to termios_raw and modify it for raw mode
  lea rsi, [termios_original]
  lea rdi, [termios_raw]
  mov rcx, 24
  cld                               ; Clear direction flag
  rep movsb
  ; Disable ECHO, ICANON, and other flags
  and word [termios_raw+12], 0xFFA0 ; termios_raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG)
  ; Set minimum bytes to read and timeout to 0
  mov byte [termios_raw+6], 0       ; termios_raw.c_cc[VMIN] = 0
  mov byte [termios_raw+7], 0       ; termios_raw.c_cc[VTIME] = 0

  ; Set terminal to raw mode
  mov rax, 16               ; sys_ioctl
  mov rdi, 0                ; stdin
  mov rsi, 0x5402           ; TCSETS
  lea rdx, [termios_raw]
  syscall

; Loop until ESC key is pressed
wait_for_esc:
  ; Wait for keypress
  mov rax, 0                ; read
  mov rdi, 0                ; stdin
  lea rsi, [buf]            ; write it into buffer
  mov rdx, 1                ; read 1 character
  syscall

  cmp byte [buf], 0x1B      ; Check for ESC key
  jne wait_for_esc

  ; Restore original terminal settings
  mov rax, 16               ; sys_ioctl
  mov rdi, 0                ; stdin
  mov rsi, 0x5401           ; TCGETS
  lea rdx, [termios_original]
  syscall

  ; Exit program
  mov rax, 60
  xor rdi, rdi
  syscall

breakdown_timestamp:
  ; Convert Unix timestamp stored rdi to year, month, day, hour, minute, second
  ; Result in r10 (year), r11 (month), r12 (day), r13 (hour), r14 (minute), r15 (second)

  ; Calculate total number of days and remaining seconds
  mov rax, rdi              ; rax = seconds since 1970
  mov rbx, 24*60*60         ; rbx = number of seconds in a day
  xor rdx, rdx              ; reset rdx
  div rbx                   ; number of second since 1970/number of seconds in a day (rax = daysTillNow, rdx = extraTime)
  mov r9, rax               ; daysTillNow
  mov r15, rdx              ; extra seconds
  mov r10, 1970             ; Initialize currYear

  ; Calculate currYear by repeatedly subtracting 365 or 366 days from daysTillNow
  .year_loop:
    ; Check for leap year
    ; (currYear % 400 == 0)
    mov rax, r10            ;put 1970 and increase it every loop
    mov r12, 400            ;put 400 into r12
    xor rdx, rdx            ;reset rdx
    div r12                 ;divide 1970 by 400 to see if its leap
    cmp rdx, 0              ;check if remainder is 0
    je .leap_year           ; if it is then its leap year and jump to leap_year func

    ; (currYear % 4 == 0
    mov rax, r10            ; year to check
    mov r12, 4              ;move 4
    xor rdx, rdx            ;reset rdx
    div r12                 ;divide year by 4 to see if its leap
    cmp rdx, 0              ;check if remainder is 0
    jne .not_leap_year      ;if not then not a leap year and jump to not_leap_year
    ;  && currYear % 100 != 0)
    mov rax, r10            ;year to check
    mov r12, 100            ;move 100
    xor rdx, rdx            ; reset rdx
    div r12                 ;divide year by 100
    cmp rdx, 0              ;check if reminder is 0
    je .not_leap_year       ;if it is then not a leap year and jump to not_leap_year

    ; if leap year
    .leap_year:
      mov r13, 1            ;its a flag that saves info about currYear being leap
      cmp r9, 366           ; Check if daysTillNow < 366
      jb .exit_loop
      sub r9, 366           ; Subtract 366 from daysTillNow
      jmp .increment_currYear

    ; else
    .not_leap_year:
      mov r13, 0            ;its a flag that saves info about currYear being not leap
      cmp r9, 365           ; Check if daysTillNow < 365
      jb .exit_loop
      sub r9, 365           ; Subtract 365 from daysTillNow

    .increment_currYear:
      add r10, 1            ; Increment currYear
      jmp .year_loop

  .exit_loop:
  ; currYear is now stored in r10

  mov r8, r9                ; extraDays = daysTillNow
  add r8, 1                 ; + 1

  ; Initialize month to 0
  xor r11, r11

  .month_loop:
    cmp r11, 1              ; Check if month != 1
    jne .not_feb
    cmp r13, 1              ; Check if flag == 1
    je .feb_leap

    .not_feb:
      ; Check if extraDays - days_per_month[index] < 0
      mov rax, [days_per_month + r11 * 8]
      cmp r8, rax
      jl .calculate_date

      add r11, 1            ; month += 1
      sub r8, rax           ; extraDays -= days_per_month[index]
      jmp .month_loop

    .feb_leap:
      cmp r8, 29            ; Check if extraDays - 29 < 0
      jl .calculate_date

      add r11, 1            ; month += 1
      sub r8, 29            ; extraDays -= 29
      jmp .month_loop

.calculate_date:
  cmp r8, 0                 ; Check if extraDays > 0
  jle .handle_zero_extraDays
  add r11, 1                ; month += 1
  mov r12, r8               ; date = extraDays
  jmp .end

; Handle last day of month
.handle_zero_extraDays:
  ; Check if month == 2 and flag == 1
  cmp r11, 2
  jne .handle_not_feb
  cmp r13, 1
  jne .handle_not_feb

  mov r12, 29               ; leap year have 29 days in February
  jmp .end
; Copy days from days_per_month
.handle_not_feb:
  mov r12, [days_per_month + (r11 - 1) * 8] ; date = days_per_month[month - 1]

.end:
  ; Current month and date are now stored in r11 and r12, respectively

; Calculate hour, minute, and second
  mov rax, r15              ; rax = extraTime
  mov rbx, 3600             ; rbx = number of seconds in an hour
  xor rdx, rdx
  div rbx                   ; rax = hours, rdx = remaining seconds
  mov r13, rax              ; hours is now stored in r13

  mov rax, rdx              ; move remaining seconds to rax
  mov rbx, 60               ; rbx = number of minutes in an hour
  xor rdx, rdx              ; reset rdx
  div rbx                   ; rax = minutes, rdx = remaining seconds
  mov r14, rax              ; minutes is now stored in r14
  mov r15, rdx              ; seconds is now stored in r15

  ; Exit
  ret

; Helper function to print a number
print_number:
  ; Save registers
  push rbp
  mov rbp, rsp
  push rbx
  push rcx
  push rdx
  push rsi
  push r11
  push rax

  ; Convert number to string
  lea rsi, [buf + 19]       ; RSI points to the end of the buffer
  mov rax, rdi              ; RAX contains the number to be printed
  mov rbx, 10               ; RBX holds the divisor (base 10)

.convert_loop:
  xor rdx, rdx              ; Clear RDX for division
  div rbx                   ; RAX /= 10, RDX = RAX % 10
  add rdx, '0'              ; Convert remainder to ASCII
  dec rsi                   ; Move buffer pointer back one byte
  mov [rsi], dl             ; Write ASCII character to buffer
  test rax, rax             ; Test if quotient is zero
  jnz .convert_loop         ; If quotient is not zero, continue converting

  ; Print string
  pop rax                   ; Restore file descriptor
  mov rdi, rax              ; File description : rax
  push rax                  ; Save file descriptor
  mov rax, 1                ; Syscall: sys_write
  mov rdx, 19               ; Length: 20 bytes
  sub rdx, rsi              ; Adjust length to only print the relevant characters
  add rdx, buf
  syscall

  ; Restore registers and return
  pop rax
  pop r11
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  mov rsp, rbp
  pop rbp
  ret

; write a single char without having to use a buffer
; void putchar(char c)
putchar:
  ; Save registries to avoid unexpected behaviors
  push rdi
  push rdx
  push rcx
  push rsi
  push r11

  mov [char_buffer], dil    ; store the character in the buffer

  ; print the character to stdout
  mov rdi, rax              ; file descriptor: rax
  push rax
  mov rax, 1                ; system call for write
  mov rsi, char_buffer      ; pointer to the character to be printed
  mov rdx, 1                ; length of the character to be printed
  syscall                   ; invoke the system call

  ; Restore registries
  pop rax
  pop r11
  pop rsi
  pop rcx
  pop rdx
  pop rdi
  ret
