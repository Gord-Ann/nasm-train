nasm -f elf64 "math".asm
ld -o "math" "math".o
./"math"