SECTION .data
	mes:	DB 'Hello, Yakovlev Nikita',0x0A
	mesLen:	EQU $-mes
	
SECTION .text
	GLOBAL _start
	
_start:
	mov eax,4
	mov ebx,1
	mov ecx,mes
	mov edx,mesLen
	int 80h
	mov eax,1
	mov ebx,0
	int 80h
