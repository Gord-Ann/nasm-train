nasm -f elf64 "sys".asm
ld -o "sys" "sys".o
./"sys"