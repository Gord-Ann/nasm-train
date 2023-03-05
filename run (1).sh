#!bin/bash
nasm -f elf64 l3.asm
ld -o l3 l3.o
./l3
