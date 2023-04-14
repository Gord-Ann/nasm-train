section .data

  prompt:               db "Please enter your name: ", 0

  msg:                  db "User ", 0

  allowed:              db " is allowed to perform actions in the system", 10, 0

  filename:             db "file.txt", 0

  days_per_month:       dq 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ; дни в месяцах





section .bss

  termios_original: resb 24 ; начальные настройки терминала 

  termios_raw:      resb 24 ; измененные настройки терминала

  char_buffer:      resb 1  ; буфер для функции putchar 

  buf:              resb 64 ; буфер ввода и вывода



section .text

  global _start



_start:

  ; Вывод "please enter your name"

  mov rax, 1            ;дескриптор вывода

  mov rdi, 1            

  ;lea rsi, [prompt]    

  mov rsi, prompt

  mov rdx, 24           ; сколько печатать символов

  syscall               



  ; Чтение ввода пользователя

  mov rax, 0            ;дескриптор чтения

  mov rdi, 0            

  lea rsi, [buf]        

  mov rdx, 64           

  syscall               

  mov r8, rax           ;r8 = количество прочитанных байтов

  dec r8                ;убрать последний символ



  ; Вывод "User "

  mov rax, 1            

  mov rdi, 1            

  lea rsi, [msg]        

  mov rdx, 5            

  syscall               



  ; Вывод имени пользователя

  mov rax, 1            

  mov rdi, 1            

  lea rsi, [buf]       

  mov rdx, r8           

  syscall               



  ; Вывод " is allowed to perform actions in the system"

  mov rax, 1            

  mov rdi, 1            

  lea rsi, [allowed]    

  mov rdx, 45           

  syscall               



  ; Получение времени системным вызовом с номером 201

  mov rax, 201          

  lea rdi, [buf]        ;время в буфер

  syscall               



  ; Перевод времени

  mov rdi, rax              ; rdi = timestamp

  call breakdown_timestamp  ; r10 = год, r11 = месяц, r12 = день, r13 = часы, r14 = минуты, r15 = секунды



  push r11                  

  mov rax, 2                ; Открыть файл

  lea rdi, [filename]       ; Имя файла

  mov rsi, 0102             ; O_RDWR | O_CREAT

  mov rdx, 0666o            ; Права доступа -rw-rw-rw-

  syscall

  pop r11                   



  ; Запись в файл

  mov rsi, rax              ; сохраняем id файла

  mov rdi, r12              ; день

  call print_number         ; выводим день

  mov rdi, '.'

  call putchar

  mov rdi, r11

  call print_number         ; выводим месяц

  mov rdi, '.'

  call putchar

  mov rdi, r10

  call print_number         ; выводим год



  mov rdi, ' '

  call putchar



  mov rdi, r13

  call print_number         ; выводим часыы

  mov rdi, ':'

  call putchar

  mov rdi, r14

  call print_number         ; выводим минуты

  mov rdi, ':'

  call putchar

  mov rdi, r15

  call print_number         ; выводим секунды



  ; Close file

  push r11                  

  mov rax, 3                ; Закрываем файл

  mov rdi, rsi              ; id файла

  syscall

  pop r11                   



  ; Вывод на экран

  mov rax, 1

  mov rdi, r12              

  call print_number         ; Выводим дни

  mov rdi, '.'

  call putchar

  mov rdi, r11

  call print_number         ; Выводим месяц

  mov rdi, '.'

  call putchar

  mov rdi, r10

  call print_number         ; Выводим год



  mov rdi, ' '

  call putchar



  mov rdi, r13

  call print_number         ; Выводим часы

  mov rdi, ':'

  call putchar

  mov rdi, r14

  call print_number         ; Выводим минуты

  mov rdi, ':'

  call putchar

  mov rdi, r15

  call print_number         ; Выводим секунды





  ; Отключение канонического режима (без буферизации)

  ; Сохранение настроек терминала

  mov rax, 16               ; sys_ioctl

  mov rdi, 0                ; stdin

  mov rsi, 0x5401           ; TCGETS

  lea rdx, [termios_original]

  syscall



  ; Копирование настроек в termios_raw и их изменение режима raw

  lea rsi, [termios_original]

  lea rdi, [termios_raw]

  mov rcx, 24

  cld                               ; Очистка флага направление

  rep movsb

  ; отключение ECHO, ICANON и других флагов

  and word [termios_raw+12], 0xFFA0 ; termios_raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG)

  ; Установка минимального количества байтов для чтения и тайм-аута на 0

  mov byte [termios_raw+6], 0       ; termios_raw.c_cc[VMIN] = 0

  mov byte [termios_raw+7], 0       ; termios_raw.c_cc[VTIME] = 0



  ; Установка терминала в нужном режиме

  mov rax, 16               ; sys_ioctl

  mov rdi, 0                ; stdin

  mov rsi, 0x5402           ; TCSETS

  lea rdx, [termios_raw]

  syscall



  ; До тех пор пока клавижа ESC не будет нажата

wait_for_esc:

  mov rax, 0                

  mov rdi, 0                

  lea rsi, [buf]            

  mov rdx, 1                ; чтение 1 символа

  syscall



  cmp byte [buf], 0x1B      ; Сравнение кода прочитанного символа с кодом ESC

  jne wait_for_esc



  ; RВосстановление настроек терминала

  mov rax, 16               ; sys_ioctl

  mov rdi, 0                ; stdin

  mov rsi, 0x5401           ; TCGETS

  lea rdx, [termios_original]

  syscall



  ; выход из программы

  mov rax, 60

  xor rdi, rdi

  syscall



breakdown_timestamp:

  ; Конвертация Unix timestamp из rdi в нужный формат. Время получаем в виде секунд с 1970 года и до нулевого часового пояса

  ; Результат в r10 (год), r11 (месяц), r12 (день), r13 (часы), r14 (минуты), r15 (секунды)



  ; ; Вычисление числа дней и секунд

  mov rax, rdi              ; rax = секунды прошедшие с 1970

  mov rbx, 24*60*60         ; rbx = секунд в дне

  xor rdx, rdx              ; reset rdx

  div rbx                   ; количество секунд с 1970 года/количество секунд в сутках (rax = daysTillNow, rdx = extraTime)

  mov r9, rax               ; количество дней

  mov r15, rdx              ; секунды

  mov r10, 1970             ; год



  ; Вычислите currYear, вычитая 365 или 366 дней из daysTillNow

    ; Проверка високосного года

    ; (currYear % 400 == 0)

    mov rax, r10            ; 1970 в цикл

    mov r12, 400           

    xor rdx, rdx            ; reset rdx

    div r12                 ; проверка года делением на 400 чтоб узнать високосный ли год

    cmp rdx, 0              ; проверка равенству остатка 0

    je .leap_year           ; если год високосный то jump to leap_year func



    ; (currYear % 4 == 0)

    mov rax, r10            ; проверка года

    mov r12, 4              ; добавление значения 4

    xor rdx, rdx            ; reset rdx

    div r12                 ; деление года на 4

    cmp rdx, 0              ; проверка остатка равенству 0

    jne .not_leap_year      ; иначе jump to not_leap_year

    ;  && currYear % 100 != 0)

    mov rax, r10            

    mov r12, 100            

    xor rdx, rdx            

    div r12                 ; деление года на 100

    cmp rdx, 0              ; проверка остатка равенству 0

    je .not_leap_year       ; иначе jump to not_leap_year

    

    ; Если год високосный

    .leap_year:

      mov r13, 1            ; флаг который високосный год ставит в 1

      cmp r9, 366           ; проверка до тех пор пока daysTillNow < 366

      jb .exit_loop

      sub r9, 366           ; вычитание 366 из daysTillNow

      jmp .increment_currYear



    ; Иначе

    .not_leap_year:

      mov r13, 0            ; не високосный = флаг 0

      cmp r9, 365           

      jb .exit_loop

      sub r9, 365           ; вычитание 365 из daysTillNow



    .increment_currYear:

      add r10, 1            ; следующий год

      jmp .year_loop



  .exit_loop:

  ; currYear в r10



  mov r8, r9                ; extraDays = daysTillNow

  add r8, 1                 ; + 1



  ; Initialize month to 0

  xor r11, r11



  .month_loop:

    cmp r11, 1              ; Проверка февраля

    jne .not_feb

    cmp r13, 1              ; Проверка високосности

    je .feb_leap



    .not_feb:

      ; Условие перехода к вычислению текущего числа  extraDays - days_per_month[index] < 0

      mov rax, [days_per_month + r11 * 8]

      cmp r8, rax

      jl .calculate_date



      add r11, 1            ; month += 1

      sub r8, rax           ; extraDays -= days_per_month[index]

      jmp .month_loop



    .feb_leap:

      cmp r8, 29            ; Проверка extraDays - 29 < 0

      jl .calculate_date



      add r11, 1            ; month += 1

      sub r8, 29            ; extraDays -= 29

      jmp .month_loop



.calculate_date:

  cmp r8, 0                 ; Проверка extraDays > 0

  jle .handle_zero_extraDays

  add r11, 1                ; month += 1

  mov r12, r8               ; date = extraDays

  jmp .end



; обработка последнего дня месяца, т.к. если день последний, мы вычтем из него все дни в предыдущем цикле



.handle_zero_extraDays:

  ; Проверка месяц == 2 и флаг == 1

  cmp r11, 2

  jne .handle_not_feb

  cmp r13, 1

  jne .handle_not_feb



  mov r12, 29               ; в високосном году 29 дней в феврале

  jmp .end

  

; копирование дней из days_per_month

.handle_not_feb: ;handle_not_leap_feb

  mov r12, [days_per_month + (r11 - 1) * 8] ; date = days_per_month[month - 1]



.end:

  ; Настоящий месяц и дата в r11 и r12



  ; Вычисление часов, минут, секунд

  mov rax, r15              ; rax = extraTime

  mov rbx, 3600             ; rbx = секунд в часе

  xor rdx, rdx

  div rbx                   

  add rax, 3		    ; московское время = полученное по нулевому часовому поясу + 3 часа

  mov r13, rax              ; часы в r13



  mov rax, rdx              ; оставшиеся секудны в rax

  mov rbx, 60               ; rbx = число минут в часе

  xor rdx, rdx              ; reset rdx

  div rbx                   ; rax = минуты, rdx = оставшиеся секунды

  mov r14, rax              ; минуты в r14

  mov r15, rdx              ; секунды в r15



  ; Выход 

  ret



; функция для вывода number

print_number:

  ; сохранение регистров

  push rbp

  mov rbp, rsp

  push rbx

  push rcx

  push rdx

  push rsi

  push r11

  push rax



  ; конвертация числа в строку

  lea rsi, [buf + 19]       ; RSI указывает на конец буфера

  mov rax, rdi              ; RAX содержит номер для вывода

  mov rbx, 10               ; RBX содержит делитель (10)



.convert_loop:

  xor rdx, rdx              

  div rbx                   ; RAX /= 10, RDX = RAX % 10

  add rdx, '0'              ; преобразование остатка в ASCII

  dec rsi                   ; перемещение указатель буфера назад на один байт

  mov [rsi], dl             ; запись ASCII символов буффера

  test rax, rax             ; проверка равенства нулю

  jnz .convert_loop         ; если не равно нулю, то продолжить конвертацию



  ; вывод строки

  pop rax                   ; восстановление файлового дескриптора

  mov rdi, rax              ; файловый дескриптор : rax

  push rax                  ; сохранение файлового дескриптора

  mov rax, 1                ; Syscall: sys_write

  mov rdx, 19               ; длина 20 байтов

  sub rdx, rsi              ; Регулировка длины, чтобы был вывод только соответствующих символов

  add rdx, buf

  syscall



  ; восстановление регистров

  pop rax

  pop r11

  pop rsi

  pop rdx

  pop rcx

  pop rbx

  mov rsp, rbp

  pop rbp

  ret



; ; запись одного символа без использования буфера

; void putchar(char c)

putchar:

  ; сохранение регистров 

  push rdi

  push rdx

  push rcx

  push rsi

  push r11



  mov [char_buffer], dil    ; сохранение символа в буфере



  ; print the character to stdout

  mov rdi, rax              ; дескриптор файла rax

  push rax

  mov rax, 1                ; системный вызов для записи

  mov rsi, char_buffer      ; указатель на символ, который нужно вывести

  mov rdx, 1                ; длина символа, который нужно вывести

  syscall                   ; вызов системного вызова



  ; восстановление регистров

  pop rax

  pop r11

  pop rsi

  pop rcx

  pop rdx

  pop rdi

  ret

