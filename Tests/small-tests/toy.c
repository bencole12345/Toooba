// See LICENSE file for the license details of MIT
// Copyright 2020 Marno van der Maas

#define START_OF_UART (0xC0000000)
#define START_OF_ROM  (0x00001000)
#define SIZE_OF_ROM (0x1000)

long main(char * output) {
    char *uart_pointer = (char *) START_OF_UART;
    long *rom_pointer  = (long *) START_OF_ROM;
    char c;
    long tmp;
    for( int i = 0; i < 10; i++) {
        c = 0x11;
        uart_pointer[0] = c;
        c = uart_pointer[0];
    }
    for( int i = 0; i < SIZE_OF_ROM/sizeof(int)/128; i++) {
        tmp = rom_pointer[i];
    }
    return tmp + c;
}
