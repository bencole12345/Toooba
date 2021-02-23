int main(void) {
    int ret;
    asm volatile (
        "li t0, 0x84;"//Event ID for AXI4 ar
        //"li t0, 0x6;"//Event ID for AUIPC
        "csrw mhpmevent3, t0;"
        "csrr t1, mhpmcounter3;"
        "li t0, 1;"
        "loop: addi t0, t0, -1;"
        "auipc t2, 0x100;"
        "srli t2, t2, 2;"
        "slli t2, t2, 2;"
        "slli t3, t0, 16;"
        "add t2, t2, t3;"
        "lw t2, 0(t2);"
        "bnez t0, loop;"
        "csrr t0, mhpmcounter3;"
        "sub %0, t0, t1"
        : "=r"(ret) //output
        : //input
        : "t0", "t1", "t2", "t3"//clobbered
    );
    return ret;
}
