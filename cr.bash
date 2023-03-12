nasm -f elf64 "jump".asm
ld -o "jump" "jump".o
./"jump"