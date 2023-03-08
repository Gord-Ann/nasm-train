section .data
    char_buffer times 1  db 0                     ; buffer for the putchar function
    buffer      times 16 db 0                     ; buffer to hold the user input & output
    prompt               db "Enter a number: ", 0 ; Prompt string
    answer               db "Y = ", 0             ; Answer string

section .text
    global _start                   ; Entrypoint

; write a single char without having to use a buffer
; void putchar(char c)
putchar:
    ; Save registries to avoid unexpected behaviors
    push rax
    push rdx
    push rcx
    push rsi

    mov [char_buffer], dil    ;

    ; print the character to stdout
    mov rax, 1                ; system call for write
    mov rdi, 1                ; file descriptor for stdout
    mov rsi, char_buffer      ; pointer to the character to be printed
    mov rdx, 1                ; length of the character to be printed
    syscall                   ; invoke the system call

    ; Restore registries
    pop rsi
    pop rcx
    pop rdx
    pop rax
    ret

_start:
    ; Print the prompt
    mov rax, 1                ; system call for write
    mov rdi, 1                ; file descriptor for stdout
    mov rsi, prompt           ; pointer to the prompt string
    mov rdx, 16               ; length of the prompt string
    syscall                   ; invoke the system call

    ; Read the user input
    mov rax, 0                ; system call for read
    mov rdi, 0                ; file descriptor for stdin
    mov rsi, buffer           ; pointer to the buffer for the input
    mov rdx, 16               ; maximum length of the input
    syscall                   ; invoke the system call

    ; Parse the user input
    mov rdi, buffer           ; pointer to the input string
    call str_to_num           ; parse the string into a number

    push rax                  ; push X to the stack

    ; Print the prompt
    mov rax, 1                ; system call for write
    mov rdi, 1                ; file descriptor for stdout
    mov rsi, answer           ; pointer to the prompt string
    mov rdx, 4                ; length of the prompt string
    syscall                   ; invoke the system call

    pop rax                   ; recover X from the stack

    ; y = 4*x-3 x<8
    ; y = x*3-7 x>8
    ; y = x+1 x=8
    cmp rax, 8      
    jl less
    cmp rax, 8
    jg more
    add rax, 1
    jmp done

less:
    mov rbx, 4
    imul rbx
    add rax, -3
    jmp done
more:
    mov rbx, 3
    imul rbx
    add rax, -7
    jmp done
done:
    ; Print the parsed number
    mov rdi, rax              ; move the number to be printed into rdi
    call print_num            ; print the number to stdout

    ; Print \n
    mov rdi, 10
    call putchar

    ; Exit the program
    mov eax, 1                ; system call for exit
    xor rbx, rbx              ; return code of 0
    int 0x80                  ; invoke the system call



; str_to_num function takes a pointer to a null-terminated string as an argument
; and returns the integer value of the string.
; long str_to_num(char *buffer)
str_to_num:
    ; Save the base pointer and stack pointer
    push rbp
    mov rbp, rsp

    ; Initialize the variables
    xor rax, rax         ; rax = 0
    ; is negative
    xor rsi, rsi         ; rsi = 0
    mov rcx, rdi         ; rsi = pointer to the string
    mov dl, [rcx]        ; bl = current character
    cmp dl, 0            ; Check if the string is empty
    je end_of_string     ; If so, return 0

    ; Check for a negative sign
    cmp dl, '-'          ; Check if the first character is a negative sign
    jne not_negative     ; If not, skip the negative sign code

    inc rcx              ; Move to the next character
    mov dl, [rcx]        ; Get the next character
    mov rsi, 1           ;

not_negative:
    ; Parse the number
    parse_loop:
        cmp dl, '0'      ; Check if the character is a digit
        jl end_of_string
        cmp dl, '9'
        jg end_of_string

        imul rax, 10     ; Multiply the result by 10
        sub dl, '0'      ; Convert the character to a digit
        add rax, rdx     ; Add the digit to the result
        inc rcx          ; Move to the next character
        mov dl, [rcx]    ; Get the next character
        jmp parse_loop   ; Continue parsing the number

end_of_string:
    cmp rsi, 1
    jne not_netgative_2
    neg rax

not_netgative_2:
    ; Restore the base pointer and stack pointer
    pop rbp
    ret


; print_num function takes an integer value in rdi and prints it to stdout
; void print_num(long number)
print_num:
    ; Initialize the variables
    xor rcx, rcx         ; rcx = 0 (counter for the number of digits)
    mov rax, rdi         ; rax = the number to be printed
    cmp rax, 0           ; Check if the number is zero
    jne not_zero         ; If not, skip the zero code

    mov rdi, '0'
    call putchar

    jmp end_of_print

not_zero:
    ; Print the negative sign if the number is negative
    cmp rax, 0

    jg not_neg

    mov rdi, '-'
    call putchar

    neg rax              ; Negate the result to make it positive

not_neg:

    mov r8, buffer       ; pointer to string buffer
    ; Count the number of digits
    count_digits:
        inc rcx          ; Increment the digit counter
        mov rbx, 10      ; rbx = 10
        xor rdx, rdx     ; reset remainder to 0 (floating point exception)
        div rbx          ; Divide rax number by 10

        add dl, '0'      ; Convert the digit to an ASCII character

        mov [r8], rdx
        inc r8

        test rax, rax    ; Check if the quotient is zero
        jnz count_digits ; If not, continue counting digits


print_number:
    mov r8, buffer       ; pointer to string buffer
    add r8, rcx          ; buffer + size of string - 1
    dec r8

    ; Print the digits
    print_digits:
        mov dil, [r8]    ; Pass char from buffer
        call putchar     ; putchar
        dec r8           ; Move pointer to previous character

        dec rcx          ; Decrement the digit counter
        cmp rcx, 0       ; Check if the counter is zero
        jg print_digits  ; If not, continue printing digits

end_of_print:
    ret
