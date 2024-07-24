%{
#include <iostream>
#include <string>
#include <sstream>
#include "../src/app/headers/variaveis.h"
#include "../src/app/headers/translation.h"

#define YYSTYPE Atributo

using namespace variaveis;
using namespace translation;

int yylex(void);
%}

%token TK_BREAK_LINE TK_ASSERT_EQUALS

%token TK_ID TK_INTEGER TK_INTEGER_BASE TK_REAL TK_LIKE

%token TK_CHAR TK_STRING TK_INTER_STRING TK_INTER_START TK_INTER_END TK_LENGTH

%token TK_IF TK_ELSE TK_FOR TK_IN TK_WHILE TK_DO

%token TK_LET TK_CONST TK_FUNCTION TK_TYPE TK_VOID

%token TK_AND TK_OR TK_BOOLEAN TK_NOT

%token TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS 

%token TK_DIV TK_POW TK_CONCAT

%token TK_BITAND TK_BITOR TK_BITXOR TK_BITLEFT TK_BITRIGHT TK_BITNOT

%token TK_PRINTLN TK_PRINT TK_SCAN TK_TYPEOF

%token TK_ARROW TK_SWITCH TK_BREAK TK_CONTINUE

%start S

%right '='
%right TK_LIKE

%left TK_AND
%left TK_OR
%left TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS

%left '+' '-'
%left '*' '/' TK_DIV '%'
%right TK_POW
%left UNARY
%right '.'

%left TK_CONCAT
%left TK_BITAND TK_BITOR TK_BITLEFT TK_BITRIGHT TK_BITXOR
%left TK_NOT TK_BITNOT

%nonassoc THEN
%nonassoc TK_ELSE

%%

/**
 * The grammar is defined here
 * The first rule is the start symbol
 */

S                   : COMMANDS {
                        cout << gerarCodigo(indent($1.translation)) << endl;
                    };

/**
 * Commands and blocks
 */

COMMANDS            : COMMAND COMMANDS { $$.translation = $1.translation + $2.translation; }
                    | { $$.translation = ""; }

COMMAND             : PUSH_NEW_CONTEXT COMMANDS POP_CONTEXT { $$.translation = $2.translation; }
                    | VARIABLE_DECLARATION ';' { $$ = $1; }
                    | ASSIGNMENT ';' { $$ = $1; }
                    | FUNCTIONS ';' { $$ = $1; }
                    | BREAK_COMMAND OPTIONAL_SEMICOLON { $$ = $1; }
                    | CONTINUE_COMMAND OPTIONAL_SEMICOLON { $$ = $1; }
                    | CONDITIONALS { $$ = $1; }
                    | CONTROL_STRUCTURE { $$ = $1;}

OPTIONAL_SEMICOLON  : ';' {} | {}

PUSH_NEW_CONTEXT    : '{' {
                        Context *newContext = new Context();
                        getContextStack()->push(newContext);
                    }

POP_CONTEXT         : '}' {
                        getContextStack()->pop();
                    }

RETURN_TYPE         : ':' TK_TYPE { $$.type = $2.label; }
                    | ':' TK_VOID { $$.type = VOID_ID; }
                    | { $$.type = VOID_ID; }

 /**
 * Expressions
 */

EXPRESSION          : CAST { $$ = $1; }
                    | ARITMETIC { $$ = $1; }
                    | LOGICAL { $$ = $1; }
                    | RELATIONAL { $$ = $1; }
                    | ASSIGNMENT { $$ = $1; }
                    | STRING_CONCAT { $$ = $1; }
                    | LITERALS { $$ = $1; }
                    | BITWISE {$$ = $1;}
                    | '(' EXPRESSION ')' { $$ = $2; }
                    | FUNCTIONS { $$ = $1; }
                    | PRIMARY { $$ = $1; }

PRIMARY             : TK_ID {
                        Variable* var = findVariableByName($1.label);

                        if (var == NULL) {
                            yyerror("Cannot found symbol \"" + $1.label + "\"");
                            return -1;
                        }

                        if (isVoid(var->getVarType())) {
                            yyerror("The variable " + $1.label + " was not initialized yet");
                            return -1;
                        }

                        $$.label = var->getRealVarLabel();
                        $$.type = var->getVarType();
                    }
                    | TK_ID ARRAY_SELECTOR {
                        Variable* var = findVariableByName($1.label);

                        if (var == NULL) {
                            yyerror("Cannot found symbol \"" + $1.label + "\"");
                            return -1;
                        }

                        if (isVoid(var->getVarType())) {
                            yyerror("The variable " + $1.label + " was not initialized yet");
                            return -1;
                        }

                        if (!var->isArray()) {
                            yyerror("The variable " + $1.label + " is not an array");
                            return -1;
                        }

                        vector<string> stringIndexes = split($2.label, ", ");
                        int size = stringIndexes.size();

                        string sumSizeofNumber = gentempcode();
                        string dimensionsArrayInteger = gentempcode();
                        string indexInteger = gentempcode();

                        $$.label = gentempcode();
                        $$.type = getOriginalTypeFromArrayType(var->getVarType());

                        createVariableIfNotExists(sumSizeofNumber, sumSizeofNumber, "int", "", true, true);
                        createVariableIfNotExists(dimensionsArrayInteger, dimensionsArrayInteger, "int*", "", true, true);
                        createVariableIfNotExists(indexInteger, indexInteger, "int", "", true, true);
                        createVariableIfNotExists($$.label, $$.label, $$.type, "", true, true);

                        $$.translation = $2.translation;
                        $$.translation += sumSizeofNumber + " = sizeof(int) * " + to_string(size + 1) + ";\n";
                        $$.translation += dimensionsArrayInteger + " = (int*) malloc(" + sumSizeofNumber + ");\n";

                        $$.translation += dimensionsArrayInteger + "[0] = " + to_string(size) + ";\n";

                        for (int i = 0; i < size; i++) {
                            $$.translation += dimensionsArrayInteger + "[" + to_string(i + 1) + "] = getIntegerValueFromNumber(" + stringIndexes[i] + ", " + to_string(getCurrentLine()) + ");\n";
                        }

                        $$.translation += indexInteger + " = calculateArrayIndex(" + var->getRealVarLabel() + ".dimensions, " + dimensionsArrayInteger + ", " + to_string(getCurrentLine()) + ");\n";

                        $$.translation += $$.label + " = " + var->getRealVarLabel() + ".array[" + indexInteger + "];\n";
                    }

ARRAY_SELECTOR      : '[' EXPRESSION ']' {
                        if ($2.type != NUMBER_ID) {
                            yyerror("The array index must be a number");
                            return -1;
                        }

                        $$.label = $2.label;
                        $$.type = NUMBER_ID;
                        $$.translation = $2.translation;
                    }
                    | ARRAY_SELECTOR '[' EXPRESSION ']'  {
                        if ($3.type != NUMBER_ID) {
                            yyerror("The array index must be a number");
                            return -1;
                        }
                        
                        $$.label = $1.label + ", " + $3.label;
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + $3.translation;
                    }

/**
 * Variables
 */

VARIABLE_DECLARATION: TK_LET LET_VARS { $$ = $2; }
                    | TK_CONST CONST_VARS { $$ = $2; }

LET_VARS            : LET_VARS ',' LET_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | LET_VAR_DECLARTION { $$.translation = $1.translation; }

LET_VAR_DECLARTION  : TK_ID RETURN_TYPE {
                        $$.label = gentempcode(true);
                        $$.type = $2.type;
                        createVariableIfNotExists($1.label, $$.label, $2.type, "", false);

                        $$.translation = "";
                    }
                    |
                    TK_ID RETURN_TYPE '=' EXPRESSION {
                        if ($2.type != VOID_ID && $2.type != $4.type) {
                            yyerror("The type of the expression (" + $4.type + ") is not compatible with the type of the variable (" + $2.type + ")");
                            return -1;
                        }

                        string translation = $4.translation;

                        $$.label = gentempcode(true);
                        $$.type = $4.type;
                        
                        string fakeLabel = $4.label;

                        Variable *var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, false);

                        if ($$.type == STRING_ID) {
                            translation += $$.label + " = strCopy(" + fakeLabel + ");\n";
                        } else {
                            translation += var->getRealVarLabel() + " = " + fakeLabel + ";\n";
                        }

                        $$.translation = translation;
                    }

CONST_VARS          : CONST_VARS ',' CONST_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | CONST_VAR_DECLARTION { $$.translation = $1.translation; }

CONST_VAR_DECLARTION: TK_ID RETURN_TYPE {
                        yyerror("Cannot declare a constant without a value");
                    }
                    | TK_ID RETURN_TYPE '=' EXPRESSION {
                        if ($2.type != VOID_ID && $2.type != $4.type) {
                            yyerror("The type of the expression (" + $4.type + ") is not compatible with the type of the variable (" + $2.type + ")");
                            return -1;
                        }
                        
                        string translation = $4.translation;

                        $$.label = gentempcode(true);
                        $$.type = $4.type;

                        Variable *var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, true);

                        if ($$.type == STRING_ID) {
                            translation += $$.label = " = strCopy(" + $4.label + ");\n";
                        } else {
                            translation += var->getRealVarLabel() + " = " + $4.label + ";\n";
                        }

                        $$.translation = translation;
                    }
                    

ASSIGNMENT          : TK_ID '=' EXPRESSION {
                        Variable* variavel = findVariableByName($1.label);

                        if (variavel == NULL) {
                            yyerror("Cannot found symbol \"" + $1.label + "\"");
                            return -1;
                        }

                        string varType = isVoid(variavel->getVarType()) ? $3.type : variavel->getVarType();

                        if (variavel->alreadyInitialized()) {
                            if (variavel->getVarType() != $3.type) {
                                yyerror("The type of the expression (" + $3.type + ") is not compatible with the type of the variable (" + variavel->getVarType() + ")");
                                return -1;
                            }

                            if (variavel->isConstant()) {
                                yyerror("Cannot reassign value to constant variable");
                                return -1;
                            }
                        }

                        if (!variavel->alreadyInitialized()) {
                            variavel->setVarType(varType);
                        }

                        variavel->setVarValue($3.label);

                        $$.label = variavel->getRealVarLabel();
                        $$.type = varType;

                        string translation = $1.translation + $3.translation;

                        if ($$.type == STRING_ID) {
                            translation += $$.label + " = strCopy(" + $3.label + ");\n";
                        } else {
                            translation += $$.label + " = " + $3.label + ";\n";
                        }

                        $$.translation = translation;
                    };

/**
 * Types
 */

 LITERALS              : TK_BOOLEAN { 
                            $$.label = gentempcode();
                            $$.type = BOOLEAN_ID;
                            createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, true, true);
                            $$.translation = $$.label + " = " + $1.label + ";\n";
                        }
                        | TK_REAL {
                            $$.label = gentempcode();
                            $$.type = NUMBER_ID;
                            createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, true, true);
                            $$.translation = $$.label + ".value.real = " + $1.label + ";\n";
                            $$.translation += $$.label + ".isInteger = false;\n";
                        }
                        | TK_INTEGER  { 
                            $$.label = gentempcode();
                            $$.type = NUMBER_ID;
                            createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, true, true);
                            $$.translation = $$.label + ".value.integer = " + $1.label + ";\n";
                            $$.translation += $$.label + ".isInteger = true;\n";
                        }
                        | TK_INTEGER_BASE {
                            string label = $1.label;

                            bool negative = startsWith(label, "-");
                            
                            if (negative) {
                                label = label.substr(1, label.length() - 1);
                            }

                            int base;

                            if (startsWith(label, "0b")) {
                                for (int i = 2; i < label.length(); i++) {
                                    if (label[i] < '0' || label[i]  > '1') {
                                        yyerror("Invalid binary number, expecting only 0 and 1 and received " + string(1, label[i]), "Lexical error");
                                    }
                                }

                                base = 2;
                            } else if (startsWith(label, "0o")) {
                                for (int i = 2; i < label.length(); i++) {
                                    if (label[i] < '0' || label[i]  > '7') {
                                        yyerror("Invalid octal number, expecting only 0-7 and received " + string(1, label[i]), "Lexical error");
                                    }
                                }

                                base = 8;
                            } else if (startsWith(label, "0x")) {
                                for (int i = 2; i < label.length(); i++) {
                                    if ((label[i] < '0' || label[i]  > '9') && (label[i] < 'A' || label[i] > 'F')) {
                                        yyerror("Invalid hexadecimal number, expecting only 0-9 and A-F and received " + string(1, label[i]), "Lexical error");
                                    }
                                }

                                base = 16;
                            } else {
                                yyerror("Invalid base for integer number, expecting token starting with 0x for hexadecimal, 0b for binary or 0o for octal", 
                                    "Lexical base convertion error");
                            }

                            int decimal = stoi(label.substr(2, label.length() - 2), nullptr, base);

                            if (negative) {
                                decimal = -decimal;
                            }

                            $$.label = gentempcode();
                            $$.type = NUMBER_ID;

                            createVariableIfNotExists($$.label, $$.label, $$.type, to_string(decimal), true, true);

                            $$.translation = $$.label + ".value.integer = " + to_string(decimal) + ";\n";
                            $$.translation += $$.label + ".isInteger = true;\n";
                        }
                        | TK_CHAR  { 
                            $$.label = gentempcode();
                            $$.type = CHAR_ID;
                            createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, true, true);
                            $$.translation = $$.label + " = " + $1.label + ";\n";
                        }
                        | TK_STRING { 
                            $$.label = gentempcode();
                            $$.type = STRING_ID;

                            string translation = "";
                            string originalString = $1.label;
                            string value = "\"";
                            
                            int size = 0;

                            for (int i = 1; i < originalString.length() - 1; i++, size++) {
                                value += originalString[i];
                            }

                            value += "\"";

                            createVariableIfNotExists($$.label, $$.label, $$.type, value, true, true);

                            translation += $$.label + ".str = (char*) malloc(" + to_string(size) + ");\n";

                            for (int i = 0; i < size; i++) {
                                translation += $$.label + ".str[" + to_string(i) + "] = '" + originalString[i + 1] + "';\n";
                            }

                            translation += $$.label + ".length = " + to_string(size) + ";\n";

                            $$.translation = translation;
                        }
                        | STRING_INTERPOL {
                            $$.label = gentempcode();
                            $$.type = STRING_ID;

                            string translation = $1.translation;

                            string value = $1.label;

                            createVariableIfNotExists($$.label, $$.label, $$.type, value, true, true);

                            translation += $$.label + " = " + value + ";\n";

                            $$.translation = translation;
                        }
                        | ARRAY {
                            $$ = $1;
                        }

START_ARRAY         : '[' {
                        createArray();
                    }

FINISH_ARRAY        : ']' {
                        Array* array = popArrayStack();

                        if (isArrayStackEmpty()) {
                            string sumSizeofNumber = gentempcode();
                            string sumSizeofInt = gentempcode();

                            createVariableIfNotExists(sumSizeofNumber, sumSizeofNumber, "int", "", true, true);
                            createVariableIfNotExists(sumSizeofInt, sumSizeofInt, "int", "", true, true);

                            $$.label = gentempcode();
                            $$.type = getArrayTypeFromType(array->getType()); // se o tipo já for array, ele vai retornar o tipo do array
                            $$.translation = array->getTranslation($$.label, sumSizeofNumber, sumSizeofInt);
                            createVariableIfNotExists($$.label, $$.label, $$.type, "", true, true);
                        } else {
                            Array* parentArray = topArrayStack();

                            string parentType = getArrayTypeFromType(array->getType());

                            parentArray->addChild(array);
                            parentArray->setType(parentType);
                        }
                    }

ARRAY               : START_ARRAY ARRAY_VALUES FINISH_ARRAY {
                        $$ = $3;
                    }

ARRAY_VALUES        : MULTIPLE_ARRAY_VALUES { } | { }

MULTIPLE_ARRAY_VALUES: EXPRESSION {
                        if (!empty($1.type)){
                            Array* topArray = topArrayStack();

                            if (topArray->getType() == VOID_ID) {
                                topArray->setType(getArrayTypeFromType($1.type));
                            }
                            
                            topArray->addLabel($1.label + " - " + $1.translation);
                        }
                    } 
                    | MULTIPLE_ARRAY_VALUES ',' EXPRESSION {
                        if (!empty($3.type)) {
                            Array* topArray = topArrayStack();

                            if (topArray->getChilds().size() == 0) {
                                if (getOriginalTypeFromArrayType(topArray->getType()) != $3.type) {
                                    yyerror("The array must have the same type for all elements (expected " + getOriginalTypeFromArrayType(topArray->getType()) + " and received " + $3.type + ")", "Mismatch type");
                                    return -1;
                                }
                            }

                            topArray->addLabel($3.label + " - " + $3.translation);
                        }
                    }

STRING_INTERPOL     : '`' STRING_PIECE '`'                 { 
                        $$ = $2;
                    }
                    | '`' STRING_PIECE STRING_PIECE_LIST '`'      { 
                        $$.label = "concat(" + $2.label + ", " + $3.label + ")";
                        $$.translation = $2.translation + $3.translation;
                    }

STRING_PIECE       : TK_INTER_STRING                      { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        string translation = "";

                        createVariableIfNotExists($$.label, $$.label, STRING_ID, $1.label, true, true);

                        translation += $$.label + ".str = (char*) malloc(1);\n";
                        translation += $$.label + ".str[0] = '" + $1.label + "';\n";
                        translation += $$.label + ".length = 1;\n";

                        $$.translation = translation;
                    }
                    | TK_INTER_START EXPRESSION TK_INTER_END {
                        string translation = $2.translation;

                        string realLabel = translate($2, translation, STRING_ID);

                        $$.label = realLabel;
                        $$.translation = translation;
                    }

STRING_PIECE_LIST   : STRING_PIECE                         {
                        $$.label = $1.label;
                        $$.translation = $1.translation;
                    }
                    | STRING_PIECE_LIST STRING_PIECE { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;
                        
                        string translation = $1.translation + $2.translation;

                        createVariableIfNotExists($$.label, $$.label, $$.type, "", true, true);

                        translation += $$.label + " = concat(" + $1.label + ", " + $2.label + ");\n";

                        $$.translation = translation;
                    }

/**
 * Explicit type casting
 */

CAST                : EXPRESSION TK_LIKE TK_TYPE {
                        string translation = "";

                        $$.label = gentempcode();
                        $$.type = $3.label;

                        string tLabel = translate($1, translation, $$.type);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = " + tLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }

 
/**
 * Functions
 */

FUNCTIONS           : TK_PRINTLN '(' EXPRESSION ')' {
                        $$.type = VOID_ID;

                        string label = translate($3, $3.translation, STRING_ID);

                        $$.translation = $3.translation + "cout << " + label + ".str << endl;\n";
                    }
                    | TK_PRINT '(' EXPRESSION ')' {
                        $$.type = VOID_ID;

                        string label = translate($3, $3.translation, STRING_ID);

                        $$.translation = $3.translation + "cout << " + label + ".str;\n";
                    }
                    | TK_SCAN '(' ')' {
                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        createVariableIfNotExists($$.label, $$.label, $$.type, "", true, true);

                        $$.translation = $$.label + " = readInput();\n";
                    }
                    | TK_TYPEOF '(' EXPRESSION ')' {
                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        string translation = $3.translation;

                        string label = translate($3, translation, STRING_ID);

                        createVariableIfNotExists($$.label, $$.label, $$.type, "", true, true);

                        string originalString = toLowerCase($3.type);

                        translation += $$.label + ".str = (char*) malloc(" + to_string(originalString.length()) + ");\n";

                        for (int i = 0; i < originalString.length(); i++) {
                            translation += $$.label + ".str[" + to_string(i) + "] = '" + originalString[i] + "';\n";
                        }

                        translation += $$.label + ".length = " + to_string($3.type.length()) + ";\n";

                        $$.translation = $3.translation + translation;
                    }
                    | TK_ASSERT_EQUALS '(' EXPRESSION ',' EXPRESSION ')' {
                        if ($3.type != $5.type) {
                            yyerror("The assert function only be used with two variavels of the same type.", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation + $5.translation;

                        string ifTempLabel = gentempcode();
                        createVariableIfNotExists(ifTempLabel, ifTempLabel, BOOLEAN_ID, "", true, true);

                        translation += "\n/* Assert Line " + to_string(getCurrentLine()) + " */\n\n";
                    
                        if ($3.type == STRING_ID) {
                            translation += ifTempLabel + " = isStringEquals(" + $3.label + ", " + $5.label + ");\n";
                        } else if ($3.type == NUMBER_ID) {
                            translation += ifTempLabel + " = isNumberEquals(" + $3.label + ", " + $5.label + ");\n";
                        } else {
                            translation += ifTempLabel + " = " + $3.label + " == " + $5.label + ";\n";
                        }

                        string ifGotoLabel = genlabelcode();

                        string label1 = translate($3, translation, STRING_ID);
                        string label2 = translate($5, translation, STRING_ID);

                        translation += "\nif (" + ifTempLabel + ") goto " + ifGotoLabel + ";\n";
                        translation += "cout << \"\\033[4;31m"
                                "The test in line " + to_string(getCurrentLine()) + " failed... "
                                "Cannot assert \" << " +
                                label1 +
                                ".str << \" is equals to \" << " +
                                label2 +
                                ".str << \""
                                "\\033[0m\" << endl;"
                                "\nexit(1);"
                                "\n";
                        translation += ifGotoLabel + ":\n\n";

                        $$.type = VOID_ID;
                        $$.translation = translation;

                        if (!testMode) {
                            $$.translation = "";
                        }
                    }
                    | EXPRESSION '.' TK_LENGTH{
                        if ($1.type != STRING_ID) {
                            yyerror("The length operator must be used with a string type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation;
                        $$.translation += $$.label + ".value.integer = " + $1.label + ".length;\n";
                        $$.translation += $$.label + ".isInteger = true;\n";
                    }

/**
 * String concatenation
 */

STRING_CONCAT       : EXPRESSION TK_CONCAT EXPRESSION {
                        string translation = $1.translation + $3.translation;

                        string fLabel = translate($1, translation, STRING_ID);
                        string sLabel = translate($3, translation, STRING_ID);

                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        createVariableIfNotExists($$.label, $$.label, STRING_ID, $$.label, true, true);

                        $$.translation = translation + $$.label + " = concat(" + fLabel + ", " + sLabel + ");\n";
                    }

/**
 * Arithmetic expressions
 */

 ARITMETIC          : EXPRESSION '*' EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator * must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = multiply(" + $1.label + ", " + $3.label + ");\n";
                    }
                    | EXPRESSION TK_DIV EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator // must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = devideInteger(" + $1.label + ", " + $3.label + ");\n";
                    }
                    | EXPRESSION '/' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator / must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = divide(" + $1.label + ", " + $3.label + ");\n";
                    }
                    | EXPRESSION '+' EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator + must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = sum(" + $1.label + ", " + $3.label + ");\n";
                    }
                    | EXPRESSION '-' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator - must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = subtract(" + $1.label + ", " + $3.label + ");\n";
                    }
                    | EXPRESSION '%' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operador absolute must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);
                        
                        $$.translation = $3.translation + $1.translation + $$.label + " = mod(" + $1.label + ", " + $3.label + ");\n";
                    }
                    | EXPRESSION TK_POW EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator ^ must be used with a number type");
                            return -1;
                        }

                        string translation = $1.translation + $3.translation;

                        translation += $$.label + " = pow(" + $1.label + ", " + $3.label + ");\n";

                        $$.translation = translation;
                    }
                    | '|' EXPRESSION '|' {
                        if ($2.type != NUMBER_ID) {
                            yyerror("The operador absolute must be used with a number type");
                            return -1;
                        }

                        $$.translation = $2.translation + $$.label + " = absolute(" + $3.label + ");\n";
                    }

/**
 * Logical expressions
 */

LOGICAL             : EXPRESSION TK_AND EXPRESSION {
                        string translation = $3.translation;

                        string fLabel = translate($1, translation, BOOLEAN_ID);
                        string sLabel = translate($3, translation, BOOLEAN_ID);

                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = " + fLabel + " && " + sLabel + ";\n";
                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_OR EXPRESSION {
                        string translation = $3.translation;

                        string fLabel = translate($1, translation, BOOLEAN_ID);
                        string sLabel = translate($3, translation, BOOLEAN_ID);

                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = " + fLabel + " || " + sLabel + ";\n";
                        $$.translation = $1.translation + translation;
                    }
                    |
                    TK_NOT EXPRESSION {
                        string translation = "";

                        string fLabel = translate($2, translation, BOOLEAN_ID);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = !" + fLabel + ";\n";
                        $$.translation = $2.translation + translation;
                    }

/**
 * Relational expressions
 */

 RELATIONAL         : EXPRESSION TK_GREATER EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator > must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = isGreaterThan(" + $1.label + ", " + $3.label + ");\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_LESS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator < must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = isLessThan(" + $1.label + ", " + $3.label + ");\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_GREATER_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator >= must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = isGreaterThanOrEquals(" + $1.label + ", " + $3.label + ");\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_LESS_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator <= must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        translation += $$.label + " = isLessThanOrEquals(" + $1.label + ", " + $3.label + ");\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_DIFFERENT EXPRESSION {
                        if ($1.type != $3.type && (!isInterpretedAsNumeric($1.type) || !isInterpretedAsNumeric($3.type))) {
                            yyerror("The operator == must be used with the same type", "No match operator " + $1.type + " " + $3.type);
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        string translation = $1.translation + $3.translation;

                        string sLabel = translate($3, translation, $1.type);
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        if ($1.type == STRING_ID) {
                            translation += $$.label + " = isStringEquals(" + $1.label + ", " + sLabel + ");\n";
                            translation += $$.label + " = !" + $$.label + ";\n";
                        } else if ($1.type == NUMBER_ID) {
                            translation += $$.label + " = isNumberEquals(" + $1.label + ", " + sLabel + ");\n";
                            translation += $$.label + " = !" + $$.label + ";\n";
                        } else {
                            translation += $$.label + " = " + $1.label + " != " + sLabel + "; / * é aqui? */\n";
                        }

                        $$.translation = translation;
                    }
                    |
                    EXPRESSION TK_EQUALS EXPRESSION {
                        if ($1.type != $3.type && (!isInterpretedAsNumeric($1.type) || !isInterpretedAsNumeric($3.type))) {
                            yyerror("The operator == must be used with the same type", "No match operator " + $1.type + " " + $3.type);
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        string translation = $1.translation + $3.translation;

                        string sLabel = translate($3, translation, $1.type);
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        if ($1.type == STRING_ID) {
                            translation += $$.label + " = isStringEquals(" + $1.label + ", " + sLabel + ");\n";
                        } else if ($1.type == NUMBER_ID) {
                            translation += $$.label + " = isNumberEquals(" + $1.label + ", " + sLabel + ");\n";
                        } else {
                            translation += $$.label + " = " + $1.label + " == " + sLabel + ";\n";
                        }

                        $$.translation = translation;
                    }

/**
 * Bitwise expressions
 */

BITWISE             : EXPRESSION TK_BITAND EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator & must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = bitAnd(" + $1.label + ", " + $3.label + ", " + to_string(getCurrentLine()) + ");\n";
                    }
                    |
                    EXPRESSION TK_BITOR EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator | must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = bitOr(" + $1.label + ", " + $3.label + ", " + to_string(getCurrentLine()) + ");\n";
                    }
                    |
                    EXPRESSION TK_BITXOR EXPRESSION {
                         if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator ^ must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = bitXor(" + $1.label + ", " + $3.label + ", " + to_string(getCurrentLine()) + ");\n";
                    }
                    |
                    TK_BITNOT EXPRESSION {
                        if ($2.type != NUMBER_ID) {
                            yyerror("The operator ~ must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $2.translation + $$.label + " = bitNot(" + $2.label + ", " + to_string(getCurrentLine()) + ");\n";
                    }
                    |
                    EXPRESSION TK_BITLEFT EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator << must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = bitShiftLeft(" + $1.label + ", " + $3.label + ", " + to_string(getCurrentLine()) + ");\n";
                    }
                    |
                    EXPRESSION TK_BITRIGHT EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator >> must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = bitShiftRight(" + $1.label + ", " + $3.label + ", " + to_string(getCurrentLine()) + ");\n";
                    }


/** Control structures 
 *
 */
CONTROL_STRUCTURE   : START_WHILE_TOKEN '(' EXPRESSION ')' COMMAND {
                        if($3.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();                       
                        string inicioWhileLabel = $1.label.substr(0, $1.label.find(" "));
                        string fimWhileLabel = $1.label.substr($1.label.find(" ") + 1);    

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, true);

                        string translation;

                        translation += inicioWhileLabel + ": \n";
                        translation += $3.translation;
                        translation += temp + " = !(" + $3.label + "); \n";
                        translation += "if (" + temp + ") goto " + fimWhileLabel + ";\n";
                        translation += $5.translation;
                        translation += "goto " + inicioWhileLabel + ";\n";
                        translation += fimWhileLabel + ": \n";

                        $$.translation = translation;
                        getContextStack()->popEndableStatement();
                    }
                    | START_DO_WHILE_TOKEN COMMAND TK_WHILE '(' EXPRESSION ')'{
                        if($5.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();                       
                        string inicioWhileLabel = $1.label.substr(0, $1.label.find(" "));
                        string fimWhileLabel = $1.label.substr($1.label.find(" ") + 1);    

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, true);

                        string translation;

                        translation += $2.translation;
                        translation += inicioWhileLabel + ": \n";
                        translation += $5.translation;
                        translation += temp + " = !(" + $5.label + "); \n";
                        translation += "if (" + temp + ") goto " + fimWhileLabel + ";\n";
                        translation += $2.translation;
                        translation += "goto " + inicioWhileLabel + ";\n";
                        translation += fimWhileLabel + ": \n";

                        $$.translation = translation;
                        getContextStack()->popEndableStatement();
                    }
                    | START_FOR_TOKEN '(' FOR_ASSIGMENT ';' EXPRESSION_OR_TRUE ';' MULTIPLE_EXPRESSIONS ')' COMMAND {
                        if ($5.type != BOOLEAN_ID) {
                            yyerror("The expression (the second statement in the for) must be a boolean");
                        }

                        string temp = gentempcode();
                        string inicioForLabel = genlabelcode();
                        string inicioVerificacaoLabel = $1.label.substr(0, $1.label.find(" "));
                        string fimForLabel = $1.label.substr($1.label.find(" ") + 1);      

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, true);

                        string translation;

                        translation += $3.translation;
                        translation += inicioForLabel + ": \n";
                        translation += $5.translation;
                        translation += temp + " = !(" + $5.label + "); \n";
                        translation += "if (" + temp + ") goto " + fimForLabel + ";\n";
                        translation += $9.translation;
                        translation += inicioVerificacaoLabel + ":\n";
                        translation += $7.translation;
                        translation += "goto " + inicioForLabel + ";\n";
                        translation += fimForLabel + ": \n";

                        $$.translation = translation;
                        getContextStack()->popEndableStatement();
                        getContextStack()->pop();
                    }
                    | START_FOR_TOKEN '(' TK_ID TK_IN TK_ID ')' COMMAND {
                        getContextStack()->popEndableStatement();
                    }
                    | START_SWITCH '{' SWITCH_CASES '}' {
                        ContextStack* contextStack = getContextStack();
                        Switch* topSwitch = contextStack->popSwitch();

                        if (topSwitch->getCases().empty()) {
                            yyerror("The switch statement must have at least one case.");
                            return -1;
                        }

                        string translation = $1.translation;
                        string gotoTable = translation += "\n/* START SWITCH TABLE */\n\n";
                        string switchsCases;

                        for (SwitchCase* switchCase : topSwitch->getCases()) {
                            if (switchCase->isDefault()) continue;

                            translation += switchCase->getExpressionTranslation();

                            string caseLabel = genlabelcode();

                            vector<string> literals = split(switchCase->getLabel(), ",");

                            for (string literal : literals) {
                                string label = gentempcode();
                                Variable *variable = createVariableIfNotExists(label, label, BOOLEAN_ID, "", false, false);

                                if (topSwitch->getSwitchType() == STRING_ID) {
                                    gotoTable += label + " = isStringEquals(" + $1.label + ", " + literal + ");\n";
                                } else if (topSwitch->getSwitchType() == NUMBER_ID) {
                                    gotoTable += label + " = isNumberEquals(" + $1.label + ", " + literal + "); // OXE\n";
                                } else {
                                    gotoTable += label + " = " + $1.label + " == " + literal + ";\n";
                                }

                                gotoTable += "if (" + label + ") ";
                                gotoTable += "goto " + caseLabel + ";\n";
                            }

                            switchsCases += "\n/* START CASE " + switchCase->getLabel() + " */\n";
                            switchsCases += caseLabel + ":\n" + switchCase->getTranslation();
                            switchsCases += "/* END CASE " + switchCase->getLabel() + " */\n";
                        }

                        if (topSwitch->hasDefaultCase()) {
                            string defaultCaseLabel = genlabelcode();
                            SwitchCase* defaultCase = topSwitch->getDefaultCase();

                            gotoTable += "goto " + defaultCaseLabel + ";\n";

                            switchsCases += "\n/* START DEFAULT CASE */\n";
                            switchsCases += defaultCaseLabel + ":\n" + defaultCase->getTranslation();
                            switchsCases += "/* END DEFAULT CASE */\n";
                        }

                        string endSwitchLabel = topSwitch->getEndSwitchLabel();

                        switchsCases += "\n" + endSwitchLabel + ":\n";

                        gotoTable += "\n/* END SWITCH TABLE */\n";

                        $$.translation = "\n/* START SWITCH STATEMENT */\n\n" + translation + gotoTable + "\n" + switchsCases + "\n/* END SWITCH STATEMENT */\n";
                        contextStack->popEndableStatement();
                    }

START_WHILE_TOKEN   : TK_WHILE {
                        Context* context = getContextStack()->top();

                        string inicioWhileLabel = genlabelcode();
                        string fimWhileLabel = genlabelcode();

                        context->createEndableStatement(inicioWhileLabel, fimWhileLabel);

                        $$.label = inicioWhileLabel + " " + fimWhileLabel;
                    }

START_DO_WHILE_TOKEN: TK_DO {
                        Context* context = getContextStack()->top();

                        string inicioWhileLabel = genlabelcode();
                        string fimWhileLabel = genlabelcode();

                        context->createEndableStatement(inicioWhileLabel, fimWhileLabel);

                        $$.label = inicioWhileLabel + " " + fimWhileLabel;
                    }

START_FOR_TOKEN     : TK_FOR {
                        Context* context = new Context();

                        string inicioForLabel = genlabelcode();
                        string fimForLabel = genlabelcode();

                        getContextStack()->push(context);
                        context->createEndableStatement(inicioForLabel, fimForLabel);

                        $$.label = inicioForLabel + " " + fimForLabel;
                    }

START_SWITCH       : TK_SWITCH '(' PRIMARY ')' {
                        ContextStack* contextStack = getContextStack();
                        
                        string endSwitchLabel = genlabelcode();

                        contextStack->createEndableStatement("", endSwitchLabel, true);
                        contextStack->createSwitch($3.type, endSwitchLabel);

                        $$.translation = $3.translation;
                        $$.label = $3.label;
                    }

MULTIPLE_LITERALS  : LITERALS {
                        $$.label = $1.label;
                        $$.type = $1.type;
                        $$.translation = $1.translation;
                    }
                    | MULTIPLE_LITERALS ',' LITERALS {
                        if ($1.type != $3.type) {
                            yyerror("The literals of switch statement must have the same type.", "Type error");
                            return -1;
                        }

                        $$.label = $1.label + "," + $3.label;
                        $$.type = $1.type;
                        $$.translation = $1.translation + $3.translation;
                    }

SWITCH_CASES       : SWITCH_CASE {
                        $$.translation = $1.translation;
                    }
                    | SWITCH_CASES SWITCH_CASE {
                        $$.translation = $1.translation + $2.translation;
                    }

SWITCH_CASE        : MULTIPLE_LITERALS TK_ARROW COMMAND {
                        ContextStack* contextStack = getContextStack();

                        if (!contextStack->hasCurrentSwitch()) {
                            yyerror("The switch arrow case operator must be used inside a switch statement.");
                            return -1;
                        }

                        Switch* topSwitch = contextStack->topSwitch();

                        if (topSwitch->getSwitchType() != $1.type) {
                            yyerror("The switch case must have the same type as the switch statement. (Case " + $1.type + ", switch type " + topSwitch->getSwitchType() + ")");
                            return -1;
                        }

                        topSwitch->addCase($1.label, $1.translation, $3.translation);
                    }
                    | '_' TK_ARROW COMMAND {
                        ContextStack* contextStack = getContextStack();

                        if (!contextStack->hasCurrentSwitch()) {
                            yyerror("The switch arrow case operator must be used inside a switch statement.");
                            return -1;
                        }

                        Switch* topSwitch = contextStack->topSwitch();

                        if (topSwitch->hasDefaultCase()) {
                            yyerror("The switch statement already has a default case.");
                            return -1;
                        }

                        topSwitch->addExaustiveCase($3.translation);
                    }

EXPRESSION_OR_TRUE  : EXPRESSION {
                        $$ = $1;
                    }
                    | {
                        string temp = gentempcode();
                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "true", false, true);

                        $$.label = temp;
                        $$.type = BOOLEAN_ID;
                        $$.translation = temp + " = true;\n";
                    }

FOR_ASSIGMENT       : VARIABLE_DECLARATION { $$.translation = $1.translation; }
                    | MULTIPLE_ASSIGNMENTS { $$.translation = $1.translation; }
                    | { $$.translation = ""; }


MULTIPLE_ASSIGNMENTS: ASSIGNMENT {
                        $$.translation = $1.translation;
                    }
                    | MULTIPLE_ASSIGNMENTS ',' ASSIGNMENT {
                        $$.translation = $1.translation + $3.translation;
                    }

MULTIPLE_EXPRESSIONS: EXPRESSION {
                        $$.translation = $1.translation;
                    }
                    | MULTIPLE_EXPRESSIONS ',' EXPRESSION {
                        $$.translation = $1.translation + $3.translation;
                    }
                    | { $$.translation = ""; }

/**
* Break and Continue
*/

BREAK_COMMAND       : TK_BREAK {
                        ContextStack* contextStack = getContextStack();
                        EndableStatement* endable = contextStack->topEndableStatement();

                        if(endable == NULL) {
                            yyerror("The break statement must be used inside a loop or switch statement");
                            return -1;
                        }

                        if (endable->isSwitchStatement()) {
                            Switch* switchStatement = contextStack->topSwitch();

                            $$.translation = "goto " + switchStatement->getEndSwitchLabel() + ";\n";
                        } else {
                            string inicioLoopLabel = endable->getStartLabel();
                            string fimLoopLabel = endable->getEndLabel();

                            $$.translation = "goto " + fimLoopLabel + ";\n";
                        }
                    }

CONTINUE_COMMAND    : TK_CONTINUE {
                        ContextStack* contextStack = getContextStack();
                        EndableStatement* loop = contextStack->topLoopStatement();

                        if(loop == NULL) {
                            yyerror("The continue statement must be used inside a loop statement");
                            return -1;
                        }

                        if (loop->isSwitchStatement()) {
                            yyerror("The continue statement must be used inside a loop statement");
                            return -1;
                        }

                        string inicioLoopLabel = loop->getStartLabel();
                        $$.translation = "goto " + inicioLoopLabel + ";\n";
                    }

/**
 * Conditionals
 */

CONDITIONALS        : TK_IF '(' EXPRESSION ')' COMMAND %prec THEN {
                        if($3.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();                       
                        string ifLabel = genlabelcode();

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "",  false, true);

                        string translation = $3.translation;

                        translation += temp + " = !(" + $3.label + "); \n";
                        translation += "if (" + temp + ") goto " + ifLabel + ";\n";
                        translation += $5.translation;
                        translation += ifLabel + ": \n";

                        $$.translation = translation;
                    }
                    | TK_IF '(' EXPRESSION ')' COMMAND TK_ELSE COMMAND {
                        if($3.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();
                        string ifLabel = genlabelcode();
                        string elseLabel = genlabelcode();

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, true);

                        string translation = $3.translation;

                        translation += temp + " = !(" + $3.label + "); \n";
                        translation += "if(" + temp + ") goto " + elseLabel + ";\n";
                        translation += $5.translation;
                        translation += "goto " + ifLabel + ";\n";
                        translation += elseLabel + ": //\n";
                        translation += $7.translation;
                        translation += ifLabel + ": \n";

                        $$.translation = translation;
                    }
%%

#include "lexico.yy.c"

int yyparse();

int main(int argc, char* argv[])
{
    init(argc, argv);
	yyparse();
	return 0;
}
