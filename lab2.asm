

section .data
    message1 db 'Enter integer: ', 0xA, 0xD 
    length1 equ $-message1
    message2 db 'Result is: ' 
    length2 equ $-message2
    
    delimeter db ','
    delimeter_len equ $-delimeter
    
    endline db 0xA, 0xD 
    endline_len equ $-endline
    
    STDIN equ 0
    STDOUT equ 1
    SYS_EXIT equ 1
    SYS_WRITE equ 4
    SYS_READ  equ 3
    
section .bss    
    input1 resb 10 ; прочитанные данные для первого числа будут сохранены здесь
    result resb 10 ; целая часть решения
    result_left resb 10  ;  дробная часть решения

section .text
    global _start

_start:
    ; выводим сообщение на экран, запрашивая первое число
    mov eax, SYS_WRITE 
    mov ebx, STDOUT
    mov ecx, message1
    mov edx, length1
    int 0x80

    ; считываем первое число
    mov eax, SYS_READ ; функция для чтения с клавиатуры
    mov ebx, STDIN ; дескриптор стандартного ввода (клавиатура)
    mov ecx, input1 ; буфер для сохранения введенных данных
    mov edx, 16 ; количество байт для чтения (1 байт числа + символ перевода строки)
    int 0x80
    
    lea edx, [input1]
    call string_to_int
    mov [input1], eax
    
    mov eax, SYS_WRITE 
    mov ebx, STDOUT
    mov ecx, message2
    mov edx, length2
    int 0x80
     
    mov eax, [input1] ; 2 + 3 * x
    mov ebx, 3
    mul ebx
    mov ecx, 2
    add ecx, eax
    
    mov eax, ecx ; eax/5
    mov ebx, 5
    div ebx
    mov [result], eax
    mov [result_left], edx 
    
   
    ; переводим в строку целую часть ответа
      
    mov eax, [result]
    mov [result], byte 0
    lea esi, [result]
    call int_to_string
   
    ; выводим целую часть
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, result
    mov edx, 16 ; 
    int 0x80
    
    ; выводим запятую
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, delimeter
    mov edx, delimeter_len 
    int 0x80
    
    ; переводим переводим дробную часть ответа
      
    mov eax, [result_left]
    mov [result_left], byte 0
    lea esi, [result_left]
    call int_to_string
   
    ; выводим дробную часть на экран
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, result_left
    mov edx, 16 ; 
    int 0x80
    
    ; Конец строки
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, endline
    mov edx, endline_len 
    int 0x80
    
  
    mov eax, SYS_EXIT
    mov ebx, 0
    int 80h
    
string_to_int:
    xor eax, eax ; "
    .next_char:
    movzx ecx, byte [edx] ; get a character
    inc edx ; ready for next one
    cmp ecx, '0' ; valid?
    jb .done
    cmp ecx, '9'
    ja .done
    sub ecx, '0' ; 
    imul eax, 10 ; 
    add eax, ecx ;
    jmp .next_char ;
.done:
    ret
    
    
; Input:
; EAX = integer value to convert
; ESI = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; EAX = pointer to the first character of the generated string

int_to_string:
    add esi,9
  mov byte [esi], 0

  mov ebx,10         
.next_digit:
  xor edx,edx         ; Clear edx prior to dividing edx:eax by ebx
  div ebx             ; eax /= 10
  add dl,'0'          ; Convert the remainder to ASCII 
  dec esi             ; store characters in reverse order
  mov [esi],dl
  test eax,eax            
  jnz .next_digit     ; Repeat until eax==0
  mov eax,esi
  ret
    
