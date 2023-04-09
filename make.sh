#!/bin/bash

nasm -f elf64 lab4.asm -o lab4.o
ld -o lab4 lab4.o

./lab4

