#!/bin/sh -xe
riscv64-unknown-elf-gcc -o toy.o -c toy.c
riscv64-unknown-elf-gcc -o init.o -c init.s
riscv64-unknown-elf-gcc -nostdlib -mcmodel=medany -Tlink.ld -o toy toy.o init.o
riscv64-unknown-elf-objdump -D toy > toy.dump
../elf_to_hex/elf_to_hex toy toy.hex
