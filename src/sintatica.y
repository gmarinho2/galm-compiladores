%{
#include <iostream>
#include <string>
#include <sstream>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string label;
	string traducao;
};

int yylex(void);
void yyerror(string); 
%}

%token TK_ID TK_NUM
%token TK_IF

%token TK_MAIN

%token TK_LET TK_CONST

%token TK_TYPE TK_VOID

%token TK_TRUE TK_FALSE

%start S

%right '='
%left '*''/'
%left '+''-'
%right UMINUS
%left '!'

%%

S : BLOCO

BLOCO : '{' COMMANDS '}' { cout << "bloco" << endl; }

COMMANDS : COMMAND COMMANDS { cout << "comandos" << endl; }
         | { cout << "vazio" << endl; }

COMMAND : COMMAND ';' { cout << "comando ponto virgula" << endl; }
        | E { cout << "comando sem ponto virgula" << endl; }
        | TK_CONST TK_ID ':' TK_TYPE '=' E { cout << "declaracao const com tipo" << endl; }
        | TK_LET TK_ID ':' TK_TYPE '=' E { cout << "declaracao let com tipo" << endl; }
        | TK_CONST TK_ID ':' TK_TYPE '[' ']' '=' E { cout << "declaracao const com tipo array" << endl; }
        | TK_LET TK_ID ':' TK_TYPE '[' ']' '=' E { cout << "declaracao let com tipo array" << endl; }
        | TK_CONST TK_ID '=' E { cout << "declaracao const sem tipo" << endl; }
        | TK_LET TK_ID '=' E { cout << "declaracao let sem tipo" << endl; }

E   : E '*' E { cout << "multiplicação" << endl; }
    | E '/' E { cout << "divisão" << endl; }
    | E '+' E { cout << "soma" << endl; } 
    | E '-' E { cout << "subtração" << endl; }
    | TK_ID '=' E { cout << "atribuicao" << endl; }
    | TK_ID ':' TK_TYPE '=' E { cout << "atribuicao com tipo" << endl; }
    | TK_ID { cout << "identificador" << endl; } 
    | TK_NUM  { cout << "numero" << endl; };

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

