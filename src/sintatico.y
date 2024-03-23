%{
#include <iostream>
#include <string>
#include <sstream>
#include "../src/app/headers/variaveis.h"

#define YYSTYPE Atributo

using namespace variaveis;

int yylex(void);
void yyerror(string); 
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

S   : TK_FUNCTION TK_MAIN FUNCTION_PARAMS ':' TK_TYPE COMMANDS { 
        cout << gerarCodigo($6.translation) << endl;
    }
    | COMMANDS {
        cout << gerarCodigo($1.translation) << endl;
    }

/**
 * Parameters
 */

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
            cout << "expressao" << $1.label << " " << $1.type << endl;
        }
        | TK_CONST TK_ID ':' TK_TYPE '=' EXPRESSION {
            if (false) {
                yyerror("Cannot found symbol \"" + $2.label + "\"");
                return -1;
            }

            if ($4.label != $6.type) {
                yyerror("Type mismatch");
                return -1;
            }

            string currentType = getTypeCodeById($4.label);

            if (empty(currentType)) {
                yyerror("The type " + $4.label + " is not defined");
                return -1;
            }

            $$.label = $2.label;
            $$.type = $4.label;
            $$.translation = $6.translation + "\t" + currentType + " " + $2.label + " = " + $6.label + ";\n";
        }
        | TK_LET TK_ID ':' TK_TYPE '=' EXPRESSION { cout << "declaracao let com tipo" << endl; }
        | TK_CONST TK_ID ':' TK_TYPE '[' ']' '=' EXPRESSION { cout << "declaracao const com tipo array" << endl; }
        | TK_LET TK_ID ':' TK_TYPE '[' ']' '=' EXPRESSION { cout << "declaracao let com tipo array" << endl; }
        | TK_CONST TK_ID '=' EXPRESSION { cout << "declaracao const sem tipo" << endl; }
        | TK_LET TK_ID '=' EXPRESSION { cout << "declaracao let sem tipo" << endl; }

/**
 * Expressions
 */

EXPRESSION  : EXPRESSION '*' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("Type mismatch");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
                cout << $$.translation << endl;
            }
            | EXPRESSION '/' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("Type mismatch");
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
                cout << $$.translation << endl;
            }
            | EXPRESSION '+' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("Type mismatch");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
                cout << "soma" << $1.label << " " << $1.type << endl;
            }
            | EXPRESSION '-' EXPRESSION { 
                if ($1.type != NUMBER_ID || $3.type != NUMBER_ID) {
                    yyerror("Type mismatch");
                    return -1;
                }

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $1.translation + $3.translation + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
                cout << $$.translation << endl;
            }
            | '!' EXPRESSION { 
                if ($2.type != BOOLEAN_ID) {
                    yyerror("Type mismatch");
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

                //TODO: implementar absolute operator

                $$.label = gentempcode();
                $$.type = NUMBER_ID;
                $$.translation = $2.translation + "\t" + $$.label + " = " + $2.label + ";\n";
                cout << $$.translation << endl;
            }
            | TK_ID '=' EXPRESSION { 
                // verificar se TK_ID está na tabela de simbolos
                // se estiver, pegar o tipo e verificar se é compatível
                // se não estiver, mandar erro

                if (false) {
                    yyerror("Cannot found symbol \"" + $1.label + "\"");
                    return -1;
                }
                
                $$.label = $1.label;
                $$.type = $1.type;
                $$.translation = $1.translation + $3.translation + "\t" + $1.label + " = " + $3.label + ";\n";
                cout << $$.translation << endl;
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
                cout << $1.label << " " << $1.type << endl;
            }
            | TK_ID { 
                $$ = $1;
             } ;

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

void yyerror(string message)
{
    cout << message << endl;
	exit (0);
}

