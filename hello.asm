SECTION .data               ; Начало секции данных
    hello:    DB 'Hello Polina', 10
    helloLen: EQU $-hello   ; длина строки 'Hello'

SECTION .text               ; Начало секции кода
    GLOBAL _start

_start:                     ; Точка входа в программу
    mov rax, 4              ; Системный вызов для записи
    mov rdi, 1              ; Описатель файла $1$ - стандартный вывод
    mov rsi, hello          ; Адрес строки hello в ecx
    mov rdx, helloLen       ; Размер строки hello
    int 80h                 ; Вызов ядра
    mov rax, 1              ; Системный вызов для выхода (sys_exit)
    mov rdi, 0              ; Выход с кодом возврата $0$ (без ошибок)
    int 80h                 ; Вызов ядра
