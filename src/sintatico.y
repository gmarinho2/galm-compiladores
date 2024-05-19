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

%token TK_ID TK_INTEGER TK_INTEGER_BASE TK_REAL TK_AS

%token TK_CHAR TK_STRING TK_INTER_STRING TK_INTER_START TK_INTER_END TK_LENGTH

%token TK_IF TK_ELSE TK_FOR TK_IN TK_WHILE TK_DO

%token TK_LET TK_CONST TK_FUNCTION TK_TYPE TK_VOID

%token TK_AND TK_OR TK_BOOLEAN TK_NOT

%token TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS 

%token TK_DIV TK_POW TK_CONCAT

%token TK_BITAND TK_BITOR TK_BITXOR TK_BITLEFT TK_BITRIGHT TK_BITNOT

%token TK_PRINTLN TK_PRINT TK_SCAN

%start S

%right '='
%right TK_AS

%left TK_ASSERT_EQUALS

%left TK_AND TK_OR
%left TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS

%left '+' '-'
%left '*' '/' TK_DIV '%'
%right TK_POW
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

COMMAND             : '{' COMMANDS '}' { $$.translation = $2.translation; }
                    | VARIABLE_DECLARATION { $$ = $1; }
                    | EXPRESSION { $$ = $1; }
                    | CONDITIONALS { $$ = $1; }
                    | CONTROL_STRUCTURE { $$ = $1;}
                    | TK_BREAK_LINE {
                        $$ = $1;
                        addLine();
                    }

/**
 * Functions
 */


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
                    | TYPES { $$ = $1; }
                    | BITWISE {$$ = $1;}
                    | '(' EXPRESSION ')' { $$ = $2; }
                    | FUNCTIONS { $$ = $1; }
                    | TK_ID {
                        Variable* var = findVariableByName($1.label);

                        if (var == NULL) {
                            yyerror("Cannot found symbol \"" + $1.label + "\"");
                            return -1;
                        }

                        if (isVoid(var->getVarType())) {
                            yyerror("The variable " + $1.label + " was not initialized yet");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = var->getVarType();
                        $$.details = var->getDetails();

                        string realName = var->getRealVarLabel();
                        string translation = "";
                        
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, $$.details == REAL_NUMBER_ID, true, true);

                        if ($$.type == STRING_ID) {
                            createString($$.label, translation, realName + STRING_SIZE_STR);
                            translation += $$.label + " = strCopy(" + realName + ", " + realName + STRING_SIZE_STR + ");\n";
                        } else {
                            translation += $$.label + " = " + realName + ";\n";
                        }

                        $$.translation = translation;
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
                        $$.details = $4.details;
                        
                        string fakeLabel = $4.label;

                        Variable *var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, $$.details == REAL_NUMBER_ID, false);

                        if ($$.type == STRING_ID) {
                            createString($$.label, translation, $4.label + STRING_SIZE_STR);
                            translation += $$.label + " = strCopy(" + fakeLabel + ", " + $4.label + STRING_SIZE_STR + ");\n";
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
                        $$.details = $4.details;

                        Variable *var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, $$.details == REAL_NUMBER_ID, true);

                        if ($$.type == STRING_ID) {
                            createString($$.label, translation, $4.label + STRING_SIZE_STR);
                            translation += $$.label = " = strCopy(" + $4.label + ", " + $4.label + STRING_SIZE_STR + ");\n";
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

                        if (variavel->isNumber()) {
                            variavel->setIsReal($3.details == REAL_NUMBER_ID);
                        }

                        $$.label = gentempcode();
                        $$.type = varType;
                        $$.details = $1.details;

                        string translation = $1.translation + $3.translation;
                        string realName = variavel->getRealVarLabel();

                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, $$.details == REAL_NUMBER_ID, true, true);

                        if ($$.type == STRING_ID) {
                            createString($$.label, translation, $3.label + STRING_SIZE_STR);
                            createString(realName, translation, $3.label + STRING_SIZE_STR);

                            translation += $$.label + " = strCopy(" + $3.label + ", " + $3.label + STRING_SIZE_STR + ");\n";
                            translation += realName + " = strCopy(" + $3.label + ", " + $3.label + STRING_SIZE_STR + ");\n";
                        } else {
                            translation += $$.label + " = " + $3.label + ";\n";
                            translation += realName + " = " + $3.label + ";\n";
                        }

                        $$.translation = translation;
                    };

/**
 * Types
 */

 TYPES              : TK_BOOLEAN { 
                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, false, true, true);
                        $$.translation = $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_REAL {
                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.details = REAL_NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, true, true, true);
                        $$.translation = $$.label + " = " + $1.label + ";\n";
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
                        $$.details = INTEGER_NUMBER_ID;

                        createVariableIfNotExists($$.label, $$.label, $$.type, to_string(decimal), false, true, true);

                        $$.translation = $$.label + " = " + to_string(decimal) + ";\n";
                    }
                    | TK_INTEGER  { 
                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.details = INTEGER_NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, false, true, true);
                        $$.translation = $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_CHAR  { 
                        $$.label = gentempcode();
                        $$.type = CHAR_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, false, true, true);
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

                        createVariableIfNotExists($$.label, $$.label, $$.type, value, false, true, true);

                        createString($$.label, translation, to_string(size));

                        translation += $$.label + " = (char*) malloc(" + to_string(size + 1) + ");\n";

                        for (int i = 0; i < size; i++) {
                            translation += $$.label + "[" + to_string(i) + "] = '" + originalString[i + 1] + "';\n";
                        }

                        translation += $$.label + "[" + to_string(size) + "] = '\\0';\n";

                        $$.translation = translation;
                    }
                    | STRING_INTERPOL {
                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        string translation = $1.translation;

                        string value = $1.label;

                        createVariableIfNotExists($$.label, $$.label, $$.type, value, false, true, true);

                        translation += $$.label + " = " + value + ";\n";

                        createString($$.label, translation, "strLen(" + $$.label + ")");
                        $$.translation = translation;
                    }

STRING_INTERPOL     : '`' STRING_PIECE '`'                 { 
                        $$ = $2;
                    }
                    | '`' STRING_PIECE STRING_PIECE_LIST '`'      { 
                        $$.label = "concat(" + $2.label + ", " + $3.label + ")";
                        $$.translation = $2.translation + $3.translation;
                        $$.details = $2.label + STRING_SIZE_STR + " + " + $3.label + STRING_SIZE_STR;
                    }

STRING_PIECE       : TK_INTER_STRING                      { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        string translation = "";

                        createVariableIfNotExists($$.label, $$.label, STRING_ID, $1.label, false, true, true);

                        translation += $$.label + " = (char*) malloc(1);\n";
                        translation += $$.label + "[0] = '" + $1.label + "';\n";

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
                        $$.details = $1.details;
                    }
                    | STRING_PIECE_LIST STRING_PIECE { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;
                        
                        string translation = $1.translation + $2.translation;

                        createVariableIfNotExists($$.label, $$.label, $$.type, "", false, true, true);

                        translation += $$.label + " = concat(" + $1.label + ", " + $2.label + ");\n";

                        $$.translation = translation;
                    }

/**
 * Explicit type casting
 */

CAST                : TK_AS EXPRESSION {
                        $1.label = toId($1.label.substr(1, $1.label.find(")") - 1));

                        string translation = "";

                        $$.label = gentempcode();
                        $$.type = $1.label;
                        $$.details = $$.type == NUMBER_ID ? INTEGER_NUMBER_ID : "";

                        string tLabel = translate($2, translation, $1.label, $$.details);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + tLabel + ";\n";

                        $$.translation = $2.translation + translation;
                    }

 
/**
 * Functions
 */

FUNCTIONS           : TK_PRINTLN '(' EXPRESSION ')' {
                        $$.translation = $3.translation + "cout << " + $3.label + " << endl;\n";
                    }
                    | TK_PRINT '(' EXPRESSION ')' {
                            $$.translation = $3.translation + "cout << " + $3.label + ";\n";
                    }
                    | TK_ASSERT_EQUALS '(' EXPRESSION ',' EXPRESSION ')' {
                        if ($3.type != $5.type) {
                            yyerror("The assert function only be used with two variavels of the same type.", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation + $5.translation;

                        string ifTempLabel = gentempcode();
                        createVariableIfNotExists(ifTempLabel, ifTempLabel, BOOLEAN_ID, "", false, true, true);

                        translation += "\n/* Assert Line " + to_string(getCurrentLine()) + " */\n";
                        translation += ifTempLabel + " = " + $3.label + " != " + $5.label + ";\n\n";

                        string ifNotLabel = gentempcode();
                        createVariableIfNotExists(ifNotLabel, ifNotLabel, BOOLEAN_ID, "", false, true, true);

                        translation += ifNotLabel + " = !" + ifTempLabel + ";\n";

                        string ifGotoLabel = genlabelcode();

                        translation += "if (" + ifNotLabel + ") goto " + ifGotoLabel + ";\n";
                        translation += "cout << \"\\033[4;31m"
                                "The test in line " + to_string(getCurrentLine()) + " failed... "
                                "Cannot assert \" << " +
                                $3.label +
                                " << \" is equals to \" << " +
                                $5.label +
                                " << \""
                                "\\033[0m\" << endl;"
                                "\nexit(1);"
                                "\n";
                        translation += ifGotoLabel + ":\n";

                        $$.translation = translation;
                    }
                    | EXPRESSION '.' TK_LENGTH {
                        if ($1.type != STRING_ID) {
                            yyerror("The length operator must be used with a string type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.details = INTEGER_NUMBER_ID;

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        $$.translation = $1.translation + $$.label + " = " + $1.label + STRING_SIZE_STR + ";\n";
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

                        createVariableIfNotExists($$.label, $$.label, STRING_ID, $$.label, false, true, true);
                        createString($$.label, translation, fLabel + STRING_SIZE_STR + " + " + sLabel + STRING_SIZE_STR);

                        $$.translation = translation + $$.label + " = concat(" + fLabel + ", " + sLabel + ");\n";
                    }

/**
 * Arithmetic expressions
 */

 ARITMETIC          : EXPRESSION '*' EXPRESSION {
                        $$.type = NUMBER_ID;

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        string translation = $3.translation;
                        string fLabel = $1.label;
                        string sLabel = $3.label;

                        if ($$.details == REAL_NUMBER_ID) {
                            fLabel = translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                            sLabel = translate($3, translation, NUMBER_ID, REAL_NUMBER_ID);
                        }

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " * " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION TK_DIV EXPRESSION {
                        $$.type = NUMBER_ID;
                        $$.details = INTEGER_NUMBER_ID;

                        string translation = $3.translation;

                        string fLabel = translate($1, translation, NUMBER_ID, INTEGER_NUMBER_ID);
                        string sLabel = translate($3, translation, NUMBER_ID, INTEGER_NUMBER_ID);

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        translation += $$.label + " = " + fLabel+ " / " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION '/' EXPRESSION { 
                        $$.type = NUMBER_ID;
                        $$.details = REAL_NUMBER_ID;

                        string translation = $3.translation;

                        string fLabel = translate($1, translation, NUMBER_ID, INTEGER_NUMBER_ID);
                        string sLabel = translate($3, translation, NUMBER_ID, INTEGER_NUMBER_ID);

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true, true);

                        translation += $$.label + " = " + fLabel + " / " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION '+' EXPRESSION {
                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        string translation = $3.translation;
                        string fLabel = $1.label;
                        string sLabel = $3.label;

                        if ($$.details == REAL_NUMBER_ID) {
                            fLabel = translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                            sLabel = translate($3, translation, NUMBER_ID, REAL_NUMBER_ID);
                        }

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " + " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION '-' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator - must be used with a number type");
                            return -1;
                        }

                        $$.type = NUMBER_ID;

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        string translation = $3.translation;
                        string fLabel = $1.label;
                        string sLabel = $3.label;

                        if ($$.details == REAL_NUMBER_ID) {
                            fLabel = translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                            sLabel = translate($3, translation, NUMBER_ID, REAL_NUMBER_ID);
                        }

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " - " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION '%' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operador absolute must be used with a number type");
                            return -1;
                        }

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            yyerror("The operador absolute must be used with an integer type");
                            return -1;
                        }
                        
                        string translation = $3.translation;

                        string div = gentempcode();
                        createVariableIfNotExists(div, div, NUMBER_ID, div, false, true, true);

                        translation += div + " = " + $1.label + " / " + $3.label + ";\n";

                        string mult = gentempcode();
                        createVariableIfNotExists(mult, mult, NUMBER_ID, mult, false, true, true);

                        translation += mult + " = " + div + " * " + $3.label + ";\n";

                        string mod = gentempcode();
                        createVariableIfNotExists(mod, mod, NUMBER_ID, mod, false, true, true);

                        translation += mod + " = " + $1.label + " - " + mult + ";\n";

                        string mask = gentempcode();
                        createVariableIfNotExists(mask, mask, NUMBER_ID, mask, false, true, true);

                        translation += mask + " = " + mod + " >> 31;\n";

                        string exclusiveOr = gentempcode();
                        createVariableIfNotExists(exclusiveOr, exclusiveOr, NUMBER_ID, exclusiveOr, false, true, true);

                        translation += exclusiveOr + " = " + mask + " ^ " + mod + ";\n";

                        string absolute = gentempcode();
                        createVariableIfNotExists(absolute, absolute, NUMBER_ID, absolute, false, true, true);

                        translation += absolute + " = " + exclusiveOr + " - " + mask + ";\n";

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + absolute + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_POW EXPRESSION {
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

                        if ($2.details == REAL_NUMBER_ID) {
                            yyerror("The operador absolute must be used with an integer type");
                            return -1;
                        }

                        string translation = "";

                        string mask = gentempcode();
                        createVariableIfNotExists(mask, mask, NUMBER_ID, mask, false, true, true);

                        translation += mask + " = " + $2.label + " >> 31;\n";

                        string exclusiveOr = gentempcode();
                        createVariableIfNotExists(exclusiveOr, exclusiveOr, NUMBER_ID, exclusiveOr, false, true, true);

                        translation += exclusiveOr + " = " + mask + " ^ " + $2.label + ";\n";

                        string absolute = gentempcode();
                        createVariableIfNotExists(absolute, absolute, NUMBER_ID, absolute, false, true, true);

                        translation += absolute + " = " + exclusiveOr + " - " + mask + ";\n";

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + absolute + ";\n";
                        $$.translation = $2.translation + translation;
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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        translation += $$.label + " = " + fLabel + " || " + sLabel + ";\n";
                        $$.translation = $1.translation + translation;
                    }
                    |
                    TK_NOT EXPRESSION {
                        string translation = "";

                        string fLabel = translate($2, translation, BOOLEAN_ID);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

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
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        string fLabel = translate($1, translation, NUMBER_ID, details);
                        string sLabel = translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " > " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_LESS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator < must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        string fLabel = translate($1, translation, NUMBER_ID, details);
                        string sLabel = translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " < " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_GREATER_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator >= must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        string fLabel = translate($1, translation, NUMBER_ID, details);
                        string sLabel = translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " >= " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_LESS_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator <= must be used with a number type", "No match operator");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        string fLabel = translate($1, translation, NUMBER_ID, details);
                        string sLabel = translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        translation += $$.label + " = " + fLabel + " <= " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_DIFFERENT EXPRESSION {
                        if ($1.type != $3.type && (!isInterpretedAsNumeric($1.type) || !isInterpretedAsNumeric($3.type))) {
                            yyerror("The operator != must be used with the same type", "No match operator");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        string translation = $1.translation + $3.translation;

                        string sLabel = translate($3, translation, $1.type, $1.details);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        $$.translation = translation + $$.label + " = " + $1.label + " != " + sLabel + ";\n";
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

                        string sLabel = translate($3, translation, $1.type, $1.details);
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        if ($1.type == STRING_ID) { //TODO
                            string aux = gentempcode();
                            createVariableIfNotExists(aux, aux, BOOLEAN_ID, aux, false, true, true);

                            translation += $$.label + " = " + $1.label + STRING_SIZE_STR + " == " + sLabel + STRING_SIZE_STR + ";\n";
                        } else {
                            translation += $$.label + " = " + $1.label + " == " + sLabel + ";\n";
                        }

                        $$.translation = translation;
                    }

/**
 * Bitwise expressions
 */

BITWISE             : EXPRESSION TK_BITAND EXPRESSION {
                        if($1.type != CHAR_ID && $1.type != NUMBER_ID || $3.type != CHAR_ID && $3.type != NUMBER_ID){
                            if($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID){
                                yyerror("The operator & must be used with a number or char type");
                            }
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " & " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_BITOR EXPRESSION {
                        if($1.type != CHAR_ID && $1.type != NUMBER_ID || $3.type != CHAR_ID && $3.type != NUMBER_ID){
                            if($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID){
                                yyerror("The operator | must be used with a number or char type");
                            }
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " | " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_BITXOR EXPRESSION {
                        if($1.type != CHAR_ID && $1.type != NUMBER_ID || $3.type != CHAR_ID && $3.type != NUMBER_ID){
                            if($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID){
                                yyerror("The operator ^ must be used with a number or char type");
                            }
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " ^ " + $3.label + ";\n";
                    }
                    |
                    TK_BITNOT EXPRESSION {
                        if($2.type != CHAR_ID && $2.type != NUMBER_ID){
                            if($2.details == REAL_NUMBER_ID)
                                yyerror("The operator ~ must be used with a number or char type");
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $2.translation + $$.label + " = " + "~ " + $2.label + ";\n";
                    }
                    |
                    EXPRESSION TK_BITLEFT EXPRESSION {
                        if($1.type != CHAR_ID && $1.type != NUMBER_ID || $3.type != CHAR_ID && $3.type != NUMBER_ID){
                            if($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID){
                                yyerror("The operator << must be used with a number or char type");
                            }
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " << " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_BITRIGHT EXPRESSION {
                        if($1.type != CHAR_ID && $1.type != NUMBER_ID || $3.type != CHAR_ID && $3.type != NUMBER_ID){
                            if($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID){
                                yyerror("The operator >> must be used with a number or char type");
                            }
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " >> " + $3.label + ";\n";
                    }


/** Control structures 
 *
 */
CONTROL_STRUCTURE   : TK_WHILE '(' EXPRESSION ')' COMMAND {
                        if($3.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();                       
                        string inicioWhileLabel = genlabelcode();
                        string fimWhileLabel = genlabelcode();

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, false, true);

                        string translation;

                        translation += inicioWhileLabel + ": \n";
                        translation += $3.translation;
                        translation += temp + " = !(" + $3.label + "); \n";
                        translation += "if (" + temp + ") goto " + fimWhileLabel + ";\n";
                        translation += $5.translation;
                        translation += "goto " + inicioWhileLabel + ";\n";
                        translation += fimWhileLabel + ": \n";

                        $$.translation = translation;
                    }
                    |
                    TK_DO COMMAND TK_WHILE '(' EXPRESSION ')'{
                        if($5.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();                       
                        string inicioWhileLabel = genlabelcode();
                        string fimWhileLabel = genlabelcode();

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, false, true);

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
                    }
                    | TK_FOR '(' MULTIPLE_ASSIGNMENTS ';' EXPRESSION_OR_TRUE ';' MULTIPLE_EXPRESSIONS ')' COMMAND {
                        if ($5.type != BOOLEAN_ID) {
                            yyerror("The expression (the second statement in the for) must be a boolean");
                        }

                        string temp = gentempcode();
                        string inicioForLabel = genlabelcode();
                        string fimForLabel = genlabelcode();

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, false, true);

                        string translation;

                        translation += $3.translation;
                        translation += inicioForLabel + ": \n";
                        translation += $5.translation;
                        translation += temp + " = !(" + $5.label + "); \n";
                        translation += "if (" + temp + ") goto " + fimForLabel + ";\n";
                        translation += $9.translation;
                        translation += $7.translation;
                        translation += "goto " + inicioForLabel + ";\n";
                        translation += fimForLabel + ": \n";

                        $$.translation = translation;
                    }
                    |
                    TK_FOR '(' TK_ID TK_IN TK_ID ')' COMMAND {

                    }

EXPRESSION_OR_TRUE  : EXPRESSION {
                        $$ = $1;
                    }
                    | 
                    {
                        string temp = gentempcode();
                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "true", false, false, true);

                        $$.label = temp;
                        $$.type = BOOLEAN_ID;
                        $$.translation = temp + " = true;\n";
                    }

MULTIPLE_ASSIGNMENTS: ASSIGNMENT {
                        $$.translation = $1.translation;
                    }
                    | MULTIPLE_ASSIGNMENTS ',' ASSIGNMENT {
                        $$.translation = $1.translation + $3.translation;
                    }
                    | { $$.translation = ""; }

MULTIPLE_EXPRESSIONS: EXPRESSION {
                        $$.translation = $1.translation;
                    }
                    | MULTIPLE_EXPRESSIONS ',' EXPRESSION {
                        $$.translation = $1.translation + $3.translation;
                    }
                    | { $$.translation = ""; }
/**
 * Conditionals
 */

CONDITIONALS        : TK_IF '(' EXPRESSION ')' COMMAND %prec THEN {
                        if($3.type != BOOLEAN_ID) yyerror("Must be a boolean");

                        string temp = gentempcode();                       
                        string ifLabel = genlabelcode();

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, false, true);

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

                        createVariableIfNotExists(temp, temp, BOOLEAN_ID, "", false, false, true);

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
    init();
	yyparse();
	return 0;
}
