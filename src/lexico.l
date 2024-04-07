%{
#include <string>
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

NUMBER ({DIGIT})+
REAL [-+]?(((({DIGIT}+)|({DIGIT}*\.{DIGIT}+))([eE][-+]?{DIGIT}+)?))
INTEGER [-+]?{NUMBER}
CHAR \'({LETTER}|{DIGIT})\'
STRING \"({LETTER}|{DIGIT})*\"
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*

TYPES "number"|"bool"|"char"|"string"
OTHER_TYPES "void"|"null"|"undefined"

RESERVED_KEYS ("int"|"t"{NUMBER})

%%

{SPACE}+          { /* ignore whitespace */                       }
"\n"              { /* ignorar break line */                      }
{RESERVED_KEYS}   { yylval.label = yytext; return TK_FORBIDDEN;   }
  
"if"              { return TK_IF;                                 }
"else"            { return TK_ELSE;                               }
"repeat"          { return TK_REPEAT;                             }
"until"           { return TK_UNTIL;                              }
"for"             { return TK_FOR;                                }
  
"fn"              { return TK_FUNCTION;                           }
"let"             { return TK_LET;                                }
"const"           { return TK_CONST;                              }
  
"true"            { yylval.label = yytext; return TK_BOOLEAN;     }
"false"           { yylval.label = yytext; return TK_BOOLEAN;     }
  
"and"             { return TK_AND;                                }
"or"              { return TK_OR;                                 }
"!"|"not"         { return TK_NOT;                                }
  
  
"=="              { return TK_EQUALS;                             }
">="              { return TK_GREATER_EQUALS;                     }
"<="              { return TK_LESS_EQUALS;                        }
"!="              { return TK_DIFFERENT;                          }
">"               { return TK_GREATER;                            }
"<"               { return TK_LESS;                               }
  
[+\-*/|]          { return *yytext;                               }
[(){}[\]]         { return *yytext;                               }
[;,~:=]           { return *yytext;                               }

("("{TYPES}")")*  { yylval.label = yytext; return TK_AS;          }
{TYPES}("[]")*    { yylval.label = yytext; return TK_TYPE;        }
{OTHER_TYPES}     { yylval.label = yytext; return TK_TYPE;        }
 
"as"              { return TK_AS;                                 }
{STRING}		  { yylval.label = yytext; return TK_STRING;      }
{CHAR}		      { yylval.label = yytext; return TK_CHAR;        }
{INTEGER}	      { yylval.label = yytext; return TK_INTEGER;     }
{REAL}	          { yylval.label = yytext; return TK_REAL;        }
{ID}		      { yylval.label = yytext; return TK_ID;          }
  
.                 { *yytext;                                      }

%%