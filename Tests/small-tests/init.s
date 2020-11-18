# See LICENSE file for the license details of MIT
# Copyright 2020 Marno van der Maas

# RISC-V baremetal init.s
# This code is executed first.

.section .text.init
entry:
    auipc sp, 0x8           #sp is pc plus 0x8000 which is the stack location
    srli  sp, sp, 12        #making sure last 12 bits of sp are 0
    slli  sp, sp, 12
    call  main              #Call the main function

end:
    j end                   #Loop when finished
