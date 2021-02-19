int main(void) {
    int ret;
    asm volatile (
        //"li t0, 0x6; csrw mhpmevent3, t0; csrr t1, mhpmcounter3; auipc t0, 0x0; csrr t0, mhpmcounter3; sub %0, t0, t1"
        "li t0, 0x84; csrw mhpmevent3, t0; csrr t1, mhpmcounter3; auipc t0, 0x10; lw t0, 0(t0); csrr t0, mhpmcounter3; sub %0, t0, t1"
        : "=r"(ret) //output
        : //input
        : "t0", "t1" //clobbered
    );
    return ret;
}
