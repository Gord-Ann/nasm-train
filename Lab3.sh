#!/bin/bash

nasm -f elf64 Lab3.asm 
ld -o Lab3 Lab3.o
./Lab3
