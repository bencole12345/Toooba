void main(int coreID, int *global_int) {
    if(coreID == 0) {
        while(*global_int == 0);
    } else {
        *global_int = 1;
    }
    return;
}
