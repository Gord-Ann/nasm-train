{\rtf1\ansi\ansicpg1251\cocoartf2707
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 section .data\
  	msg1 db "Enter a number x:", 0\
  	len1 equ $-msg1\
  	msg2 db "y = ", 0\
  	len2 equ $-msg2\
  	newline db 0Ah, 0Dh\
\
  section .bss\
  	x resb 10\
  	y resb 10\
\
  section .text\
  	global _start\
\
  _start:\
  	; \uc0\u1042 \u1099 \u1074 \u1086 \u1076 \u1080 \u1084  \u1085 \u1072  \u1101 \u1082 \u1088 \u1072 \u1085  \u1089 \u1086 \u1086 \u1073 \u1097 \u1077 \u1085 \u1080 \u1077  "Enter a number x: "\
  	mov eax, 4\
  	mov ebx, 1\
  	mov ecx, msg1\
  	mov edx, len1\
  	int 0x80\
\
  	; \uc0\u1063 \u1080 \u1090 \u1072 \u1077 \u1084  \u1095 \u1080 \u1089 \u1083 \u1086  x \u1089  \u1082 \u1083 \u1072 \u1074 \u1080 \u1072 \u1090 \u1091 \u1088 \u1099 \
  	mov eax, 3\
  	mov ebx, 0\
  	mov ecx, x\
  	mov edx, 10\
  	int 0x80\
\
  	; \uc0\u1050 \u1086 \u1085 \u1074 \u1077 \u1088 \u1090 \u1080 \u1088 \u1091 \u1077 \u1084  \u1074  \u1095 \u1080 \u1089 \u1083 \u1086 \
  	lea ebx, [x]\
  	call str_to_int\
  	mov [x], eax\
\
    ;\uc0\u1089 \u1088 \u1072 \u1074 \u1085 \u1080 \u1090 \u1100  \u1093  \u1080  \u1094 \u1080 \u1092 \u1088 \u1091  5\
    ;\uc0\u1087 \u1077 \u1088 \u1077 \u1093 \u1086 \u1076  \u1085 \u1072  \u1084 \u1077 \u1090 \u1082 \u1080  \u1073 \u1086 \u1083 \u1100 \u1096 \u1077 , \u1084 \u1077 \u1085 \u1100 \u1096 \u1077 , \u1088 \u1072 \u1074 \u1085 \u1086 \
  	cmp eax, 5\
    jg .greater\
    jl .less\
    je .eq\
\
    ;\uc0\u1074 \u1099 \u1095 \u1080 \u1089 \u1083 \u1077 \u1085 \u1080 \u1103  \u1076 \u1083 \u1103  \u1073 \u1086 \u1083 \u1100 \u1096 \u1077 \
    .greater:\
    mov eax, 2\
    mov ebx, [x]\
    mul ebx\
    sub ebx, 5\
    add eax, ebx\
    \
    ;\uc0\u1076 \u1074 \u1080 \u1075 \u1072 \u1077 \u1084  \u1089 \u1086 \u1076 \u1077 \u1088 \u1078 \u1080 \u1084 \u1086 \u1077  \u1088 \u1077 \u1075 \u1080 \u1089 \u1090 \u1088 \u1086 \u1074  \u1080  \u1087 \u1088 \u1099 \u1075 \u1072 \u1077 \u1084  \u1085 \u1072  \u1074 \u1099 \u1093 \u1086 \u1076 \
    mov ecx, eax\
  	mov [y], ecx\
    jmp .exit\
    \
    ;\uc0\u1074 \u1099 \u1095 \u1080 \u1089 \u1083 \u1077 \u1085 \u1080 \u1103  \u1076 \u1083 \u1103  \u1084 \u1077 \u1085 \u1100 \u1096 \u1077 \
    .less\
    mov eax, 4\
    mov ebx, [x]\
    mul ebx\
    \
    mov ecx, eax\
  	mov [y], ecx\
    jmp .exit\
\
    ;\uc0\u1074 \u1099 \u1095 \u1080 \u1089 \u1083 \u1077 \u1085 \u1080 \u1103  \u1076 \u1083 \u1103  \u1088 \u1072 \u1074 \u1085 \u1086     \
    .eq\
    mov eax, [x]\
\
    mov ecx, eax\
  	mov [y], ecx\
  	jmp .exit\
\
  	; \uc0\u1042 \u1099 \u1074 \u1086 \u1076 \u1080 \u1084  \u1085 \u1072  \u1101 \u1082 \u1088 \u1072 \u1085  \u1089 \u1086 \u1086 \u1073 \u1097 \u1077 \u1085 \u1080 \u1077  "y = " \u1080  \u1079 \u1085 \u1072 \u1095 \u1077 \u1085 \u1080 \u1077  y\
  	.exit: \
  	mov eax, 4\
  	mov ebx, 1\
  	mov ecx, msg2\
  	mov edx, len2\
  	int 0x80\
\
  	; \uc0\u1050 \u1086 \u1085 \u1074 \u1077 \u1088 \u1090 \u1080 \u1088 \u1091 \u1077 \u1084  \u1095 \u1080 \u1089 \u1083 \u1086  \u1074  \u1089 \u1090 \u1088 \u1086 \u1082 \u1091  \u1080  \u1089 \u1086 \u1093 \u1088 \u1072 \u1085 \u1103 \u1077 \u1084  \u1077 \u1075 \u1086  \u1074  y\
  	mov eax, [y]\
  	mov [y], byte 0\
  	lea esi, [y]\
  	call int_to_str\
\
  	mov eax, 4\
  	mov ebx, 1\
  	mov ecx, y\
  	mov edx, 10\
  	int 0x80\
\
  	; \uc0\u1042 \u1099 \u1074 \u1086 \u1076 \u1080 \u1084  \u1087 \u1077 \u1088 \u1077 \u1074 \u1086 \u1076  \u1089 \u1090 \u1088 \u1086 \u1082 \u1080 \
  	mov eax, 4\
  	mov ebx, 1\
  	mov ecx, newline\
  	mov edx, 2\
  	int 0x80 \
\
  	; \uc0\u1047 \u1072 \u1074 \u1077 \u1088 \u1096 \u1072 \u1077 \u1084  \u1087 \u1088 \u1086 \u1075 \u1088 \u1072 \u1084 \u1084 \u1091 \
  	mov eax, 1\
  	mov ebx, 0\
  	int 0x80\
  	\
  str_to_int: \
  	xor eax, eax \
  	.next_char:\
  	movzx ecx, byte [ebx] \
  	inc ebx ; \uc0\u1091 \u1074 \u1077 \u1083 \u1080 \u1095 \u1080 \u1074 \u1072 \u1077 \u1084  \u1091 \u1082 \u1072 \u1079 \u1072 \u1090 \u1077 \u1083 \u1100 \
  	cmp ecx, '0' ; \uc0\u1074 \u1099 \u1093 \u1086 \u1076  \u1080 \u1079  \u1094 \u1080 \u1082 \u1083 \u1072  \u1077 \u1089 \u1083 \u1080  \u1079 \u1085 \u1072 \u1095 \u1077 \u1085 \u1080 \u1077  \u1084 \u1077 \u1085 \u1100 \u1096 \u1077 \
  	jb .done\
  	cmp ecx, '9' ; \uc0\u1074 \u1099 \u1093 \u1086 \u1076  \u1080 \u1079  \u1094 \u1080 \u1082 \u1083 \u1072  \u1077 \u1089 \u1083 \u1080  \u1079 \u1085 \u1072 \u1095 \u1077 \u1085 \u1080 \u1077  \u1073 \u1086 \u1083 \u1100 \u1096 \u1077 \
  	ja .done\
  	sub ecx, '0' ; \uc0\u1087 \u1088 \u1077 \u1086 \u1073 \u1088 \u1072 \u1079 \u1091 \u1077 \u1084  \u1074  \u1095 \u1080 \u1089 \u1083 \u1086 \
  	imul eax, 10  ; \uc0\u1091 \u1084 \u1085 \u1086 \u1078 \u1072 \u1077 \u1084  \u1085 \u1072  10\
  	add eax, ecx ; \uc0\u1076 \u1086 \u1073 \u1072 \u1074 \u1083 \u1103 \u1077 \u1084  \u1094 \u1080 \u1092 \u1088 \u1091  \u1082  \u1088 \u1077 \u1079 \u1091 \u1083 \u1100 \u1090 \u1072 \u1090 \u1091 \
  	jmp .next_char ; \uc0\u1087 \u1086 \u1074 \u1090 \u1086 \u1088 \u1103 \u1077 \u1084  \u1076 \u1086  \u1082 \u1086 \u1085 \u1094 \u1072  \u1089 \u1090 \u1088 \u1086 \u1082 \u1080 \
  .done:\
  	ret ; \uc0\u1074 \u1086 \u1079 \u1074 \u1088 \u1072 \u1090  \u1091 \u1087 \u1088 \u1072 \u1074 \u1083 \u1077 \u1085 \u1080 \u1103 \
\
  int_to_str:\
  	add esi, 9\
  	mov byte [esi], 0\
  	mov ebx, 10         \
  .next_digit:\
  	xor edx, edx         \
  	div ebx            \
  	add dl, '0'    ;\uc0\u1087 \u1088 \u1077 \u1086 \u1073 \u1088 \u1072 \u1079 \u1091 \u1077 \u1084  \u1074  \u1094 \u1080 \u1092 \u1088 \u1091       \
  	dec esi       ; \uc0\u1091 \u1084 \u1077 \u1085 \u1100 \u1096 \u1072 \u1077 \u1084  \u1091 \u1082 \u1072 \u1079 \u1072 \u1090 \u1077 \u1083 \u1100       \
  	mov [esi], dl \
  	test eax, eax   ;\uc0\u1087 \u1088 \u1086 \u1074 \u1077 \u1088 \u1103 \u1077 \u1084  \u1086 \u1089 \u1090 \u1072 \u1083 \u1080 \u1089 \u1100  \u1083 \u1080  \u1094 \u1080 \u1092 \u1088 \u1099          \
  	jnz .next_digit   ; \uc0\u1077 \u1089 \u1083 \u1080  \u1085 \u1077  \u1079 \u1072 \u1082 \u1086 \u1085 \u1095 \u1080 \u1083 \u1080 \u1089 \u1100  \u1087 \u1088 \u1086 \u1076 \u1086 \u1083 \u1078 \u1072 \u1077 \u1084  \u1094 \u1080 \u1082 \u1083   \
  	mov eax, esi \
  	ret}