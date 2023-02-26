    section .data
    msg1 db "Enter a number x: ", 0
    msg2 db "y = ", 0
    newline db 0Ah, 0Dh

    section .bss
    x resb 1
    y resb 1

    section .text
    global _start

    _start:
    ; Выводим на экран сообщение "Enter a number x: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 17
    int 0x80

    ; Читаем число x с клавиатуры
    mov eax, 3
    mov ebx, 0
    mov ecx, x
    mov edx, 1
    int 0x80

    ; Конвертируем символ в число
    sub byte [x], '0'

    ; Вычисляем y
    mov al, 2
    mul byte [x]
    mov bl, 2
    add bl, byte [x]
    div bl
    mov cl, al

    mov al, 3
    mul byte [x]
    mov bl, 3
    sub bl, 1
    div bl
    mov dl, al

    add cl, dl

    mov al, 4
    mul byte [x]
    mov bl, 4
    div bl
    mov dl, al

    add cl, dl

    add cl, '0'
    mov byte [y], cl

    ; Выводим на экран сообщение "y = " и значение y
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, 4
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, y
    mov edx, 1
    int 0x80

    ; Выводим перевод строки
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 2
    int 0x80

    ; Завершаем программу
    mov eax, 1
    xor ebx, ebx
    int 0x80

Ещё

