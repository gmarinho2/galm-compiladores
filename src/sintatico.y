%{
#include <iostream>
#include <string>
#include <sstream>
#include "../src/app/headers/variaveis.h"

#define YYSTYPE Atributo

using namespace variaveis;

int yylex(void);
%}

%token TK_ID TK_NUMBER TK_CHAR TK_STRING

%token TK_IF TK_ELSE TK_FOR TK_REPEAT TK_UNTIL

%token TK_MAIN

%token TK_LET TK_CONST TK_FUNCTION

%token TK_TYPE TK_VOID

%token TK_AND TK_OR TK_TRUE TK_FALSE TK_NOT

%token TK_SIMILAR TK_EQUALS TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS

%token TK_FORBIDDEN

%start S

%right '='
%left TK_AND TK_OR
%left '*''/'
%left '+''-' TK_EQUALS TK_SIMILAR TK_DIFFERENT TK_GREATER TK_LESS TK_GREATER_EQUALS TK_LESS_EQUALS
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

COMMANDS            : COMMAND COMMANDS {
                        $$.translation = "\t" + $1.translation + $2.translation;
                    }
                    | '{' COMMANDS '}' { 
                        $$.translation = "\t" + $2.translation;
                    }
                    | { $$.translation = ""; }

COMMAND             : COMMAND ';' {
                        $$ = $1;
                    }
                    | FUNCTION {
                        $$ = $1;
                    }
                    | EXPRESSION {
                        $$ = $1;
                    }
                    | VARIABLE_DECLARATION {
                        $$ = $1;
                    }

ID                  : TK_FORBIDDEN {
                        yyerror("You are trying to use a reserved key \"" + $1.label + "\".");
                    }
                    | TK_ID {
                        $$ = $1;
                    }

/**
 * Functions
 */

 FUNCTION           : TK_FUNCTION ID '(' PARAMETERS ')' RETURN_TYPE '{' COMMANDS '}' { // Declaração da função
                        $$.translation = $6.label + " " + $2.label + "(" + $4.translation + ") {\n" + indent($8.translation) + "\t}\n";
                    }
                    | ID '(' ARGUMENTS ')' { // Chamada da função
                        $$.translation = $1.label + "(" + $3.translation + ");\n";
                    }

ARGUMENTS           : ID { // (arg1)
                        cout << "Argumento" << endl;
                    }
                    | ID ',' ARGUMENTS { // (arg1, arg2)
                        cout << "Argumento" << endl;
                    }
                    | { $$.translation = ""; }

PARAMETERS          : ID RETURN_TYPE {
                        $$.translation = $2.type + " " + $1.label ;
                    }
                    | ID RETURN_TYPE ',' PARAMETERS {
                        $$.translation =  $2.type + " " + $1.label + ", " + $4.translation;
                    }
                    | { $$.translation = ""; }

RETURN_TYPE         : ':' TK_TYPE { $$.type = $2.label; }
                    | ':' TK_VOID { $$.type = "void"; }
                    | { $$.type = "void"; }

 /**
 * Expressions
 */

EXPRESSION          : ARITMETIC { $$ = $1; }
                    | LOGICAL { $$ = $1; }
                    | RELATIONAL { $$ = $1; }
                    | ASSIGNMENT { $$ = $1; }
                    | TYPES { $$ = $1; }
                    | ID {
                        bool found = false;
                        Variavel variavel = findVariableByName($1.label, found);

                        if (!found) {
                            yyerror("Cannot found symbol \"" + $1.label + "\"");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = variavel.getVarType();
                        $$.translation = $$.label + " = " + $1.label + ";\n";
                    }

/**
 * Variables
 */

VARIABLE_DECLARATION: TK_LET ID RETURN_TYPE '=' EXPRESSION {
                        if ($3.type != "void" && $3.type != $5.type) {
                            yyerror("The type of the expression (" + $5.type + ") is not compatible with the type of the variable (" + $3.type + ")", "Type check error");
                            return -1;
                        }

                        createVariableIfNotExists($2.label, $5.type, $5.label);
                        
                        $$.label = $2.label;
                        $$.type = $4.label;
                        $$.translation = $5.translation + "\t" + $2.label + " = " + $5.label + ";\n";
                    }
                    | TK_CONST ID RETURN_TYPE '=' EXPRESSION {
                        if ($3.type != "void" && $3.type != $5.type) {
                            yyerror("The type of the expression (" + $5.type + ") is not compatible with the type of the variable (" + $3.type + ")", "Type check error");
                            return -1;
                        }

                        createVariableIfNotExists($2.label, $5.type, $5.label, true);

                        $$.label = $2.label;
                        $$.type = $4.type;
                        $$.translation = $5.translation + "\t" + $2.label + " = " + $5.label + ";\n";
                    };

ASSIGNMENT          : ID '=' EXPRESSION { 
                        bool found = false;
                        Variavel variavel = findVariableByName($1.label, found);

                        if (!found) {
                            yyerror("Cannot found symbol \"" + $1.label + "\"");
                            return -1;
                        }

                        if (variavel.getVarType() != $3.type) {
                            yyerror("The type of the expression (" + $3.type + ") is not compatible with the type of the variable (" + variavel.getVarType() + ")");
                            return -1;
                        }

                        if (variavel.isConstant()) {
                            yyerror("Cannot assign a value to a constant variable");
                            return -1;
                        }

                        cout << $1.label << " " << $3.label << " " << $3.type << endl;

                        variavel.setVarValue($3.label);

                        $$.label = $1.label;
                        $$.type = $1.type;
                        $$.translation = $1.translation + "\t" + $3.translation + $1.label + " = " + $3.label + ";\n";
                    };

/**
 * Types
 */

 TYPES              : TK_TRUE { 
                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        $$.translation = $$.label + " = true;\n";
                    }
                    | TK_FALSE { 
                        $$.label = gentempcode();
                        $$.type = BOOLEAN_ID;
                        $$.translation = $$.label + " = false;\n";
                    }
                    | TK_NUMBER  { 
                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_CHAR  { 
                        $$.label = gentempcode();
                        $$.type = CHAR_ID;
                        $$.translation = $$.label + " = " + $1.label + ";\n";
                    }
                    | TK_STRING  { 
                        $$.label = gentempcode();
                        $$.type = STRING_ID;
                        $$.translation = $$.label + " = " + $1.label + ";\n";
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
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
                    }
                    | EXPRESSION '/' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator / must be used with a number type");
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
                    }
                    | EXPRESSION '+' EXPRESSION {
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator + must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
                    }
                    | EXPRESSION '-' EXPRESSION { 
                        if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator - must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
                    } 
                    | '|' EXPRESSION '|' {
                        if ($2.type != NUMBER_ID) {
                            yyerror("The operador absolute must be used with a number type");
                            return -1;
                        }

                        $$.label = gentempcode();
                        $$.type = NUMBER_ID;
                        $$.translation = $2.translation + $$.label + " = " + $2.label + ";\n";
                    }

/**
 * Logical expressions
 */

LOGICAL             : EXPRESSION TK_SIMILAR EXPRESSION {
                        $$.type = BOOLEAN_ID;

                        bool sameType = $1.type == $3.type;

                        $$.label = gentempcode();
                        $$.translation = $1.translation + $3.translation + $$.label + " = true;\n";
                    }
                    |
                    EXPRESSION TK_EQUALS EXPRESSION {
                        $$.type = BOOLEAN_ID;

                        bool sameType = $1.type == $3.type;

                        $$.label = gentempcode();
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + (sameType == 0 ? "false" : "true") + ";\n";
                    }
                    | TK_NOT EXPRESSION {
                        if ($2.type != BOOLEAN_ID) {
                            yyerror("The operator ! must be used with a boolean type");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $2.translation + $$.label + " = !" + $2.label + ";\n";
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
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " > " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_LESS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator < must be used with a number type");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " < " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_GREATER_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator >= must be used with a number type");
                            return -1;
                        }


                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " >= " + $3.label + ";\n";
                    }
                    |
                    EXPRESSION TK_LESS_EQUALS EXPRESSION {
                        if($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                            yyerror("The operator <= must be used with a number type");
                            return -1;
                        }

                        $$.type = BOOLEAN_ID;
                        $$.label = gentempcode();
                        $$.translation = $1.translation + $3.translation + $$.label + " = " + $1.label + " <= " + $3.label + ";\n";
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

