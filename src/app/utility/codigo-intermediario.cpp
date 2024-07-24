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

typedef struct {
    String* array;
    int* dimensions;
} StringArray;

typedef struct {
    number* array;
    int* dimensions;
} NumberArray;

typedef struct {
    bool* array;
    int* dimensions;
} BoolArray;

typedef struct {
    char* array;
    int* dimensions;
} CharArray;

typedef struct {
    void* array;
    int* dimensions;
} VoidArray;

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

int getIntegerValueFromNumber(number a, int currentLine);

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

int calculateArrayTotalSize(int* dimensions);
int calculateArrayIndex(int* dimensions, int* indexes, int currentLine);
NumberArray getArrayLength(int* dimensions);

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
    float f1, f2;
    int i1, i2;
    
    float temp1, temp2;
    int temp3, temp4;

    bool isAInteger = a.isInteger;
    bool isBInteger = b.isInteger;

    bool isNotAInteger = !isAInteger;
    bool isNotBInteger = !isBInteger;
    bool eitherNotInteger = isNotAInteger || isNotBInteger;

    if (eitherNotInteger) goto L1;
    result.isInteger = true;
    goto L2;

    L1:
    result.isInteger = false;

    if (!isAInteger) goto L3;
    temp1 = (float) a.value.integer;
    goto L4;
    L3:
    temp1 = a.value.real;

    L4:
    f1 = temp1;

    if (!isBInteger) goto L5;
    temp2 = (float) b.value.integer;
    goto L6;
    L5:
    temp2 = b.value.real;

    L6:
    f2 = temp2;

    result.value.real = f1 + f2;
    goto L7;

    L2:
    if (!isAInteger) goto L8;
    temp3 = a.value.integer;
    goto L9;
    L8:
    temp3 = (int) a.value.real;

    L9:
    i1 = temp3;

    if (!isBInteger) goto L10;
    temp4 = b.value.integer;
    goto L11;
    L10:
    temp4 = (int) b.value.real;

    L11:
    i2 = temp4;

    result.value.integer = i1 + i2;

    L7:
    return result;
}

number subtract(number a, number b) {
    number result;
    int flag;
    float f1, f2;
    int i1, i2;

    int tempFlag1, tempFlag2;
    float temp1, temp2;
    int temp3, temp4;

    tempFlag1 = !a.isInteger;
    tempFlag2 = !b.isInteger;
    if (tempFlag1) goto HandleReal;
    if (tempFlag2) goto HandleReal;
    result.isInteger = true;
    goto HandleInteger;

    HandleReal:
    result.isInteger = false;
    if (a.isInteger) goto ConvertAtoFloat;
    temp1 = a.value.real;
    goto AConverted;
    
    ConvertAtoFloat:
    temp1 = (float) a.value.integer;

    AConverted:
    f1 = temp1;
    if (b.isInteger) goto ConvertBtoFloat;
    temp2 = b.value.real;
    goto BConverted;
    
    ConvertBtoFloat:
    temp2 = (float) b.value.integer;

    BConverted:
    f2 = temp2;
    result.value.real = f1 - f2;
    goto End;

    HandleInteger:
    if (a.isInteger) goto ConvertAtoInt;
    temp3 = (int) a.value.real;
    goto AConvertedToInt;
    
    ConvertAtoInt:
    temp3 = a.value.integer;

    AConvertedToInt:
    i1 = temp3;
    if (b.isInteger) goto ConvertBtoInt;
    temp4 = (int) b.value.real;
    goto BConvertedToInt;

    ConvertBtoInt:
    temp4 = b.value.integer;

    BConvertedToInt:
    i2 = temp4;
    result.value.integer = i1 - i2;

    End:
    return result;
}



number multiply(number a, number b) {
    number result;
    int flag;

    bool isAInteger = a.isInteger;
    bool isBInteger = b.isInteger;

    bool isNotAInteger = !isAInteger;
    bool isNotBInteger = !isBInteger;
    bool eitherNotInteger = isNotAInteger || isNotBInteger;

    if (!eitherNotInteger) goto integerElse;
    result.isInteger = false;

    float f1;
    float f2;

    if (isAInteger) goto isAIntegerGoto;
        f1 = a.value.real;
    goto fimIfAIntegerGoto;
isAIntegerGoto:
        f1 = (float) a.value.integer;
fimIfAIntegerGoto:

    if (isBInteger) goto isBIntegerGoto;
        f2 = b.value.real;
    goto fimIfBIntegerGoto;
isBIntegerGoto:
        f2 = (float) b.value.integer;
fimIfBIntegerGoto:

    result.value.real = f1 * f2;
    goto fimIf;
integerElse:
    result.isInteger = true;

    int i1;
    int i2;

    if (isAInteger) goto isAIntegerGoto2;
        i1 = (int) a.value.real;
    goto fimIfAIntegerGoto2;
isAIntegerGoto2:
        i1 = a.value.integer;
fimIfAIntegerGoto2:

    if (isBInteger) goto isBIntegerGoto2;
        i2 = (int) b.value.real;
    goto fimIfBIntegerGoto2;
isBIntegerGoto2:
        i2 = b.value.integer;
fimIfBIntegerGoto2:

    result.value.integer = i1 * i2;
fimIf:

    return result;
}

number divide(number a, number b) {
    number result;
    int flag;

    bool isAInteger = a.isInteger;
    bool isBInteger = b.isInteger;

    bool isNotAInteger = !isAInteger;
    bool isNotBInteger = !isBInteger;
    bool eitherNotInteger = isNotAInteger || isNotBInteger;

    if (!eitherNotInteger) goto integerElse;
    result.isInteger = false;

    float f1;
    float f2;

    if (isAInteger) goto isAIntegerGoto;
        f1 = a.value.real;
    goto fimIfAIntegerGoto;
isAIntegerGoto:
        f1 = (float) a.value.integer;
fimIfAIntegerGoto:

    if (isBInteger) goto isBIntegerGoto;
        f2 = b.value.real;
    goto fimIfBIntegerGoto;
isBIntegerGoto:
        f2 = (float) b.value.integer;
fimIfBIntegerGoto:

    result.value.real = f1 / f2;
    goto fimIf;
integerElse:
    result.isInteger = true;

    int i1;
    int i2;

    if (isAInteger) goto isAIntegerGoto2;
        i1 = (int) a.value.real;
    goto fimIfAIntegerGoto2;
isAIntegerGoto2:
        i1 = a.value.integer;
fimIfAIntegerGoto2:

    if (isBInteger) goto isBIntegerGoto2;
        i2 = (int) b.value.real;
    goto fimIfBIntegerGoto2;
isBIntegerGoto2:
        i2 = b.value.integer;
fimIfBIntegerGoto2:

    result.value.integer = i1 / i2;
fimIf:

    return result;
}


number divideInteger(number a, number b) {
    number result;
    result.isInteger = true;

    bool isAInteger = a.isInteger;
    bool isBInteger = b.isInteger;

    int i1;
    int i2;

    if (isAInteger) goto isAIntegerGoto;
        i1 = (int) a.value.real;
    goto fimIfAIntegerGoto;
isAIntegerGoto:
        i1 = a.value.integer;
fimIfAIntegerGoto:

    if (isBInteger) goto isBIntegerGoto;
        i2 = (int) b.value.real;
    goto fimIfBIntegerGoto;
isBIntegerGoto:
        i2 = b.value.integer;
fimIfBIntegerGoto:

    result.value.integer = i1 / i2;

    return result;
}

number mod(number a, number b) {
    bool isAInteger = a.isInteger;
    bool isBInteger = b.isInteger;

    bool isNotAInteger = !isAInteger;
    bool isNotBInteger = !isBInteger;
    bool eitherNotInteger = isNotAInteger || isNotBInteger;

    if (!eitherNotInteger) goto isCorrectLabel;
    dispatchError("Modulus operator can only be performed on integers", 0);
isCorrectLabel:

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

float ln(float a) {
    bool isNonPositive;
    float result;
    float aMinus1;
    float aPlus1;
    float x;
    float x2;
    float num;
    float denom;
    float div;
    bool condition;

    isNonPositive = a <= 0;

    if (!isNonPositive) goto isCorrectLabel;
        dispatchError("Logarithm of a non-positive number", 0);
    isCorrectLabel:

    result = 0;
    aMinus1 = a - 1;
    aPlus1 = a + 1;
    x = aMinus1 / aPlus1;
    x2 = x * x;
    num = x2;
    denom = 1;

    int i = 1;
    L1:
    condition = i <= 100;
    if (!condition) goto L2;

    div = num / denom;
    result = result + div;
    num = num * x2;
    denom = denom + 2;
    i = i + 2;

    goto L1;

    L2:
    return 2.0f * result;
}


float exp(float a) {
    float result;
    float num;
    float denom;
    float div;

    int i;
    int condition;

    result = 1;
    num = 1;
    denom = 1;
    i = 1;

    L1:
    condition = i <= 100;
    if (!condition) goto L2;

    div = num / denom;
    result = result + div;
    num = num * a;
    denom = denom * i;
    i = i + 1;

    goto L1;

    L2:
    return result;
}



number pow(number a, number b) {
    number result;
    result.isInteger = 0;

    float base;
    float exponent;

    int ifFlag1;
    int ifFlag2;
    int ifFlag3;
    int ifFlag4;
    int ifFlag5;
    int ifFlag6;
    int i;

    float res;
    float positive;
    int intPart;
    float decimalPart;
    float lnBase;
    float expValue;

    ifFlag1 = a.isInteger;
    if (!ifFlag1) goto useRealBase;
    base = (float) a.value.integer;
    goto checkExponent;

useRealBase:
    base = a.value.real;

checkExponent:
    ifFlag2 = b.isInteger;
    if (!ifFlag2) goto useRealExponent;
    exponent = (float) b.value.integer;
    goto checkBaseExponent;

useRealExponent:
    exponent = b.value.real;

checkBaseExponent:
    ifFlag3 = base == 0;
    ifFlag4 = exponent == 0;
    if (!ifFlag3) goto checkBaseZero;
    if (!ifFlag4) goto checkBaseZero;
    dispatchError("0^0 is undefined", 0);

checkBaseZero:
    ifFlag5 = base == 0;
    if (!ifFlag5) goto checkExponentZero;
    result.value.real = 0;
    return result;

checkExponentZero:
    ifFlag6 = exponent == 0;
    if (!ifFlag6) goto calculatePower;
    result.value.real = 1;
    return result;

calculatePower:
    res = 1.0;
    ifFlag6 = exponent > 0;
    if (!ifFlag6) goto negateExponent;
    positive = exponent;
    goto calculateParts;

negateExponent:
    positive = -exponent;

calculateParts:
    intPart = (int) positive;
    decimalPart = positive - intPart;

    i = 0;
calculateLoop:
    ifFlag1 = i >= intPart;
    if (ifFlag1) goto endLoop;
    res = res * base;
    i++;
    goto calculateLoop;
endLoop:

    ifFlag4 = decimalPart > 0;
    if (!ifFlag4) goto checkNegativeExponent;
    lnBase = ln(base);
    float resultExp;
    resultExp = decimalPart * lnBase;
    expValue = exp(resultExp);
    res = res * expValue;

checkNegativeExponent:
    ifFlag4 = exponent < 0;
    if (!ifFlag4) goto assignResult;
    res = 1 / res;

assignResult:
    result.value.real = res;

    return result;
}



number bitOr(number a, number b, int currentLine) {
    int ifFlag1;
    int ifFlag2;

    number result;

    ifFlag1 = !a.isInteger;
    if (!ifFlag1) goto checkB;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

checkB:
    ifFlag2 = !b.isInteger;
    if (!ifFlag2) goto performOr;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

performOr:
    result.value.integer = a.value.integer | b.value.integer;
    result.isInteger = 1;

    return result;
}


number bitAnd(number a, number b, int currentLine) {
    int ifFlag1;
    int ifFlag2;

    number result;

    ifFlag1 = !a.isInteger;
    if (!ifFlag1) goto checkB;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

checkB:
    ifFlag2 = !b.isInteger;
    if (!ifFlag2) goto performAnd;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

performAnd:
    result.value.integer = a.value.integer & b.value.integer;
    result.isInteger = 1;

    return result;
}


number bitXor(number a, number b, int currentLine) {
    int ifFlag1;
    int ifFlag2;

    number result;

    ifFlag1 = !a.isInteger;
    if (!ifFlag1) goto checkB;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

checkB:
    ifFlag2 = !b.isInteger;
    if (!ifFlag2) goto performXor;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

performXor:
    result.value.integer = a.value.integer ^ b.value.integer;
    result.isInteger = 1;

    return result;
}


number bitNot(number a, int currentLine) {
    int ifFlag;

    number result;

    ifFlag = !a.isInteger;
    if (!ifFlag) goto performNot;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

performNot:
    result.value.integer = ~a.value.integer;
    result.isInteger = 1;

    return result;
}


number bitShiftLeft(number a, number b, int currentLine) {
    int ifFlag1;
    int ifFlag2;

    number result;

    ifFlag1 = !a.isInteger;
    if (!ifFlag1) goto checkB;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

checkB:
    ifFlag2 = !b.isInteger;
    if (!ifFlag2) goto performShift;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

performShift:
    result.value.integer = a.value.integer << b.value.integer;
    result.isInteger = 1;

    return result;
}


number bitShiftRight(number a, number b, int currentLine) {
    int ifFlag1;
    int ifFlag2;

    number result;

    ifFlag1 = !a.isInteger;
    if (!ifFlag1) goto checkB;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

checkB:
    ifFlag2 = !b.isInteger;
    if (!ifFlag2) goto performShift;

    dispatchError("Bitwise operations can only be performed on integers", currentLine);

performShift:
    result.value.integer = a.value.integer >> b.value.integer;
    result.isInteger = 1;

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
    int ifFlag1;
    int ifFlag2;
    int result;

    float f1;
    float f2;

    ifFlag1 = a.isInteger && b.isInteger;
    if (!ifFlag1) goto notBothIntegers;

    result = a.value.integer > b.value.integer;
    return result;

notBothIntegers:
    ifFlag2 = a.isInteger;
    if (!ifFlag2) goto useRealValueA;

    f1 = (float) a.value.integer;
    goto checkB;

useRealValueA:
    f1 = a.value.real;

checkB:
    ifFlag2 = b.isInteger;
    if (!ifFlag2) goto useRealValueB;

    f2 = (float) b.value.integer;
    goto compareValues;

useRealValueB:
    f2 = b.value.real;

compareValues:
    result = f1 > f2;
    return result;
}

int isLessThan(number a, number b) {
    int ifFlag1;
    int ifFlag2;
    int result;

    float f1;
    float f2;

    ifFlag1 = a.isInteger && b.isInteger;
    if (!ifFlag1) goto notBothIntegers;

    result = a.value.integer < b.value.integer;
    return result;

notBothIntegers:
    ifFlag2 = a.isInteger;
    if (!ifFlag2) goto useRealValueA;

    f1 = (float) a.value.integer;
    goto checkB;

useRealValueA:
    f1 = a.value.real;

checkB:
    ifFlag2 = b.isInteger;
    if (!ifFlag2) goto useRealValueB;

    f2 = (float) b.value.integer;
    goto compareValues;

useRealValueB:
    f2 = b.value.real;

compareValues:
    result = f1 < f2;
    return result;
}

int isGreaterThanOrEquals(number a, number b) {
    int ifFlag1;
    int ifFlag2;
    int result;

    float f1;
    float f2;

    ifFlag1 = a.isInteger && b.isInteger;
    if (!ifFlag1) goto notBothIntegers;

    result = a.value.integer >= b.value.integer;
    return result;

notBothIntegers:
    ifFlag2 = a.isInteger;
    if (!ifFlag2) goto useRealValueA;

    f1 = (float) a.value.integer;
    goto checkB;

useRealValueA:
    f1 = a.value.real;

checkB:
    ifFlag2 = b.isInteger;
    if (!ifFlag2) goto useRealValueB;

    f2 = (float) b.value.integer;
    goto compareValues;

useRealValueB:
    f2 = b.value.real;

compareValues:
    result = f1 >= f2;
    return result;
}


int isLessThanOrEquals(number a, number b) {
    int ifFlag1;
    int ifFlag2;
    int result;

    float f1;
    float f2;

    ifFlag1 = a.isInteger && b.isInteger;
    if (!ifFlag1) goto notBothIntegers;

    result = a.value.integer <= b.value.integer;
    return result;

notBothIntegers:
    ifFlag2 = a.isInteger;
    if (!ifFlag2) goto useRealValueA;

    f1 = (float) a.value.integer;
    goto checkB;

useRealValueA:
    f1 = a.value.real;

checkB:
    ifFlag2 = b.isInteger;
    if (!ifFlag2) goto useRealValueB;

    f2 = (float) b.value.integer;
    goto compareValues;

useRealValueB:
    f2 = b.value.real;

compareValues:
    result = f1 <= f2;
    return result;
}

int getIntegerValueFromNumber(number a, int currentLine) {
    int i1;

    if (a.isInteger) goto isIntegerIf;
    dispatchError("Expected integer value", currentLine);
isIntegerIf:

    i1 = a.value.integer;
    
    return i1;
}

char numberToChar(number a) {
    int i1;

    if (a.isInteger) goto integerIf;
floatIf:
    i1 = (int) a.value.real;
    goto endIf;
integerIf:
    i1 = a.value.integer;
endIf:
    
    return (char) i1;   
}

bool numberToBool(number a) {
    int i1;

    if (a.isInteger) goto integerIf;

floatIf:
    i1 = (int) a.value.real;
    goto endIf;
integerIf:
    i1 = a.value.integer;
endIf:

    return i1 != 0;
}

int isNumberEquals(number a, number b) {
    int ifFlag1;
    int ifFlag2;
    int result;

    float f1;
    float f2;

    ifFlag1 = (a.isInteger == b.isInteger);
    if (!ifFlag1) goto notEqualType;

    ifFlag2 = a.isInteger;
    if (!ifFlag2) goto checkRealValues;

    result = (a.value.integer == b.value.integer);
    return result;

checkRealValues:
    result = (a.value.real == b.value.real);
    return result;

notEqualType:
    ifFlag2 = a.isInteger;
    if (!ifFlag2) goto useRealValueA;

    f1 = (float) a.value.integer;
    goto checkB;

useRealValueA:
    f1 = a.value.real;

checkB:
    ifFlag2 = b.isInteger;
    if (!ifFlag2) goto useRealValueB;

    f2 = (float) b.value.integer;
    goto compareValues;

useRealValueB:
    f2 = b.value.real;

compareValues:
    result = (f1 == f2);
    return result;
}

String numberToString(number n) {
    String str;

    str.str = (char*) malloc(12);

    if (n.isInteger) goto integerIf;

floatIf:
    sprintf(str.str, "%f", n.value.real);
    goto endIf;
integerIf:
    sprintf(str.str, "%d", n.value.integer);
endIf:

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

int calculateArrayTotalSize(int* dimensions) {
    int dimensionsLength = dimensions[0];

    int i;
    int totalSize;

    int ifFlag;

    i = 2;
    totalSize = dimensions[1];

startWhile:
    ifFlag = i <= dimensionsLength;
    if (!ifFlag) goto endWhile;
    totalSize = totalSize * dimensions[i];
    i = i + 1;
    goto startWhile;
endWhile:
    
    return totalSize;
}

int calculateArrayIndex(int* dimensions, int* indexes, int currentLine) {
    int dimensionsLength;

    dimensionsLength = dimensions[0];

    if (dimensionsLength == indexes[0]) goto equalsDimensions;
    dispatchError("Expected array selector with same number of dimensions of the original array.", currentLine);
equalsDimensions:

    int index;
    int multiplicador = 1;

    int ifFlag;

    index = 0;
    multiplicador = 1;

startFor:
    ifFlag = dimensionsLength > 0;
    if (!ifFlag) goto endFor;
    index = index + multiplicador * indexes[dimensionsLength];
    multiplicador = multiplicador * dimensions[dimensionsLength];
    dimensionsLength = dimensionsLength - 1;
    goto startFor;
endFor:

    if (index >= 0) goto positiveIndex;
    dispatchError("Array index out of bounds (negative number)", currentLine);
positiveIndex:

    int maxIndex;

    maxIndex = calculateArrayTotalSize(dimensions);

    if (index < maxIndex) goto indexInBounds;
    dispatchError("Array index out of bounds (exceed maximum index)", currentLine);
indexInBounds:

    return index;
}

NumberArray getArrayLength(int* dimensions) {
    int dimensionsLength;

    NumberArray numberArray;
    int totalDimensions;
    int sizeOfSum;
    int twoSizeOfSum;

    dimensionsLength = dimensions[0];
    totalDimensions = dimensionsLength + 1;
    sizeOfSum = totalDimensions * sizeof(int);
    twoSizeOfSum = 2 * sizeof(int);

    numberArray.array = (number*) malloc(sizeOfSum);
    numberArray.dimensions = (int*) malloc(twoSizeOfSum);

    numberArray.array[0].isInteger = true;
    numberArray.array[0].value.integer = dimensionsLength;
    
    numberArray.dimensions[0] = 1;
    numberArray.dimensions[1] = totalDimensions;

    int i;
    int ifFlag;

    i = 1;

startFor:
    ifFlag = i <= dimensionsLength;
    if (!ifFlag) goto endFor;
    numberArray.array[i].isInteger = true;
    numberArray.array[i].value.integer = dimensions[i];
    i = i + 1;
    goto startFor;
endFor:
    
    return numberArray;
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