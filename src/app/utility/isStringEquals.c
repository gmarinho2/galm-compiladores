int isStringEquals(char* str1, int str1Len, char* str2, int str2Len) {
    if (str1Len != str2Len) return 0;

    int i;

    int whileFlag;
    int flag;

    i = 0;
    
startWhileLabel:
    whileFlag = i < str1Len;
    if (!whileFlag) goto endWhileLabel;
    flag = str1[i] == str2[i];
    if (!flag) return 0;
    i = i + 1;
    goto startWhileLabel;
endWhileLabel:

    return 1;
}