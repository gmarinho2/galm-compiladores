%{
#include <stdio.h>
#include <stdlib.h>

#define TK_ID 1
#define TK_IF 2

#define TK_LET 10
#define TK_CONST 11

#define TK_NUM 30

#define TK_TRUE 31
#define TK_FALSE 32
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

INT ({DIGIT})+
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT})*

%%

"if"        { return TK_IF;                              }

"let"       { return TK_LET;                              }
"const"     { return TK_CONST;                            }

"true"      { return TK_TRUE;                             }
"false"     { return TK_FALSE;                            }

{INT}		{ return TK_NUM;                              }
{ID}		{ return TK_ID;                               }

%%

void main() {
    int tokenType = 0;

    while ((tokenType = yylex()) != 0) {
        printf("Token: %d", tokenType);
    }
}