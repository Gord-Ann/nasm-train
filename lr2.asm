SYS_EXIT  equ 1
SYS_READ  equ 3
SYS_WRITE equ 4
STDIN     equ 0
STDOUT    equ 1

segment .data 

   msg1 db "Enter a digit ", 0xA,0xD 
   len1 equ $- msg1 


   msg2 db "Result is: "
   len2 equ $- msg2

   ; Склад костылей?
   int1: db 33
   int2: db 12
   int3: db 2
   int4: db 5
   int5: db 3

segment .bss

   num1 resb 2 
   res resb 3

section .text
   global _start            ;must be declared for using gcc


_start:                     ;tell linker entry point
   mov ebp, esp             ; for correct debugging             
   mov eax, SYS_WRITE         
   mov ebx, STDOUT         
   mov ecx, msg1         
   mov edx, len1 
   int 0x80                

   mov eax, SYS_READ 
   mov ebx, STDIN  
   mov ecx, num1 
   mov edx, 2
   int 0x80                  
                            ; ((33 / x) + 12 * 2 + 5) / (3 * x)
   xor edx, edx
   xor eax, eax
   xor ebx, ebx
   mov ax, [int1]
   and ax, 0xff
   mov bx, [num1]
   and bx, 0xff
   sub bx, '0'               ; (33 / x)

   div bx ; 

   push ax                   ; save to stack
   xor eax,eax
   xor ebx, ebx
   mov ax, [int2]
   and ax, 0xff
   mov bx, [int3]
   and bx, 0xff
  
   mul bx                    ; 12 * 2
   
   xor ecx, ecx
   pop cx                    ; take from stack
   add ax, cx                ; (33/x) + (12 * 2)

   xor ecx, ecx
   mov cx, [int4]
   and cx, 0xff
   add ax, cx                ; (33/x) + (12 * 2) + 5 should be 40
   push ax                   ; save to stack

   xor eax, eax
   xor ebx, ebx
   mov ax, [int5] 
   and ax, 0xff
   mov bx, [num1]
   and bx, 0xff
   sub bx, '0'
   mul bx                    ; (3 * x)

   xor edx, edx
   xor ebx, ebx
   mov bx, ax
   pop ax                    ; take from stack
   div bx                    ; ((33/x) + (12 * 2) + 5)/(3 * x)

   mov [res], ax                 

   lea esi, [res]            ; get effective address

   call int_to_string        ; call procedure

   mov ecx, eax ; "begin print" position
   xor edx, edx
getlen:
   cmp byte [ecx + edx], 10
   jz gotlen
   inc edx
   jmp getlen
gotlen:
   inc edx
   mov eax, 4
   mov ebx, 1
   int 0x80

  mov eax, 1
  mov ebx, 0
  int 0x80

int_to_string:
  add esi, 9
  mov word [esi], 10
  mov ebx, 10         

.next_digit:
  xor edx, edx       
  div ebx             
  add dl, '0'         
  dec esi             
  mov [esi],dl
  test eax, eax           
  jnz .next_digit
  mov eax, esi
  ret

exit:    
   
   mov eax, SYS_EXIT   
   xor ebx, ebx 
   int 0x80
