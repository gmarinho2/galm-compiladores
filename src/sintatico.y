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

%token TK_BREAK_LINE

%token TK_ID TK_INTEGER TK_REAL TK_CHAR TK_STRING TK_AS

%token TK_IF TK_ELSE TK_FOR TK_REPEAT TK_UNTIL

%token TK_LET TK_CONST TK_FUNCTION TK_TYPE TK_VOID

%token TK_AND TK_OR TK_BOOLEAN TK_NOT

%token TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS TK_DIV

%token TK_BITAND TK_BITOR TK_BITXOR TK_BITLEFT TK_BITRIGHT TK_BITNOT

%token TK_FORBIDDEN

%start S

%right '='
%right TK_AS

%left TK_AND TK_OR
%left '*' '/' TK_DIV '%'
%left '+' '-'
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
                    | TYPES { $$ = $1; }
                    | BITWISE {$$ = $1;}
                    | '(' EXPRESSION ')' { $$ = $2; }
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
                        
                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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

                        if ($2.type == "void") {
                            $$.type = $4.type;
                        } else {
                            translate($4, translation, $$.type, $$.details);
                        }

                        Variavel var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, $$.details == REAL_NUMBER_ID ? true : false);

                        $$.translation = translation + var.getRealVarLabel() + " = " + $4.label + ";\n";
                    }

CONST_VARS          : CONST_VARS ',' CONST_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | CONST_VAR_DECLARTION { $$.translation = $1.translation; }

CONST_VAR_DECLARTION: ID RETURN_TYPE '=' EXPRESSION {
                        string translation = $4.translation;

                        $$.label = gentempcode(true);
                        $$.type = $2.type;
                        $$.details = $4.details;

                        if ($2.type == "void") {
                            $$.type = $4.type;
                        } else {
                            translate($4, translation, $$.type, $$.details);
                        }

                        Variavel var = createVariableIfNotExists($1.label, $$.label, $$.type, $4.label, $$.details == REAL_NUMBER_ID ? true : false, true);

                        $$.translation = translation + var.getRealVarLabel() + " = " + $4.label + ";\n";
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

                        createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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
                    | TK_STRING  { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;
                        Variavel var = createVariableIfNotExists($$.label, $$.label, $$.type, $1.label, false, true, true);
                        $$.translation = $$.label + " = " + $1.label + ";\n";
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

                        translate($2, translation, $1.label, $$.details);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $2.label + ";\n";

                        $$.translation = $2.translation + translation;
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

                        if ($$.details == REAL_NUMBER_ID) {
                            translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                            translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                        }

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " * " + $3.label + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION TK_DIV EXPRESSION {
                        $$.type = NUMBER_ID;
                        $$.details = INTEGER_NUMBER_ID;

                        string translation = $3.translation;

                        translate($1, translation, NUMBER_ID, INTEGER_NUMBER_ID);
                        translate($3, translation, NUMBER_ID, INTEGER_NUMBER_ID);

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        translation += $$.label + " = " + $1.label + " / " + $3.label + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    | EXPRESSION '/' EXPRESSION { 
                        $$.type = NUMBER_ID;
                        $$.details = REAL_NUMBER_ID;

                        string translation = $3.translation;

                        translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                        translate($3, translation, NUMBER_ID, REAL_NUMBER_ID);

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, true, true, true);

                        translation += $$.label + " = " + $1.label + " / " + $3.label + ";\n";

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

                        if ($$.details == REAL_NUMBER_ID) {
                            translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                            translate($3, translation, NUMBER_ID, REAL_NUMBER_ID);
                        }

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " + " + $3.label + ";\n";

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

                        if ($$.details == REAL_NUMBER_ID) {
                            translate($1, translation, NUMBER_ID, REAL_NUMBER_ID);
                            translate($3, translation, NUMBER_ID, REAL_NUMBER_ID);
                        }

                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " - " + $3.label + ";\n";

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + absolute + ";\n";

                        $$.translation = $1.translation + translation;
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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + absolute + ";\n";
                        $$.translation = $2.translation + translation;
                    }

/**
 * Logical expressions
 */

LOGICAL             : EXPRESSION TK_AND EXPRESSION {
                        string translation = $3.translation;

                        translate($1, translation, BOOLEAN_ID);
                        translate($3, translation, BOOLEAN_ID);

                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " && " + $3.label + ";\n";
                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_OR EXPRESSION {
                        string translation = $3.translation;

                        translate($1, translation, BOOLEAN_ID);
                        translate($3, translation, BOOLEAN_ID);

                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " || " + $3.label + ";\n";
                        $$.translation = $1.translation + translation;
                    }
                    |
                    TK_NOT EXPRESSION {
                        string translation = "";

                        translate($2, translation, BOOLEAN_ID);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        $$.translation = $2.translation + translation;
                    }

/**
 * Relational expressions
 */

 RELATIONAL         : EXPRESSION TK_GREATER EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator > must be used with a number type");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        translate($1, translation, NUMBER_ID, details);
                        translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " > " + $3.label + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_LESS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator < must be used with a number type");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        translate($1, translation, NUMBER_ID, details);
                        translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " < " + $3.label + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_GREATER_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator >= must be used with a number type");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        translate($1, translation, NUMBER_ID, details);
                        translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " >= " + $3.label + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_LESS_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator <= must be used with a number type");
                            return -1;
                        }

                        string translation = $3.translation;
                        string details = $1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID ? REAL_NUMBER_ID : INTEGER_NUMBER_ID;

                        translate($1, translation, NUMBER_ID, details);
                        translate($3, translation, NUMBER_ID, details);

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

                        translation += $$.label + " = " + $1.label + " <= " + $3.label + ";\n";

                        $$.translation = $1.translation + translation;
                    }
                    |
                    EXPRESSION TK_DIFFERENT EXPRESSION {
                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        string translation = $1.translation + $3.translation;

                        translate($3, translation, $1.type, $1.details);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        $$.translation = translation + $$.label + " = " + $1.label + " != " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_EQUALS EXPRESSION {
                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        string translation = $1.translation + $3.translation;

                        translate($3, translation, $1.type, $1.details);

                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, false, true, true);

                        $$.translation = translation + $$.label + " = " + $1.label + " == " + $3.label + ";\n";
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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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
                        createVariableIfNotExists($$.label, $$.label, $$.type, $$.label, $$.details == REAL_NUMBER_ID ? true : false, true, true);

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

