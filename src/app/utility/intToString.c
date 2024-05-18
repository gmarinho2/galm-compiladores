char* intToString(int n) {
    int value;
    char character;

    int t0;
    int t1;
    int t2;
    int t3;

    char *str;
    str = (char*) malloc(12);

    t0 = n == 0;
    if (!t0) goto endIfIsZero;
    str[0] = '0';
    str[1] = '\0';
    return str;
endIfIsZero:

    t1 = 0;

startWhileLabel:
    t2 = n != 0;
    if (!t2) goto endWhileLabel;
    t1 = t1 - 1;
    value = n % 10;
    
    if (value < 0) value = value * -1;
    
    value = value + 48;
    character = (char) value;
    str[t1] = character;
    n = n / 10;
    goto startWhileLabel;
endWhileLabel:

    t3 = n < 0;
    if (!t3) goto endIfIsNegative;
    t1 = t1 - 1;
    str[t1] = '-';
endIfIsNegative:
    
    char* ptr;
    ptr = str + t1;
    return ptr;
}