%{
#include <string>
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

NUMBER ({DIGIT})+
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*

TYPES "number"|"boolean"|"string"
OTHER_TYPES "void"|"null"|"undefined"

%%

[ \t]           { /* ignore whitespace */                       } 
"\n"            { /* ignorar break line */                      }

"main"          { return TK_MAIN;                               }

{TYPES}("[]")*  { yylval.label = yytext; return TK_TYPE;        }
{OTHER_TYPES}   { yylval.label = yytext; return TK_TYPE;        }

[+\-*/|]        { return *yytext;                               }
[(){}[\]]       { return *yytext;                               }
[;,~:=]         { return *yytext;                               }

"if"            { return TK_IF;                                 }
"else"          { return TK_ELSE;                               }

"function"      { return TK_FUNCTION;                           }
"let"           { return TK_LET;                                }
"const"         { return TK_CONST;                              }

"and"           { return TK_AND;                                }
"or"            { return TK_OR;                                 }

"true"          { yylval.label = yytext; return TK_TRUE;        }
"false"         { yylval.label = yytext; return TK_FALSE;       }

{NUMBER}	    { yylval.label = yytext; return TK_NUMBER;      }
{ID}		    { yylval.label = yytext; return TK_ID;          }

%%