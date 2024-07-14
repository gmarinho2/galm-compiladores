/*
   ____ ___  __  __ ____ ___ _        _    ____   ___  ____        ____    _    _     __  __ 
  / ___/ _ \|  \/  |  _ \_ _| |      / \  |  _ \ / _ \|  _ \      / ___|  / \  | |   |  \/  |
 | |  | | | | |\/| | |_) | || |     / _ \ | | | | | | | |_) |    | |  _  / _ \ | |   | |\/| |
 | |__| |_| | |  | |  __/| || |___ / ___ \| |_| | |_| |  _ <     | |_| |/ ___ \| |___| |  | |
  \____\___/|_|  |_|_|  |___|_____/_/   \_\____/ \___/|_| \_\     \____/_/   \_\_____|_|  |_|
  
  
 __     _______ ____  ____  /\/| ___      _   ___  
 \ \   / / ____|  _ \/ ___||/\/ / _ \    / | / _ \ 
  \ \ / /|  _| | |_) \___ \ /_\| | | |   | || | | |
   \ V / | |___|  _ < ___) / _ \ |_| |   | || |_| |
    \_/  |_____|_| \_\____/_/ \_\___/    |_(_)___/ 
                                                 

  Authored by: Allan Marcelino, Gabriel Marinho, Marcos Souza      
  Version: 1.0
  Date: 13/07/2024

*/

#include <iostream>
#include <stdio.h>
#include <string.h>

using namespace std;

#define bool int
#define true 1
#define false 0

typedef struct {

    union {
        int integer;
        float real;
    } value;
    int isInteger;

} number;

typedef struct {
    char* str;
    int length;
} String;

void dispatchError(string message, int currentLine);

number sum(number a, number b);
number subtract(number a, number b);
number multiply(number a, number b);
number divide(number a, number b);
number divideInteger(number a, number b);
number mod(number a, number b);
number pow(number a, number b);

number bitOr(number a, number b, int currentLine);
number bitAnd(number a, number b, int currentLine);
number bitXor(number a, number b, int currentLine);
number bitNot(number a, int currentLine);
number bitShiftLeft(number a, number b, int currentLine);
number bitShiftRight(number a, number b, int currentLine);

int isGreaterThan(number a, number b);
int isLessThan(number a, number b);
int isGreaterThanOrEquals(number a, number b);
int isLessThanOrEquals(number a, number b);

number intToFloat(number a);
number floatToInt(number a);
char numberToChar(number a);
bool numberToBool(number a);

int isNumberEquals(number a, number b);
int isStringEquals(String str1, String str2);

String numberToString(number n);
String concat(String dest, String source);
String strCopy(String string);

int strLen(char *str);

String readInput();

/* %%%%%%%%%%%%%%%%%%%%%%% */

// ARRUMAR ISSO AQUI PARA RECEBER CHAR POINTER
void dispatchError(string message, int currentLine) {
    cout << "\033[1;31mRuntime exception: " << message << " (line " << currentLine << ")" << endl << "\033[0m";
    exit(1);
}

number sum(number a, number b) {
    number result;

    int flag;

    if (!a.isInteger || !b.isInteger) {
        result.isInteger = false;

        float f1;
        float f2;

        if (a.isInteger) {
            f1 = (float) a.value.integer;
        } else {
            f1 = a.value.real;
        }

        if (b.isInteger) {
            f2 = (float) b.value.integer;
        } else {
            f2 = b.value.real;
        }

        result.value.real = f1 + f2;
    } else {
        result.isInteger = true;
        
        int i1;
        int i2;

        if (a.isInteger) {
            i1 = a.value.integer;
        } else {
            i1 = (int) a.value.real;
        }

        if (b.isInteger) {
            i2 = b.value.integer;
        } else {
            i2 = (int) b.value.real;
        }

        result.value.integer = i1 + i2;
    }

    return result;
}

number subtract(number a, number b) {
    number result;

    int flag;

    if (!a.isInteger || !b.isInteger) {
        result.isInteger = false;

        float f1;
        float f2;

        if (a.isInteger) {
            f1 = (float) a.value.integer;
        } else {
            f1 = a.value.real;
        }

        if (b.isInteger) {
            f2 = (float) b.value.integer;
        } else {
            f2 = b.value.real;
        }

        result.value.real = f1 - f2;
    } else {
        result.isInteger = true;
        
        int i1;
        int i2;

        if (a.isInteger) {
            i1 = a.value.integer;
        } else {
            i1 = (int) a.value.real;
        }

        if (b.isInteger) {
            i2 = b.value.integer;
        } else {
            i2 = (int) b.value.real;
        }

        result.value.integer = i1 - i2;
    }

    return result;
}

number multiply(number a, number b) {
    number result;

    int flag;

    if (!a.isInteger || !b.isInteger) {
        result.isInteger = false;

        float f1;
        float f2;

        if (a.isInteger) {
            f1 = (float) a.value.integer;
        } else {
            f1 = a.value.real;
        }

        if (b.isInteger) {
            f2 = (float) b.value.integer;
        } else {
            f2 = b.value.real;
        }

        result.value.real = f1 * f2;
    } else {
        result.isInteger = true;
        
        int i1;
        int i2;

        if (a.isInteger) {
            i1 = a.value.integer;
        } else {
            i1 = (int) a.value.real;
        }

        if (b.isInteger) {
            i2 = b.value.integer;
        } else {
            i2 = (int) b.value.real;
        }

        result.value.integer = i1 * i2;
    }

    return result;
}

number divide(number a, number b) {
    number result;

    int flag;

    if (!a.isInteger || !b.isInteger) {
        result.isInteger = false;

        float f1;
        float f2;

        if (a.isInteger) {
            f1 = (float) a.value.integer;
        } else {
            f1 = a.value.real;
        }

        if (b.isInteger) {
            f2 = (float) b.value.integer;
        } else {
            f2 = b.value.real;
        }

        result.value.real = f1 / f2;
    } else {
        result.isInteger = true;
        
        int i1;
        int i2;

        if (a.isInteger) {
            i1 = a.value.integer;
        } else {
            i1 = (int) a.value.real;
        }

        if (b.isInteger) {
            i2 = b.value.integer;
        } else {
            i2 = (int) b.value.real;
        }

        result.value.integer = i1 / i2;
    }

    return result;
}

number divideInteger(number a, number b) {
    number result;

    result.isInteger = true;

    int i1;

    if (a.isInteger) {
        i1 = a.value.integer;
    } else {
        i1 = (int) a.value.real;
    }

    int i2;

    if (b.isInteger) {
        i2 = b.value.integer;
    } else {
        i2 = (int) b.value.real;
    }

    result.value.integer = i1 / i2;

    return result;
}

number mod(number a, number b) {
    // A AND B IS INTEGER
    int div = a.value.integer / b.value.integer;
    int mult = div * b.value.integer;
    int mod = a.value.integer - mult;
    int mask = mod >> 31;
    int exclusiveOr = mask ^ mod;
    int abs = exclusiveOr - mask;

    number result;

    result.value.integer = abs;
    result.isInteger = true;

    return result;
}

float absolute(float a) {
    return a < 0 ? -a : a;
}

float ln(float a) {
    if (a <= 0) {
        dispatchError("Logarithm of a non-positive number", 0);
    }

    float result = 0;
    float x = (a - 1) / (a + 1);
    float x2 = x * x;
    float num = x2;
    float denom = 1;

    for (int i = 1; i <= 100; i += 2) {
        result += num / denom;
        num *= x2;
        denom += 2;
    }

    return 2.0f * result;
}

float exp(float a) {
    float result = 1;
    float num = 1;
    float denom = 1;

    for (int i = 1; i <= 100; i++) {
        result += num / denom;
        num *= a;
        denom *= i;
    }

    return result;
}

number pow(number a, number b) {
    number result;

    result.isInteger = false;
    
    float base;
    float exponent;

    if (a.isInteger) {
        base = (float) a.value.integer;
    } else {
        base = a.value.real;
    }

    if (b.isInteger) {
        exponent = (float) b.value.integer;
    } else {
        exponent = b.value.real;
    }

    if (base == 0 && exponent == 0) {
        dispatchError("0^0 is undefined", 0);
    }

    if (base == 0) {
        result.value.real = 0;
        return result;
    }

    if (exponent == 0) {
        result.value.real = 1;
        return result;
    }

    float res = 1.0;
    float positive = exponent > 0 ? exponent : -exponent;
    int intPart = (int) positive;
    float decimalPart = positive - intPart;

    for (int i = 0; i < intPart; i++) {
        res *= base;
    }

    if (decimalPart > 0) {
        res *= exp(decimalPart * ln(base));
    }

    if (exponent < 0) {
        res = 1 / res;
    }

    result.value.real = res;

    return result;
}

number bitOr(number a, number b, int currentLine) {
    if (!a.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    if (!b.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    number result;

    result.value.integer = a.value.integer | b.value.integer;
    result.isInteger = true;

    return result;
}

number bitAnd(number a, number b, int currentLine) {
    if (!a.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    if (!b.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    number result;

    result.value.integer = a.value.integer & b.value.integer;
    result.isInteger = true;

    return result;
}

number bitXor(number a, number b, int currentLine) {
    if (!a.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    if (!b.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    number result;

    result.value.integer = a.value.integer ^ b.value.integer;
    result.isInteger = true;

    return result;
}

number bitNot(number a, int currentLine) {
    if (!a.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    number result;

    result.value.integer = ~a.value.integer;
    result.isInteger = true;

    return result;
}

number bitShiftLeft(number a, number b, int currentLine) {
    if (!a.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    if (!b.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    number result;

    result.value.integer = a.value.integer << b.value.integer;
    result.isInteger = true;

    return result;
}

number bitShiftRight(number a, number b, int currentLine) {
    if (!a.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    if (!b.isInteger) {
        dispatchError("Bitwise operations can only be performed on integers", currentLine);
    }

    number result;

    result.value.integer = a.value.integer >> b.value.integer;
    result.isInteger = true;

    return result;
}

number intToFloat(number a) {
    if (!a.isInteger) return a;

    number result;

    result.isInteger = false;
    result.value.real = (float) a.value.integer;

    return result;
}

number floatToInt(number a) {
    if (a.isInteger) return a;

    number result;

    result.isInteger = true;
    result.value.integer = (int) a.value.real;

    return result;
}

int isGreaterThan(number a, number b) {
    if (a.isInteger && b.isInteger) {
        return a.value.integer > b.value.integer;
    }

    float f1;
    float f2;

    if (a.isInteger) {
        f1 = (float) a.value.integer;
    } else {
        f1 = a.value.real;
    }

    if (b.isInteger) {
        f2 = (float) b.value.integer;
    } else {
        f2 = b.value.real;
    }

    return f1 > f2;
}

int isLessThan(number a, number b) {
    if (a.isInteger && b.isInteger) {
        return a.value.integer < b.value.integer;
    }

    float f1;
    float f2;

    if (a.isInteger) {
        f1 = (float) a.value.integer;
    } else {
        f1 = a.value.real;
    }

    if (b.isInteger) {
        f2 = (float) b.value.integer;
    } else {
        f2 = b.value.real;
    }

    return f1 < f2;
}

int isGreaterThanOrEquals(number a, number b) {
    if (a.isInteger && b.isInteger) {
        return a.value.integer >= b.value.integer;
    }

    float f1;
    float f2;

    if (a.isInteger) {
        f1 = (float) a.value.integer;
    } else {
        f1 = a.value.real;
    }

    if (b.isInteger) {
        f2 = (float) b.value.integer;
    } else {
        f2 = b.value.real;
    }

    return f1 >= f2;
}

int isLessThanOrEquals(number a, number b) {
    if (a.isInteger && b.isInteger) {
        return a.value.integer <= b.value.integer;
    }

    float f1;
    float f2;

    if (a.isInteger) {
        f1 = (float) a.value.integer;
    } else {
        f1 = a.value.real;
    }

    if (b.isInteger) {
        f2 = (float) b.value.integer;
    } else {
        f2 = b.value.real;
    }

    return f1 <= f2;
}

char numberToChar(number a) {
    int i1;

    if (a.isInteger) {
        i1 = a.value.integer;
    } else {
        i1 = (int) a.value.real;
    }

    int c = (char) i1;

    return c;
}

bool numberToBool(number a) {
    int i1;

    if (a.isInteger) {
        i1 = a.value.integer;
    } else {
        i1 = (int) a.value.real;
    }

    return i1 != 0;
}

int isNumberEquals(number a, number b) {
    if (a.isInteger == b.isInteger) {
        if (a.isInteger) {
            return a.value.integer == b.value.integer;
        } else {
            return a.value.real == b.value.real;
        }
    }

    float f1;
    float f2;

    if (a.isInteger) {
        f1 = (float) a.value.integer;
    } else {
        f1 = a.value.real;
    }

    
    if (b.isInteger) {
        f2 = (float) b.value.integer;
    } else {
        f2 = b.value.real;
    }

    return f1 == f2;
}

String numberToString(number n) {
    String str;

    str.str = (char*) malloc(12);

    if (n.isInteger) {
        sprintf(str.str, "%d", n.value.integer);
    } else {
        sprintf(str.str, "%f", n.value.real);
    }

    str.length = strLen(str.str);

    return str;
}

String concat(String dest, String source) {
    String string;

    string.length = dest.length + source.length;
    string.str = (char*) malloc(string.length);

    int i;
    int j;
    int flag;

    i = 0;
    j = 0;

startWhileDest:
    flag = i < dest.length;
    if (!flag) goto endWhileDest;
    string.str[j] = dest.str[i];
    i = i + 1;
    j = j + 1;
    goto startWhileDest;
endWhileDest:

    i = 0;

startWhileSource:
    flag = i < source.length;
    if (!flag) goto endWhileSource;
    string.str[j] = source.str[i];
    i = i + 1;
    j = j + 1;
    goto startWhileSource;
endWhileSource:
    
    return string;
}

int isStringEquals(String str1, String str2) {
    int ifFlag = str1.length != str2.length;

    if (ifFlag) return 0;

    int i;

    int whileFlag;
    int flag;

    i = 0;
    
startWhileLabel:
    whileFlag = i < str1.length;
    if (!whileFlag) goto endWhileLabel;
    flag = str1.str[i] == str2.str[i];
    if (!flag) return 0;
    i = i + 1;
    goto startWhileLabel;
endWhileLabel:

    return 1;
}

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

String strCopy(String str) {
    String string;

    string.str = (char*) malloc(str.length);
    string.length = str.length;

    int i;
    int flag;

    i = 0;

startWhile:
    flag = i < str.length;
    if (!flag) goto endWhile;
    string.str[i] = str.str[i];
    i = i + 1;
    goto startWhile;
endWhile:
        
    return string;
}

String readInput() {
    int capacity;

    int character;
    char currentCharacter;

    int whileFlag;
    int ifFlag;

    int currentCharacterFlag;
    int sizeSum;

    capacity = 12;
    currentCharacter = 0;

    String string;

    string.length = 0;

startWhile:
    character = cin.get();
    currentCharacter = (char) character;
    whileFlag = currentCharacter != '\n';
    if (!whileFlag) goto endWhile;

    sizeSum = string.length + 1;
    ifFlag = sizeSum >= capacity;
    if (!ifFlag) goto endIf;
    capacity = capacity * 2;
    string.str = (char*) realloc(string.str, capacity);
endIf:
    string.str[string.length] = currentCharacter;
    string.length++;
    goto startWhile;
endWhile:

    string.str = (char*) realloc(string.str, string.length);

    return string;
}