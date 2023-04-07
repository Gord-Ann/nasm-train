section .data
	file_name db 'filee.txt', 0
	msg1 db 'enter your name: '
	msg2 db 'user ', 0
	msg3 db ' is allowed to perform actions in the system.', 0
	newline db 0Ah, 0Dh
	dot db "."
	ddot db ":"
	space db " "

section .bss
	name resb 64
	fd resb 4 ; файловый дескриптор
	info resb 200
	bit1 equ 1<<1 ; оператор сдвига
	bit3 equ 1<<3 ; смещает 1 на 3 бита
	esc resb 36
	sec resb 4
	min resb 4
	hour resb 4
	day resb 4
	days resb 4
	month resb 4
	year resb 4

section .text
	global _start

_start:
	; вывод сообщения "введите имя"
	mov eax, 4 ; sys_write
	mov ebx, 1 ; stdout
	mov ecx, msg1 ; сообщение
	mov edx, 17 ; длина сообщение
	int 0x80 ; прерывание

	; ввод с клавиатуры
	mov eax, 3 ; sys_read
	mov ebx, 0
	mov ecx, name ; буфер
	mov edx, 64 ; размер буфера
	int 0x80
	call delENDL ; удаление последнего символа

	; вывод сообщения "пользователю"
	mov eax, 4 ; sys_write
	mov ebx, 1
	mov ecx, msg2
	mov edx, 6
	int 0x80

	; вывод имени
	mov eax, 4
	mov ebx, 1
	mov ecx, name
	mov edx, 64
	int 0x80

	; вывод сообщения "разрешен доступ"
	mov eax, 4
	mov ebx, 1
	mov ecx, msg3
	mov edx, 45
	int 0x80

	; перенос строки
	mov eax, 4
	mov ebx, 1
	mov ecx, newline
	mov edx, 2
	int 0x80

	; создание файла
	mov eax, 8 
	mov ebx, file_name
	mov ecx, 0666o 
	int 0x80
	mov [fd], eax ; сохранение файлового дескриптора

	; время
	xor ebx, ebx
	mov eax, 13
	int 80h

	; seconds
	xor ebx, ebx
	xor edx, edx
	mov ebx, 60
	div ebx
	mov [sec], edx

	; minutes
	xor edx, edx
	div ebx
	mov [min], edx

	; hours
	xor ebx, ebx
	xor edx, edx
	mov ebx, 24
	div ebx

	; UTC+3
	add edx, 3
	;проверка 24 часа
	cmp edx, 24
	jl .noTimeOverflow
	add eax, 1
	sub edx, 24
.noTimeOverflow:
	mov [hour], edx
	inc eax
	mov [days], eax

	; дни с 1970
	xor r10d, r10d
	xor r8d, r8d
	mov r8d, [days]
	mov r9d, 1970

	; расчет високосного года
.l1:
	mov edi, r9d
	call leap_year ; 0 - не високосный год
	test eax, eax
	jnz .leap
	mov r10d, 0
	sub r8d, 365
	inc r9d
	jmp .l1done
.leap:
	mov r10d, 1
	sub r8d, 366
	inc r9d
.l1done:
	test r10d, r10d
	jz .nl
	cmp r8d, 366
	jmp .l1end
.nl:
	cmp r8d, 365
.l1end:
	jg .l1
	mov [year], r9d
	; осталось дней в году
	xor r9d, r9d ; обнуление счетчика
.l2:
	inc r9d
	cmp r9d, 2
	jne .notFebruary
	mov edi, [year]
	call leap_year
	test eax, eax
	jz .notFebruary
	mov ebx, 29
	jmp .continueSub
.notFebruary:
	mov edi, r9d
	call daysinmonth
	movzx ebx, al
.continueSub:
	sub r8d, ebx
	cmp r8d, 0
	jg .l2
	add r8d, ebx
	mov [month], r9d
	mov [day], r8d

	; преобразование в строку
	mov ebx, 4
	lea esi,[sec]
	call int_to_string

	mov ebx, 4
	lea esi,[min]
	call int_to_string

	mov ebx, 4
	lea esi,[hour]
	call int_to_string

	mov ebx, 4
	lea esi,[day]
	call int_to_string

	mov ebx, 4
	lea esi,[month]
	call int_to_string

	mov ebx, 4
	lea esi,[year]
	call int_to_string

	; запись в файл
	mov eax, 4
	mov ebx, [fd]
	lea ecx, [day+2]
	mov edx, 2
	int 80h

	mov eax, 4
	mov ebx, [fd]
	mov ecx, dot
	mov edx, 1
	int 80h

	mov eax, 4
	mov ebx, [fd]
	lea ecx, [month+2]
	mov edx, 2
	int 80h

	mov eax, 4
	mov ebx, [fd]
	mov ecx, dot
	mov edx, 1
	int 80h

	mov eax, 4
	mov ebx, [fd]
	mov ecx, year
	mov edx, 4
	int 80h

	mov eax, 4
	mov ebx, [fd]
	mov ecx, space
	mov edx, 1
	int 80h

	mov eax, 4
	mov ebx, [fd]
	lea ecx, [hour+2]
	mov edx, 2
	int 80h

	mov eax, 4
	mov ebx, [fd]
	mov ecx, ddot
	mov edx, 1
	int 80h

	mov eax, 4
	mov ebx, [fd]
	lea ecx, [min+2]
	mov edx, 2
	int 80h

	mov eax, 4
	mov ebx, [fd]
	mov ecx, ddot
	mov edx, 1
	int 80h

	mov eax, 4
	mov ebx, [fd]
	lea ecx, [sec+2]
	mov edx, 2
	int 80h

	; закрываем дескриптор
	mov eax, 6
	mov ebx, [fd]
	int 80h

	; открытие файла
	mov eax, 5 ; sys_open
	mov ebx, file_name
	mov ecx, 2
	mov edx, 0666o
	int 80h

	; читаем из файла
	mov eax, 3
	mov ebx, [fd]
	mov ecx, name
	mov edx, 40
	int 80h

	; записываем в файл
	mov eax, 4
	mov ebx, 1
	mov ecx, name
	mov edx, 20
	int 80h

	; закрываем дескриптор
	mov eax, 6
	mov ebx, [fd]
	int 80h

	; вывод даты
	mov eax, 4
	mov ebx, 1
	mov ecx, info
	mov edx, 200
	int 0x80

	; новая строка
	mov eax, 4
	mov ebx, 1
	mov ecx, newline
	mov edx, 2
	int 0x80

	; прослушивание esc
	call off

.esc:
	mov eax, 3
	mov ebx, 0
	mov ecx, name
	mov edx, 1
	int 0x80
	movzx eax, byte [name]
	cmp eax, 0x1B
	jne .esc
	jmp exit

; удаление последнего символа
delENDL:
	xor eax, eax
	mov ebx, name
.top:
	movzx eax, byte [ebx]
	cmp eax, 'A'
	jb .done
	cmp eax, 'z'
	ja .done
	inc ebx
	jmp .top

.done:
        mov byte [ebx], 0
        ret

    ; проверка на високосность
leap_year:
	; делим на 4
	mov rcx, rdi ; год
	and rcx, 0x03
	xor rax, rax
	test rcx, rcx
	jne .done
	; делим на 100
	mov rax, rdi
	xor rdx, rdx
	mov rcx, 100
	div rcx
	not rax
	test rdx, rdx
	jne .done

	; делим на 400
	mov rax, rdi
	xor rdx, rdx
	mov rcx, 400
	div rcx
	xor rax, rax
	test rdx, rdx
	jnz .done
	not rax
.done:
	ret

; количество дней в месяце
daysinmonth:
; > 28 дней?
	mov rax,rdi
	mov ah,al ; число месяца в ah
	shr ah,3 ; сдвиг бита 3 в позицию 0, обнулив все остальные биты
	xor ah,al ; бит маски 0 или 1, в месяце 31 или 30 дней
	and ah,1
	or ah,28
	dec al
	dec al
	or al,0xF0
	dec al
	shr al,3
	and al,2
	or ah,al
	shr ax,8
	ret

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
	cmp ecx, 0
	jne .addZero
	ret

.addZero:
	dec ecx
	dec esi
	mov byte [esi], '0'
	jmp .test

    ; очистить канонический и эхо бит в флагах локального режима
off:
	call read_esc
	and dword [esc+12], ~bit1
	and dword [esc+12], ~bit3
	call write_esc
	ret

    ; установите канонический и эхо бит во флагах локального режима
on:
	call read_esc
	or dword [esc+12], bit1
	or dword [esc+12], bit3
	call write_esc
	ret

read_esc:
	push rbx
	mov eax, 36h
	mov ebx, 0
	mov ecx, 5401h
	mov edx, esc
	int 0x80
	pop rbx
	ret

write_esc:
	push rbx
	mov eax, 36h
	mov ebx, 0
	mov ecx, 5402h
	mov edx, esc
	int 0x80
	pop rbx
	ret

exit:
	call on
	mov eax, 4
	mov ebx, 1
	int 0x80
	mov eax, 1
	int 0x80
