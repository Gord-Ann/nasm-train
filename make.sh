#!/bin/bash

nasm -f elf64 lab2.asm 
ld -o lab2 lab2.o
./lab2
