%{
#include <iostream>
#include <string>
#include <sstream>
#include "../src/app/headers/variaveis.h"

#define YYSTYPE Atributo

using namespace variaveis;

int yylex(void);
%}

%token TK_ID TK_NUMBER
%token TK_IF TK_ELSE

%token TK_MAIN

%token TK_LET TK_CONST TK_FUNCTION

%token TK_TYPE TK_VOID

%token TK_AND TK_OR TK_TRUE TK_FALSE

%start S

%right '='
%left TK_AND TK_OR
%left '*''/'
%left '+''-'
%left '!'

%%

/**
 * The grammar is defined here
 * The first rule is the start symbol
 */

S   : TK_FUNCTION TK_MAIN FUNCTION_STRUCTURE COMMANDS { 
        cout << gerarCodigo($4.translation) << endl;
    }
    | COMMANDS {
        cout << gerarCodigo($1.translation) << endl;
    }

/**
 * Parameters
 */

 FUNCTION_STRUCTURE: FUNCTION_PARAMS ':' TK_TYPE {
                        cout << "função com parametros e tipo" << endl;
                    }
                    | FUNCTION_PARAMS {
                        cout << "função com parametros sem tipo" << endl;
                    }

FUNCTION_PARAMS: '(' PARAMS ')' { cout << "parametros de função" << endl; }

PARAMS : TK_ID { cout << "parametro sem tipo" << endl; }
       | TK_ID ':' TK_TYPE { cout << "parametro com tipo" << endl; }
       | PARAMS ',' TK_ID ':' TK_TYPE { cout << "parametros" << endl; }
       | { cout << "parametros vazio" << endl; }

/**
 * Commands and blocks
 */

COMMANDS    : COMMAND COMMANDS {
                $$.translation = $1.translation + $2.translation;
            }
            | '{' COMMANDS '}' { 
                $$.translation = $2.translation;
            }
            | { $$.translation = ""; }

COMMAND : COMMAND ';' {
            $$ = $1;
        }
        | EXPRESSION {
            $$ = $1;
        }
        | TK_CONST TK_ID ':' TK_TYPE '=' EXPRESSION {
            if ($4.label != $6.type) {
                yyerror("The type of the expression (" + $6.type + ") is not compatible with the type of the variable (" + $4.label + ")");
                return -1;
            }

            string currentType = getTypeCodeById($4.label);

            if (empty(currentType)) {
                yyerror("The type " + $4.label + " is not defined");
                return -1;
            }

            createVariableIfNotExists($2.label, $4.label, $6.label, true);

            $$.label = $2.label;
            $$.type = $4.label;
            $$.translation = $4.translation + "\t" + $2.label + " = " + $6.label + ";\n";
        }
        | TK_LET TK_ID ':' TK_TYPE '=' EXPRESSION {
            if (false) {
                yyerror("Cannot found symbol \"" + $2.label + "\"");
                return -1;
            }

            if ($4.label != $6.type) {
                yyerror("The type of the expression (" + $6.type + ") is not compatible with the type of the variable (" + $4.label + ")");
                return -1;
            }

            createVariableIfNotExists($2.label, $4.label, $6.label);
            
            $$.label = $2.label;
            $$.type = $4.label;
            $$.translation = $6.translation + "\t" + $2.label + " = " + $6.label + ";\n";
        }
        | TK_CONST TK_ID '=' EXPRESSION {
            createVariableIfNotExists($2.label, $4.type, $4.label, true);

            $$.label = $2.label;
            $$.type = $4.type;
            $$.translation = $4.translation + "\t" + $2.label + " = " + $4.label + ";\n";
        }
        | TK_LET TK_ID '=' EXPRESSION {
            createVariableIfNotExists($2.label, $4.type, $4.label);

            $$.label = $2.label;
            $$.type = $4.type;
            $$.translation = $4.translation + "\t" + $2.label + " = " + $4.label + ";\n";
        }

/**
 * Expressions
 */

EXPRESSION  : EXPRESSION '*' EXPRESSION {
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("The operator * must be used with a number type");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
            }
            | EXPRESSION '/' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("The operator / must be used with a number type");
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
            }
            | EXPRESSION '+' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("The operator + must be used with a number type");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
            }
            | EXPRESSION '-' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("The operator - must be used with a number type");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
            }
            | '!' EXPRESSION { 
                if ($2.type != BOOLEAN_ID) {
                    yyerror("The operator ! must be used with a boolean type");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = BOOLEAN_ID;
                $$.translation = $2.translation + "\t" + $$.label + " = !" + $2.label + ";\n";
                cout << $$.translation << endl;
            }
            | EXPRESSION TK_AND EXPRESSION {
                if ($1.type != BOOLEAN_ID || $3.type != BOOLEAN_ID) { // TEM QUE VERIFICAR COMPATIBILIDADE
                    yyerror("Boolean and type mismatch");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = BOOLEAN_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " && " + $3.label + ";\n";
                cout << $$.translation << endl;
            }
            | '|' EXPRESSION '|' {
                if ($2.type != NUMBER_ID) {
                    yyerror("The operador absolute must be used with a number type");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $2.translation + "\t" + $$.label + " = " + $2.label + ";\n";
                cout << $$.translation << endl;
            }
            | TK_ID '=' EXPRESSION { 
                // verificar se TK_ID está na tabela de simbolos
                // se estiver, pegar o tipo e verificar se é compatível
                // se não estiver, mandar erro

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
                $$.translation = $1.translation + $3.translation + "\t" + $1.label + " = " + $3.label + ";\n";
            }
            | TK_TRUE { 
                $$.label = gentempcode();
                $$.type = BOOLEAN_ID;
                $$.translation = "\t" + $$.label + " = true;\n";
                cout<< "booleano true " << $$.translation << endl;
            }
            | TK_FALSE { 
                $$.label = gentempcode();
                $$.type = BOOLEAN_ID;
                $$.translation = "\t" + $$.label + " = false;\n";
                cout << "booleano false " << $$.translation << endl;
            }
            | TK_NUMBER  { 
                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = "\t" + $$.label + " = " + $1.label + ";\n";
            }
            | TK_ID { 
                bool found = false;
                Variavel variavel = findVariableByName($1.label, found);

                if (!found) {
                    yyerror("Cannot found symbol \"" + $1.label + "\"");
                    return -1;
                }

                $$.label = variavel.getVarValue();
                $$.type = variavel.getVarType();
                $$.translation = "\t" + $$.label + " = " + $1.label + ";\n";
             };

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

