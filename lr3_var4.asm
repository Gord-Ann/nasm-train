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


_start:
    mov rbp, rsp; for correct debugging                     ;tell linker entry point
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
   int 0x80                 ; 4 var
                            ; (x-3)*2 if x > 3
                            ; 5 * x if x < 3
                            ; 2 + x if x = 3
   
   xor edx, edx
   xor eax, eax
   xor ebx, ebx
   mov eax, [num1]
   and eax, 0xff
   sub eax, '0'               

   cmp eax, 3
   jg .isgreater
   jl .isless
   je .isequal

.isgreater:                     ; (x-3)*2
   sub eax, 3
   xor ebx, ebx
   mov ebx, 2
   mul ebx

   jmp .output
.isless:                       
   xor ebx, ebx                 ; 5 * x
   mov ebx, 5
   mul ebx
   jmp .output
.isequal:                       ; 2 + x 
   add eax, 2
   jmp .output

.output:
   mov [res], eax                 

   lea esi, [res]

   call int_to_string
   mov ecx, eax
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
