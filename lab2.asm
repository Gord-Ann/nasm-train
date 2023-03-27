section .data

    char_buffer times 1  db 0                     ; буфер для функции putchar

    buffer      times 16 db 0                     ; буфер для ввода и вывода пользователя

    prompt               db "Enter a number: ", 0 ; строка запроса

    answer               db "y = ", 0             ; строка ответа



section .text

    global _start                   ; Точка входа в программу



    ; запись одного символа без использования буфера

      putchar:

    ; сохранение регистров для избежания ошибок 

    push rax

    push rdx

    push rcx

    push rsi



    mov [char_buffer], dil    ; копирование символа в буфер



    ; вывод символа в stdout

    mov rax, 1                ; Системный вызов для записи

    mov rdi, 1                ; файловый дескриптор для stdout

    mov rsi, char_buffer      ; указатель на символ для вывода

    mov rdx, 1                ; длина символа для вывода

    syscall                   ; системный вызов



    ; возвращение регистров

    pop rsi

    pop rcx

    pop rdx

    pop rax

    ret



_start:

    ; вывод строки prompt

    mov rax, 1                ; Системный вызов для записи

    mov rdi, 1                ; файловый дескриптор для stdout

    mov rsi, prompt           ; указатель на строку prompt 

    mov rdx, 16               ; длина строки prompt 

    syscall                   ; системный вызов



    ; чтение ввода пользователя

    mov rax, 0                ; Системный вызов для чтения

    mov rdi, 0                ; файловый дескриптор для stdin

    mov rsi, buffer           ; указатель на буфер для ввода

    mov rdx, 16               ; максимальная длина для ввода

    syscall                   ; системный вызов



    ; парсинг ввода пользователя

    mov rdi, buffer           ; указатель на строку для ввода

    call str_to_num           ; строка парсится в число



    push rax                  ; push X в стек



    ; вывод ответа

    mov rax, 1                ; Системный вызов для записи

    mov rdi, 1                ; файловый дескриптор для stdout

    mov rsi, answer           ; указатель на строку prompt 

    mov rdx, 4                ; длина строки prompt

    syscall                   ; системный вызов



    pop rax                   ; извлечение X из стека



                              ; y = (22-6*x)/8-2

    mov rbx, 6

    imul rbx                  ; rax(x) * rbx(6)

    mov rbx, 22

    sub rbx, rax

    mov rax, rbx

    mov rbx, 8

    idiv rbx                  ; (-rax(x * 6) + 22) / 8

    sub rax, 2                ; (-rax(x * 6) + 22) / 8 - 2



    ; вывод парсированного числа

    mov rdi, rax              ; отправка числа для вывода в  rdi

    call print_num            ; вывод числа в stdout



    ; вывод \n

    mov rdi, 10

    call putchar



    ; выход из программы

    mov eax, 1                ; системный вызов для выхода

    xor rbx, rbx              ; return код 0

    int 0x80                  ; системный вызов





; str_to_num функция считывает строку (которая заканчивается нулем) из указателя как аргумент

; и переводит строку в числовое значение

str_to_num:

    ; инициализация переменных

    xor rax, rax         ; rax = 0

    xor rsi, rsi         ; rsi = 0



    mov rcx, rdi         ; rsi = указатель на строку

    mov dl, [rcx]        ; dl = символ который используется сейчас

    cmp dl, 0            ; проверка пустая ли строка

    je end_of_string     ; есть да то return 0



    ; проверка на -

    cmp dl, '-'          ; проверка если первый символ -

    jne not_negative     ; если нет то пропустить код для отрицательных



    inc rcx              ; переход к следующему символу

    mov dl, [rcx]        ; перевод символа в dl

    mov rsi, 1           ; запись что число отрицательное



not_negative:

    ; парсинг числа

    parse_loop:

        cmp dl, '0'      ; проверка есть символ является числом

        jl end_of_string

        cmp dl, '9'

        jg end_of_string



        imul rax, 10     ; умножение результата на 10

        sub dl, '0'      ; перевод символа в число

        add rax, rdx     ; добавление числа в результат

        inc rcx          ; переход к следующему символу

        mov dl, [rcx]    ; перевод символа в dl

        jmp parse_loop   ; продолжаю парсить



end_of_string:

    cmp rsi, 1           ; если было замечено что число отр. то делаем его отр.

    jne not_netgative_2

    neg rax



not_netgative_2:

    ret





; print_num функция берет int значение в rdi и выводит его в stdout

print_num:

    ; инициализация переменных

    xor rcx, rcx         ; rcx = 0 (счетчик числа символов)

    mov rax, rdi         ; rax = число которое будет выводиться



    cmp rax, 0           ; проверка является ли число 0

    jne not_zero         ; если нет то пропускается код для 0



    mov rdi, '0'

    call putchar



    jmp end_of_print



not_zero:

    ; вывожу знак минус если число отрицательное

    cmp rax, 0



    jg not_neg



    mov rdi, '-'

    call putchar



    neg rax              ; делаю число положительным для вывода



not_neg:



    mov r8, buffer       ; указатель  на буфер

    ; счетчик для числа символов

    read_digits:

        inc rcx          ; счетчик увеличивается на 1

        mov rbx, 10      ; rbx = 10

        xor rdx, rdx     ; установка остатка на 0 

        div rbx          ; деление rax числа на 10



        add dl, '0'      ; перевод числа в  ASCII символ



        mov [r8], rdx    ; сохранение символа в буфер

        inc r8           ; переход на следующий адрес в буфере



        test rax, rax    ; проверка если результат деления 0

        jnz read_digits ; если нет то продолжаю считать символы





print_number:

    mov r8, buffer       ; укзатель на буфер

    add r8, rcx          ; буфер + размер строки - 1

    dec r8



    ; вывод чисел

    print_digits:

        mov dil, [r8]    ; считывание числа из буфера

        call putchar     ; вызов putchar

        dec r8           ; переход на предыдущий адрес в буфере



        dec rcx          ; уменьшение счетчика на 1

        cmp rcx, 0       ; проверка если счетчик равен 0

        jg print_digits  ; если нет то продолжаю выводить числа



end_of_print:

    ret