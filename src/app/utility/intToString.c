char* intToString(int n) {
    char *str;
    str = (char*) malloc(12);

    if (n != 0) goto endIfIsZero;
    str[0] = '0';
    str[1] = '\0';
    return str;
    endIfIsZero:

    int isNegative;
    int value;
    char character;

    int t0;
    int t1;

    t0 = 0;
    isNegative = n < 0;

    startWhileLabel:
    t1 = n != 0;
    if (!t1) goto endWhileLabel;
    t0 = t0 - 1;
    value = n % 10;
    
    if (value < 0) value = value * -1;
    
    value = value + 48;
    character = (char) value;
    str[t0] = character;
    n = n / 10;
    goto startWhileLabel;
    endWhileLabel:

    if (!isNegative) goto endIfIsNegative;
    t0 = t0 - 1;
    str[t0] = '-';
    endIfIsNegative:
    
    char* ptr;
    ptr = str + t0;
    return ptr;
}