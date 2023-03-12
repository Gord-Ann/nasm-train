#!/bin/bash

nasm -f elf64 l3.asm 
ld -o l3_anna l3.o
./l3
