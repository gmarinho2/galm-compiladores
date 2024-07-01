char* concat(char* dest, char* source) {
    int destSize;
    int sourceSize;
    int totalSize;

    int t1;
    int i;
    int j;

    char* str;
    
    destSize = 0;
    sourceSize = 0;

startCountDestSize:
    t1 = dest[destSize] != '\0';
    if (!t1) goto endCountDestSize;
    destSize = destSize + 1;
    goto startCountDestSize;
endCountDestSize:

startCountSourceSize:
    t1 = source[sourceSize] != '\0';
    if (!t1) goto endCountSourceSize;
    sourceSize = sourceSize + 1;
    goto startCountSourceSize;
endCountSourceSize:
    
    totalSize = destSize + sourceSize;
    
    str = (char*) malloc(totalSize + 1);

    i = 0;
    j = 0;

startCopyDest:
    t1 = j < destSize;
    if (!t1) goto endCopyDest;
    str[i] = dest[j];
    j = j + 1;
    i = i + 1;
    goto startCopyDest;
endCopyDest:

    j = 0;

startCopySource:
    t1 = j < sourceSize;
    if (!t1) goto endCopySource;
    str[i] = source[j];
    j = j + 1;
    i = i + 1;
    goto startCopySource;
endCopySource:

    str[i] = '\0';
    return str;
}