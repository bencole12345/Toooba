# See LICENSE file for the license details of MIT
# Copyright 2020 Marno van der Maas

# RISC-V baremetal init.s
# This code is executed first.

.section .text.init
entry:
    auipc sp, 0x8           #sp is pc plus 0x8000 which is the stack location
    srli  sp, sp, 12        #making sure last 12 bits of sp are 0
    slli  sp, sp, 12
    #la    t0, __mem
    #csrw  mtvec, t0        #Set trap vector to go back to start of program
    csrr  a0, mhartid       #Put harware thread ID in first function argument
    la    a1, global_int
    call  main              #Call the main function

    csrr  t1, mhartid
infiniloop:
    bnez  t1, infiniloop    #If not core 0 then loop infinitly
end:
    bne   a0, zero, end2
    li    a0, 0xDEADBEEFDEADBEEF
end2:
    la    t0, tohost
    sw    a0, 0(t0)    #Store main's return val to tohost address
    j     end               #Loop when finished

.section .tohost
.global tohost; tohost: .dword 0;
.global fromhost; fromhost: .dword 0; 
global_int:
    .dword 0

