.model SMALL
.368
.stack 100h
.data
		Message db 'Hello, <Anna Konoshenko>'
.code

start:
		mov ax, @data
		mov ds, ax
		
		mov dx, offset Message
		mov ah, 9h
		int 21h
		
		mov ah, 8h
		int 21h
		
		mov ah, 4Ch
		mov al, 00h
		int 21h
		
end start 