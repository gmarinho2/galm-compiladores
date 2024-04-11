#include <iostream>
#include <string>
#include <vector>
#include "str.h"

using namespace std;
using namespace str;

#pragma once
namespace variaveis {
    unsigned long long int tempCodeCounter = 0;
    unsigned long long int varCodeCounter = 0;

    void yyerror(string message, string error = "Syntax error") {
        cout << "\033[1;31m" << error << ": " << message << endl << "\033[0m";
        exit(1);
    }

    const string NUMBER_ID = "number";
    const string BOOLEAN_ID = "bool";
    const string STRING_ID = "string";
    const string CHAR_ID = "char";
    const string VOID_ID = "void";

    bool isVoid(string voidString) {
        return voidString == VOID_ID || voidString == "void*";
    }

    const string REAL_NUMBER_ID = "real";
    const string INTEGER_NUMBER_ID = "integer";

    const string REAL_NUMBER_DEFINITION = "double";
    const string INTEGER_NUMBER_DEFINITION = "int";

    typedef struct {
        string label;
        string type;
        string details;
        string translation;
    } Atributo;
    
    class Variavel {
        private:
            string varName;
            string varLabel;
            string varType;
            string varValue;
            bool constant;
            bool real;
        public:
            Variavel(string varName, string varLabel, string varType, string varValue, bool constant, bool real = false) {
                this->varName = varName;
                this->varLabel = varLabel;
                this->varType = varType;
                this->varValue = varValue;
                this->constant = constant;
                this->real = real;
            }

            string getVarName() {
                return varName;
            }

            string getVarValue() {
                return varValue;
            }

            bool alreadyInitialized() {
                return !isVoid(this->varType) && !this->varValue.empty();
            }

            void setVarValue(string value) {
                this->varValue = value;
            }

            void setVarType(string type) {
                if (alreadyInitialized())
                    yyerror("The symbol \"" + varName + "\" is already declared");

                this->varType = type;
            }

            void setIsReal(bool real) {
                this->real = real;
            }

            bool isReal() {
                return real;
            }

            string getVarType() {
                if (this->varType == VOID_ID) {
                    return "void*";
                }

                return this->varType;
            }

            string getRealVarLabel() {
                if (this->varType == NUMBER_ID) 
                    return varLabel + "." +  (real ? REAL_NUMBER_ID : INTEGER_NUMBER_ID);
                return varLabel;
            }

            string getDetails() {
                return varType == NUMBER_ID ? (real ? REAL_NUMBER_ID : INTEGER_NUMBER_ID) : "";
            }

            bool isConstant() {
                return constant;
            }

            string getTranslation() {
                return getVarType() + " " + varLabel;
            }

            bool isNumber() {
                return varType == NUMBER_ID;
            }

    };

    string getType(Atributo atributo) {
        if (atributo.type == NUMBER_ID) {
            return atributo.details == REAL_NUMBER_ID ? REAL_NUMBER_DEFINITION : INTEGER_NUMBER_DEFINITION;
        }

        return atributo.type;
    }

    Variavel NULL_VAR = Variavel("", "", "", "", false);

    vector<Variavel> variaveis;

    string gentempcode(bool isVar = false) {
        if(isVar) {
            varCodeCounter++;
            return "var" + to_string(varCodeCounter);
        }
        else {
            tempCodeCounter++;
            return "t" + to_string(tempCodeCounter);
        }
    }

    string gerarCodigo(string codigo) {
        string compilador = "/* Compilador GALM */\n\n#include <iostream>\n\n";

        compilador += "#define bool int\n";
        compilador += "#define true 1\n";
        compilador += "#define false 0\n";

        compilador += "using namespace std;\n\n";

        compilador += "typedef union {\n\t" + REAL_NUMBER_DEFINITION + " real;\n\t" + INTEGER_NUMBER_DEFINITION + " integer;\n} number;\n\n";

        compilador += "\nint main(void) {\n";

        for (int i = 0; i < variaveis.size(); i++) {
            compilador += "\t" + variaveis[i].getTranslation() + ";\n";
        }

        compilador += "\n" + codigo + "\treturn 0;\n}";

        return compilador;
    }

    /**
     * Função que retorna uma variável a partir do nome
     * Ela busca na tabela de simbolos e retorna a variável
     * Caso não encontre, retorna uma instância sem nada e com o atributo found como false
     */

    Variavel* findVariableByName(string varName, bool &found) {
        for (int i = 0; i < variaveis.size(); i++)
            if (variaveis[i].getVarName() == varName) {
                found = true;
                return &variaveis[i];
            }

        return &NULL_VAR;
    }

    Variavel createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isReal = false, bool isConst = false,  bool isGlobal = false) {
        bool found = false;
        findVariableByName(varName, found);
        
        if (!found) {
            Variavel var = Variavel(varName, varLabel, varType, varValue, isConst, isReal);
            variaveis.push_back(var);
            return var;
        }

        yyerror("The symbol \"" + varName + "\" is already declared");
        return NULL_VAR;
    }

    /**
     * Função que converte um tipo de dado para outro
     * 
     * Retorna uma instância de Atributo, onde o label é como realmente será feito a conversão
     * e o type é o tipo de dado que será convertido
    */

    Atributo convertType(Atributo cast, Atributo &expression, string toType) {
        if (expression.type == toType)
            return {expression.label, expression.type, expression.details};

        if (expression.type == CHAR_ID) {
            if (toType == NUMBER_ID) {
                cast.label = gentempcode(true);
                cast.type = NUMBER_ID;
                cast.details = INTEGER_NUMBER_ID;
                cast.translation = indent(getType(cast) + " " + cast.label + " = (" + getType(cast) + ") " + expression.label + ";\n");
                return cast;
            } else if (toType == BOOLEAN_ID) {
                Atributo newCast = {};
                Atributo intConversion = convertType(newCast, expression, NUMBER_ID);

                cast.label = gentempcode(true);
                cast.type = BOOLEAN_ID;
                cast.translation = intConversion.translation + indent(getType(cast) + " " + cast.label + " = " + intConversion.label + " != 0;\n");
                return cast;
            }
        }

        if (expression.type == BOOLEAN_ID) {
            if (toType == NUMBER_ID) {
                cast.label = gentempcode(true);
                cast.type = NUMBER_ID;
                cast.details = INTEGER_NUMBER_ID;
                cast.translation = indent(getType(cast) + " " + cast.label + " = " + expression.label + ";\n");
                return cast;
            }
        }

        if (expression.type == NUMBER_ID) {
            if (toType == BOOLEAN_ID) {
                cast.label = gentempcode(true);
                cast.type = BOOLEAN_ID;
                cast.translation = indent(getType(cast) + " " + cast.label + " = " + expression.label + " != 0;\n");
                return cast;
            } else if (toType == CHAR_ID) {
                if (expression.details == INTEGER_NUMBER_ID) {
                    cast.label = gentempcode(true);
                    cast.type = CHAR_ID;
                    cast.translation = indent(getType(cast) + " " + cast.label + " = (char) " + expression.label + ";\n");
                    return cast;
                } else {
                    Atributo newCast = {};
                    Atributo intConversion = convertType(newCast, expression, NUMBER_ID);

                    cast.label = gentempcode(true);
                    cast.type = CHAR_ID;
                    cast.translation = intConversion.translation + indent(getType(cast) + " " + cast.label + " = (char) " + intConversion.label + ";\n");
                    return cast;
                }
            }
        }
        
        yyerror("Not supported explicity conversion expression " + expression.type + " to " + toType);
        return expression;
    }

    // REFAZER USANDO A FUNÇÃO DE CIMA
    string getAsBoolean(Atributo atributo) {
        if (atributo.type == BOOLEAN_ID)
            return atributo.label;

        if (atributo.type == NUMBER_ID) {
            return atributo.label + " != 0";
        }

        if (atributo.type == STRING_ID) {
            return atributo.label + ".length() > 0";
        }

        if (atributo.type == CHAR_ID) {
            return atributo.label + " != '\\0'";
        }
        
        yyerror("Cannot convert " + atributo.type + " of symbol \"" + atributo.label + "\" to boolean");
        return atributo.label;
    }

};