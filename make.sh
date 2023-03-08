#!/bin/bash

nasm -f elf64 lab3.asm 
ld -o lab3 lab3.o
./lab3
