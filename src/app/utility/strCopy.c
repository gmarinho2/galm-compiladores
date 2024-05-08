char* strCopy(char *str, int size) {
    char* dest = (char*) malloc(size + 1);
    
    for (int i = 0; i < size; i++)
        dest[i] = str[i];
        
    dest[size] = '\0';
    
    return dest;
}