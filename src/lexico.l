%{
#include <string>

string toDecimal(string str, int base) {
    bool negative = str.rfind("-", 0) == 0;
    bool startsWith = str.rfind("+", 0) == 0 || negative;
    int firstCharacter = 2 + startsWith;

    int decimal = stoi(str.substr(firstCharacter, str.length() - 2), nullptr, base);

    if (negative) {
        decimal = -decimal;
    }

    return to_string(decimal);
}
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

NUMBER ({DIGIT})+
REAL [-+]?(((({DIGIT}+)|({DIGIT}*\.{DIGIT}+))([eE][-+]?{DIGIT}+)?))

BINARY_INTEGER [-+]?0[bB][01]+
OCTAL_INTEGER [-+]?0[oO][0-7]+
HEXA_INTEGER [-+]?0[xX][0-9a-fA-F]+
DECIMAL_INTEGER [-+]?{NUMBER}

CHAR \'({LETTER}|{DIGIT})\'
STRING \"({LETTER}|{DIGIT})*\"
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*

TYPES "number"|"bool"|"char"|"string"
OTHER_TYPES "void"|"null"

RESERVED_KEYS "int"

%%

{SPACE}+            { /* ignore whitespace */                       }
"\n"                { return TK_BREAK_LINE;                         }
{RESERVED_KEYS}     { yylval.label = yytext; return TK_FORBIDDEN;   }

"if"                { return TK_IF;                                 }
"else"              { return TK_ELSE;                               }
"repeat"            { return TK_REPEAT;                             }
"until"             { return TK_UNTIL;                              }
"for"               { return TK_FOR;                                }

"fn"                { return TK_FUNCTION;                           }
"let"               { return TK_LET;                                }
"const"             { return TK_CONST;                              }
      
"true"              { yylval.label = "true"; return TK_BOOLEAN;     }
"false"             { yylval.label = "false"; return TK_BOOLEAN;    }

"and"               { return TK_AND;                                }
"or"                { return TK_OR;                                 }
"!"|"not"           { return TK_NOT;                                }

"&"                 { return TK_BITAND;                             }
"|"                 { return TK_BITOR;                              }
"~"                 { return TK_BITNOT;                             }
"^"                 { return TK_BITXOR;                             }
"<<"                { return TK_BITLEFT;                            }
">>"                { return TK_BITRIGHT;                           }

"=="                { return TK_EQUALS;                             }
"!="                { return TK_DIFFERENT;                          }
">="                { return TK_GREATER_EQUALS;                     }
"<="                { return TK_LESS_EQUALS;                        }
"!="                { return TK_DIFFERENT;                          }
">"                 { return TK_GREATER;                            }
"<"                 { return TK_LESS;                               }

"//"                { return TK_DIV;                                }
[+\-*/|]            { return *yytext;                               }
[(){}[\]]           { return *yytext;                               }
[;,~:=%]            { return *yytext;                               }

("("{TYPES}")")*    { yylval.label = yytext; return TK_AS;          }
{TYPES}("[]")*      { yylval.label = yytext; return TK_TYPE;        }
{OTHER_TYPES}       { yylval.label = yytext; return TK_TYPE;        }
 
"as"                { return TK_AS;                                 }
{STRING}		        { yylval.label = yytext; return TK_STRING;      }
{CHAR}		          { yylval.label = yytext; return TK_CHAR;        }

{BINARY_INTEGER}    { yylval.label = toDecimal(yytext, 2); 
                      return TK_INTEGER;     
                    }
{OCTAL_INTEGER}     { yylval.label = toDecimal(yytext, 8); 
                      return TK_INTEGER;     
                    }
{HEXA_INTEGER}      { yylval.label = toDecimal(yytext, 16); 
                      return TK_INTEGER;     
                    }
{DECIMAL_INTEGER}   { yylval.label = yytext; return TK_INTEGER;     }

{REAL}	            { yylval.label = yytext; return TK_REAL;        }
{ID}		            { yylval.label = yytext; return TK_ID;          }   

.                   { *yytext;                                      }

%%