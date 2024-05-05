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

%token TK_ID TK_INTEGER TK_INTEGER_BASE TK_REAL TK_CHAR TK_STRING TK_STRING_W_INTER TK_AS

%token TK_IF TK_ELSE TK_FOR TK_REPEAT TK_UNTIL

%token TK_LET TK_CONST TK_FUNCTION TK_TYPE TK_VOID

%token TK_AND TK_OR TK_BOOLEAN TK_NOT

%token TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS 

%token TK_DIV TK_POW TK_CONCAT

%token TK_BITAND TK_BITOR TK_BITXOR TK_BITLEFT TK_BITRIGHT TK_BITNOT

%token TK_PRINTLN TK_PRINT TK_SCAN

%token TK_FORBIDDEN

%start S

%right '='
%right TK_AS

%left TK_ASSERT_EQUALS

%left TK_AND TK_OR

%left '+' '-'
%left '*' '/' TK_DIV '%'
%right TK_POW

%left TK_CONCAT
%left TK_BITAND TK_BITOR TK_BITLEFT TK_BITRIGHT TK_BITXOR
%left TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS
%left TK_NOT TK_BITNOT

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
                    | '{' COMMANDS '}' COMMANDS {  $$.translation = "\n{\n" + indent($2.translation) + "}\n\n" + $4.translation; }
                    | { $$.translation = ""; }

COMMAND             : COMMAND ';' { $$ = $1; }
                    | VARIABLE_DECLARATION { $$ = $1; }
                    | EXPRESSION { $$ = $1; }
                    | TK_BREAK_LINE {
                        $$ = $1;
                        addLine();
                    }

ID                  : TK_FORBIDDEN {
                        yyerror("You are trying to use a reserved key \"" + $1.label + "\".");
                    }
                    | TK_ID { $$ = $1; }

/**
 * Functions
 */


RETURN_TYPE         : ':' TK_TYPE { $$.type = $2.label; }
                    | ':' TK_VOID { $$.type = "void"; }
                    | { $$.type = "void"; }

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
                    | ID {
                        bool found = false;
                        Variavel* var = findVariableByName($1.label, found);

                        if (!found) {
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
                        
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, $$.details == REAL_NUMBER_ID, true, true);

                        $$.translation = $$.label + " = " + realName + ";\n";
                    }

/**
 * Variables
 */

VARIABLE_DECLARATION: TK_LET LET_VARS { $$ = $2; }
                    | TK_CONST CONST_VARS { $$ = $2; }

LET_VARS            : LET_VARS ',' LET_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | LET_VAR_DECLARTION { $$.translation = $1.translation; }

LET_VAR_DECLARTION  : ID RETURN_TYPE {
                        $$.label = gentempcode(true);
                        Variavel var = createVariableIfNotExists($1.label, $$.label, $2.type, "", false);

                        $$.type = $2.type;
                        $$.translation = "";
                    }
                    |
                    ID RETURN_TYPE '=' EXPRESSION {
                        string translation = $4.translation;

                        $$.label = gentempcode(true);
                        $$.type = $2.type;
                        $$.details = $4.details;
                        
                        string fakeLabel = $4.label;

                        if ($2.type == "void") {
                            $$.type = $4.type;
                        } else {
                            string fakeLabel = translate($4, translation, $$.type, $$.details);
                        }

                        Variavel var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, $$.details == REAL_NUMBER_ID);

                        $$.translation = translation + var.getRealVarLabel() + " = " + fakeLabel + ";\n";
                    }

CONST_VARS          : CONST_VARS ',' CONST_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | CONST_VAR_DECLARTION { $$.translation = $1.translation; }

CONST_VAR_DECLARTION: ID RETURN_TYPE '=' EXPRESSION {
                        string translation = $4.translation;

                        $$.label = gentempcode(true);
                        $$.type = $2.type;
                        $$.details = $4.details;

                        string fakeLabel = $4.label;

                        if ($2.type == "void") {
                            $$.type = $4.type;
                        } else {
                            fakeLabel = translate($4, translation, $$.type, $$.details);
                        }

                        Variavel var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, $$.details == REAL_NUMBER_ID, true);

                        $$.translation = translation + var.getRealVarLabel() + " = " + fakeLabel + ";\n";
                    }
                    

ASSIGNMENT          : ID '=' EXPRESSION {
                        bool found = false;
                        Variavel* variavel = findVariableByName($1.label, found);

                        if (!found) {
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

                        translation += $$.label + " = " + $3.label + ";\n";
                        translation += realName + " = " + $3.label + ";\n";

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

                        for (int i = 1; i < originalString.length() - 1; i++) {
                            if (originalString[i] == '$' && originalString[i + 1] == '{') {
                                i += 2;

                                string varName = "";

                                while (originalString[i] != '}') {
                                    varName += originalString[i];
                                    i++;
                                }

                                bool found = false;
                                Variavel* var = findVariableByName(varName, found);

                                if (!found) {
                                    yyerror("Cannot found symbol \"" + varName + "\"");
                                    return -1;
                                }

                                const Atributo atributo = {var->getRealVarLabel(), var->getVarType(), var->getDetails(), ""};
                                string realLabel = translate(atributo, translation, STRING_ID);
                                
                                value += "\" + ";
                                value += realLabel;
                                value += " + \"";
                            } else {
                                value += originalString[i];
                            }
                        }

                        Variavel var = createVariableIfNotExists($$.label, $$.label, $$.type, value, false, true, true);
                        $$.translation = translation + $$.label + " = " + value + "\";\n";
                    }

/**
 * Explicit type casting
 */

CAST                : TK_AS EXPRESSION {
                        $1.label = $1.label.substr(1, $1.label.find(")") - 1);

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
                    | TK_ASSERT_EQUALS EXPRESSION EXPRESSION { // ADICIONRA LABEL DE GOTO AQUI!!!
                        string translation = $2.translation + $3.translation;

                        string ifTempLabel = gentempcode();

                        createVariableIfNotExists(ifTempLabel, ifTempLabel, BOOLEAN_ID, "", false, true, true);

                        translation += "\n/* Assert Line " + to_string(getCurrentLine()) + " */\n";
                        translation += ifTempLabel + " = " + $2.label + " == " + $3.label + ";\n\n";

                        string firstLabel = $2.type == STRING_ID ? $2.label : "to_string(" + $2.label + ")";
                        string secondLabel = $3.type == STRING_ID ? $3.label : "to_string(" + $3.label + ")";

                        translation += "if (!" + ifTempLabel + ") {\n";
                        translation += indent("cout << \"\\033[4;31m"
                                "The test in line " + to_string(getCurrentLine()) + " failed... "
                                "Cannot assert \" + " +
                                firstLabel +
                                " + \" is equals to \" + " +
                                secondLabel +
                                " + \""
                                "\\033[0m\" << endl;"
                                "\nexit(1);"
                                "\n");
                        translation += "}\n\n";

                        $$.translation = translation;
                    }

/**
 * String concatenation
 */

STRING_CONCAT       : EXPRESSION TK_CONCAT EXPRESSION {
                        $$.label = gentempcode();
                        $$.type = STRING_ID;

                        string translation = $1.translation + $3.translation;

                        string fLabel = translate($1, translation, STRING_ID);
                        string sLabel = translate($3, translation, STRING_ID);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        translation += $$.label + " = " + fLabel + " + " + sLabel + ";\n";

                        $$.translation = $1.translation + translation;
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
                            yyerror("The operator == must be used with the same type", "No match operator");
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
                            yyerror("The operator == must be used with the same type", "No match operator");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        string translation = $1.translation + $3.translation;

                        string sLabel = translate($3, translation, $1.type, $1.details);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        $$.translation = translation + $$.label + " = " + $1.label + " == " + sLabel + ";\n";
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

%%

#include "lexico.yy.c"

int yyparse();

int main(int argc, char* argv[])
{
	yyparse();
	return 0;
}

