%{
#include <string>
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

NUMBER ({DIGIT})+
CHAR \'({LETTER}|{DIGIT})\'
STRING \"({LETTER}|{DIGIT})*\"
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*

TYPES "number"|"boolean"|"char"|"string"
OTHER_TYPES "void"|"null"|"undefined"

%%

{SPACE}+        { /* ignore whitespace */                       }
"\n"            { /* ignorar break line */                      }
"int"           { /* ignorar break line */                      }

"main"          { return TK_MAIN;                               }

"if"            { return TK_IF;                                 }
"else"          { return TK_ELSE;                               }
"repeat"        { return TK_REPEAT;                             }
"until"         { return TK_UNTIL;                              }
"for"           { return TK_FOR;                                }

"fn"            { return TK_FUNCTION;                           }
"let"           { return TK_LET;                                }
"const"         { return TK_CONST;                              }

"true"          { yylval.label = yytext; return TK_TRUE;        }
"false"         { yylval.label = yytext; return TK_FALSE;       }

"and"           { return TK_AND;                                }
"or"            { return TK_OR;                                 }
"!"|"not"       { return TK_NOT;                                }


"=="            { return TK_SIMILAR;                            }
"==="           { return TK_EQUALS;                             }
">="            { return TK_GREATER_EQUALS;                     }
"<="            { return TK_LESS_EQUALS;                        }
"!="            { return TK_DIFFERENT;                          }
">"             { return TK_GREATER;                            }
"<"             { return TK_LESS;                               }

[+\-*/|]        { return *yytext;                               }
[(){}[\]]       { return *yytext;                               }
[;,~:=]         { return *yytext;                               }

{TYPES}("[]")*  { yylval.label = yytext; return TK_TYPE;        }
{OTHER_TYPES}   { yylval.label = yytext; return TK_TYPE;        }

{STRING}		{ yylval.label = yytext; return TK_STRING;      }
{CHAR}		    { yylval.label = yytext; return TK_CHAR;        }
{NUMBER}	    { yylval.label = yytext; return TK_NUMBER;      }
{ID}		    { yylval.label = yytext; return TK_ID;          }

.               { *yytext;                                      }

%%