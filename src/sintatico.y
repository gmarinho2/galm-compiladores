%{
#include <iostream>
#include <string>
#include <sstream>
#include "../src/app/headers/variaveis.h"

#define YYSTYPE Atributo

using namespace variaveis;

int yylex(void);
%}

%token TK_ID TK_INTEGER TK_REAL TK_CHAR TK_STRING TK_AS

%token TK_IF TK_ELSE TK_FOR TK_REPEAT TK_UNTIL

%token TK_LET TK_CONST TK_FUNCTION TK_TYPE TK_VOID

%token TK_AND TK_OR TK_BOOLEAN TK_NOT

%token TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS

%token TK_PRINTLN TK_PRINT TK_SCAN

%token TK_FORBIDDEN

%start S

%right '='
%right TK_AS
%left TK_AND TK_OR
%left '*''/'
%left '+''-' TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS
%left TK_NOT

%%

/**
 * The grammar is defined here
 * The first rule is the start symbol
 */

S                   : COMMANDS {
                        cout << gerarCodigo($1.translation) << endl;
                    };

/**
 * Commands and blocks
 */

COMMANDS            : COMMAND COMMANDS { $$.translation = "\t" + $1.translation + $2.translation; }
                    | '{' COMMANDS '}' {  $$.translation = "\t" + $2.translation; }
                    | { $$.translation = ""; }

COMMAND             : COMMAND ';' { $$ = $1; }
                    | VARIABLE_DECLARATION { $$ = $1; }
                    | EXPRESSION { $$ = $1; }

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
                        
                        $$.translation = getType($$) + " " + $$.label + " = " + var->getRealVarLabel() + ";\n";
                    }

/**
 * Variables
 */

VARIABLE_DECLARATION: TK_LET LET_VARS { $$ = $2; }
                    | TK_CONST CONST_VARS { $$ = $2; }

LET_VARS            : LET_VARS ',' LET_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | LET_VAR_DECLARTION { $$.translation = $1.translation; }

LET_VAR_DECLARTION  : ID RETURN_TYPE {
                        string tempCode = gentempcode(true);
                        Variavel var = createVariableIfNotExists($1.label, tempCode, $2.type, "", false);

                        $$.label = tempCode;
                        $$.type = $2.type;
                        $$.translation = "";
                    }
                    |
                    ID RETURN_TYPE '=' EXPRESSION {
                        if ($2.type != "void" && $2.type != $4.type) {
                            yyerror("The type of the expression (" + $4.type + ") is not compatible with the type of the variable (" + $2.type + ")", "Type check error");
                            return -1;
                        }

                        string tempCode = gentempcode(true);
                        Variavel var = createVariableIfNotExists($1.label, tempCode, $4.type, $4.label, $4.details == REAL_NUMBER_ID ? true : false);

                        $$.label = tempCode;
                        $$.type = $4.type;
                        $$.translation = $4.translation + "\t" + var.getRealVarLabel() + " = " + $4.label + ";\n";
                    }

CONST_VARS          : CONST_VARS ',' CONST_VAR_DECLARTION { $$.translation = $1.translation + $3.translation; }
                    | CONST_VAR_DECLARTION { $$.translation = $1.translation; }

CONST_VAR_DECLARTION: ID RETURN_TYPE {
                        string tempCode = gentempcode(true);
                        Variavel var = createVariableIfNotExists($1.label, tempCode, $2.type, "", false);

                        $$.label = tempCode;
                        $$.type = $2.type;
                        $$.translation = "";
                    }
                    |
                    ID RETURN_TYPE '=' EXPRESSION {
                        if ($2.type != "void" && $2.type != $4.type) {
                            yyerror("The type of the expression (" + $4.type + ") is not compatible with the type of the variable (" + $2.type + ")", "Type check error");
                            return -1;
                        }

                        string tempCode = gentempcode(true);
                        Variavel var = createVariableIfNotExists($1.label, tempCode, $4.type, $4.label, $4.details == REAL_NUMBER_ID ? true : false, true);

                        $$.label = tempCode;
                        $$.type = $4.type;
                        $$.translation = $4.translation + "\t" + var.getRealVarLabel() + " = " + $4.label + ";\n";
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
                                yyerror("Cannot assign a value to a constant variable");
                                return -1;
                            }
                        }

                        variavel->setVarType(varType);
                        variavel->setVarValue($3.label);

                        if (variavel->isNumber()) {
                            variavel->setIsReal($3.details == REAL_NUMBER_ID);
                        }

                        $$.label = $1.label;
                        $$.type = varType;

                        $$.translation = $1.translation + $3.translation + "\t" + variavel->getRealVarLabel() + " = " + $3.label + ";\n";
                    };

/**
 * Types
 */

 TYPES              : TK_BOOLEAN { 
                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        $$.translation = getType($$) + " " + $$.label + ";\n" + "\t" + $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_REAL { 
                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.details = REAL_NUMBER_ID;
                        $$.translation = getType($$) + " " + $$.label + ";\n" + "\t" + $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_INTEGER  { 
                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.details = INTEGER_NUMBER_ID;
                        $$.translation = getType($$) + " " + $$.label + ";\n" + "\t" + $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_CHAR  { 
                        $$.label = gentempcode();
                        $$.type = CHAR_ID;
                        $$.translation = getType($$) + " " + $$.label + ";\n" + "\t" + $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_STRING  { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;
                        $$.translation = getType($$) + " " + $$.label + ";\n" + "\t" + $$.label + " = " + $1.label + ";\n";
                    }

/**
 * Explicit type casting
 */

CAST                : TK_AS EXPRESSION {
                        $1.label = $1.label.substr(1, $1.label.find(")") - 1);

                        Atributo converted = convertType($$, $2, $1.label);
                        
                        $$ = converted;
                        $$.translation = $2.translation + converted.translation;
                    }
                    | TK_PRINTLN '(' EXPRESSION ')'
                    {
                        $$.translation = $3.translation + "\tcout << " + $3.label + " << endl;\n";
                    }
			
                    | TK_PRINT '(' EXPRESSION ')'
                    {
                            $$.translation = $3.translation + "\tcout << " + $3.label + ";\n";
                        
                    }


/**
 * Arithmetic expressions
 */

 ARITMETIC          : EXPRESSION '*' EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator * must be used with a number type");
                            return -1;
                        }

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " * " + $3.label + ";\n");
                    }
                    | EXPRESSION '/' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator / must be used with a number type");
                            return -1;
                        }

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " / " + $3.label + ";\n");
                    }
                    | EXPRESSION '+' EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator + must be used with a number type");
                            return -1;
                        }

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " + " + $3.label + ";\n");
                    }
                    | EXPRESSION '-' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator - must be used with a number type");
                            return -1;
                        }

                        if ($1.details == REAL_NUMBER_ID || $3.details == REAL_NUMBER_ID) {
                            $$.details = REAL_NUMBER_ID;
                        } else {
                            $$.details = INTEGER_NUMBER_ID;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " - " + $3.label + ";\n");
                    } 
                    | '|' EXPRESSION '|' {
                        if ($2.type != NUMBER_ID) {
                            yyerror("The operador absolute must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode(); //TODO
                        $$.type = NUMBER_ID;
                        $$.translation = $2.translation + $$.label + " = abs(" + $2.label + ");\n";
                    }

/**
 * Logical expressions
 */

LOGICAL             : EXPRESSION TK_AND EXPRESSION {
                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        Atributo firstExpressionConversion = {};
                        Atributo firstExpression = convertType(firstExpressionConversion, $1, BOOLEAN_ID);

                        Atributo secondExpressionConversion = {};
                        Atributo secondExpression = convertType(secondExpressionConversion, $3, BOOLEAN_ID);

                        $$.translation = $1.translation + indent($3.translation) + firstExpression.translation + secondExpression.translation + indent(getType($$) + " " + $$.label + " = " + firstExpression.label + " && " + secondExpression.label + ";\n");
                    }
                    |
                    EXPRESSION TK_OR EXPRESSION {
                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        Atributo firstExpressionConversion = {};
                        Atributo firstExpression = convertType(firstExpressionConversion, $1, BOOLEAN_ID);

                        Atributo secondExpressionConversion = {};
                        Atributo secondExpression = convertType(secondExpressionConversion, $3, BOOLEAN_ID);

                        $$.translation = $1.translation + indent($3.translation) + firstExpression.translation + secondExpression.translation + indent(getType($$) + " " + $$.label + " = " + firstExpression.label + " || " + secondExpression.label + ";\n");
                    }
                    |
                    TK_NOT EXPRESSION {
                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();

                        Atributo expressionConversion = {};
                        Atributo expression = convertType(expressionConversion, $2, BOOLEAN_ID);

                        $$.translation = $2.translation + expression.translation + indent(getType($$) + " " + $$.label + " = " + expression.label + " != 1;\n");
                    }

/**
 * Relational expressions
 */

 RELATIONAL         : EXPRESSION TK_GREATER EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator > must be used with a number type");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " > " + $3.label + ";\n");
                    }
                    |
                    EXPRESSION TK_LESS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator < must be used with a number type");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " < " + $3.label + ";\n");
                    }
                    |
                    EXPRESSION TK_GREATER_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator >= must be used with a number type");
                            return -1;
                        }


                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " >= " + $3.label + ";\n");
                    }
                    |
                    EXPRESSION TK_LESS_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator <= must be used with a number type");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " <= " + $3.label + ";\n");
                    }
                    |
                    EXPRESSION TK_EQUALS EXPRESSION {
                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + indent($3.translation + getType($$) + " " + $$.label + " = " + $1.label + " == " + $3.label + ";\n");
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

