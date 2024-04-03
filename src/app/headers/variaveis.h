#include <iostream>
#include <string>
#include <vector>
#include "str.h"

using namespace std;
using namespace str;

#pragma once
namespace variaveis {
    unsigned long long int tempCodeCounter = 0;

    const string NUMBER_ID = "number";
    const string BOOLEAN_ID = "bool";
    const string STRING_ID = "string";
    const string CHAR_ID = "char";

    const string REAL_NUMBER_ID = "real";
    const string INTEGER_NUMBER_ID = "integer";

    typedef struct {
        string label;
        string type;
        string details;
        string translation;
    } Atributo;
    
    class Variavel {
        private:
            string varName;
            string varType;
            string varValue;
            bool constant;
            bool real;
        public:
            Variavel(string varName, string varType, string varValue, bool constant, bool real = false) {
                this->varName = varName;
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

            void setVarValue(string value) {
                this->varValue = value;
            }

            void setIsReal(bool real) {
                this->real = real;
            }

            bool isReal() {
                return real;
            }

            string getVarType() {
                return varType;
            }

            string getRealVarLabel() {
                if (varType == NUMBER_ID) 
                    return varName + "." +  (real ? REAL_NUMBER_ID : INTEGER_NUMBER_ID);
                return varName;
            }

            string getDetails() {
                return varType == NUMBER_ID ? (real ? REAL_NUMBER_ID : INTEGER_NUMBER_ID) : "";
            }

            bool isConstant() {
                return constant;
            }

            string getTranslation() {
                return getVarType() + " " + varName;
            }

            bool isNumber() {
                return varType == NUMBER_ID;
            }

    };

    string getType(Atributo atributo) {
        if (atributo.type == NUMBER_ID) {
            return atributo.details == REAL_NUMBER_ID ? "double" : "long long int";
        }

        return atributo.type;
    }

    const Variavel NULL_VAR = Variavel("", "", "", false);

    vector<Variavel> variaveis;

    string gentempcode() {
        tempCodeCounter++;
        return "t" + to_string(tempCodeCounter);
    }

    string gerarCodigo(string codigo) {
        string compilador = "/* Compilador GALM */\n\n#include <iostream>\n\n";

        compilador += "typedef union {\n\tdouble real;\n\tlong long int integer;\n} number;\n\n";

        for (int i = 0; i < variaveis.size(); i++) {
            compilador += variaveis[i].getTranslation() + ";\n";
        }

        compilador += "\nint main(void) {\n" + codigo + "\treturn 0;\n}";


        return compilador;
    }

    void yyerror(string message, string error = "Syntax error") {
        cout << "\033[1;31m" << error << ": " << message << endl << "\033[0m";
        exit(1);
    }

    /**
     * Função que retorna uma variável a partir do nome
     * Ela busca na tabela de simbolos e retorna a variável
     * Caso não encontre, retorna uma instância sem nada e com o atributo found como false
     */

    Variavel findVariableByName(string varName, bool &found) {
        for (int i = 0; i < variaveis.size(); i++)
            if (variaveis[i].getVarName() == varName) {
                found = true;
                return variaveis[i];
            }

        return NULL_VAR;
    }

    Variavel createVariableIfNotExists(string varName, string varType, string varValue, bool isReal = false, bool isConst = false,  bool isGlobal = false) {
        bool found = false;
        findVariableByName(varName, found);
        
        if (!found) {
            Variavel var = Variavel(varName, varType, varValue, isConst, isReal);
            variaveis.push_back(var);
            return var;
        }

        yyerror("The symbol \"" + varName + "\" is already declared");
        return NULL_VAR;
    }

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