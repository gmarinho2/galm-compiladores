int strLen(char *str) {
    int result;
    int ptr;
    int t1;

    result = 0;
    ptr = 0;

    startCount:
    t1 = str[ptr] != '\0';
    if (!t1) goto endCount;
    result = result + 1;
    ptr = ptr + 1;
    goto startCount;
    endCount:

    return result;
}