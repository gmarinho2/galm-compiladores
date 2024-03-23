%{
#include <string>
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

INT ({DIGIT})+
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*

%%

[ \t]       { /* ignore whitespace */                       } 
"\n"        { /* ignorar break line */                      }

"main"      { return TK_MAIN;                               }

"number"    { yylval.label = *yytext; return TK_TYPE;       }
"boolean"   { yylval.label = *yytext; return TK_TYPE;       }
"void"      { yylval.label = *yytext; return TK_TYPE;       }
"null"      { yylval.label = *yytext; return TK_TYPE;       }
"undefined" { yylval.label = *yytext; return TK_TYPE;       }

[+\-*/|]    { return *yytext;                               }
[(){}[\]]   { return *yytext;                               }
[;,~:=]     { return *yytext;                              }

"if"        { return TK_IF;                                 }

"let"       { return TK_LET;                                }
"const"     { return TK_CONST;                              }

"true"      { return TK_TRUE;                               }
"false"     { return TK_FALSE;                              }

{INT}		{ yylval.label = atoi(yytext); return TK_NUM;   }
{ID}		{ yylval.label = yytext; return TK_ID;          }

%%