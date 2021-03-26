#!/bin/sh -xe

riscv64-unknown-elf-gcc -o init.o -c init.s
for TEST in toy dual hpm memshim
do
riscv64-unknown-elf-gcc -o $TEST.o -c $TEST.c
riscv64-unknown-elf-gcc -nostdlib -mcmodel=medany -Tlink.ld -o $TEST $TEST.o init.o
riscv64-unknown-elf-objdump -D $TEST > $TEST.dump
../elf_to_hex/elf_to_hex $TEST $TEST.hex
done
