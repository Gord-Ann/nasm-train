#!/bin/bash

nasm -f elf64 Lab2.asm 
ld -o Lab2 Lab2.o
./Lab2
