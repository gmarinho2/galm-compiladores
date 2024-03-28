#include <iostream>
#include <string>
#include <vector>
#include "str.h"

using namespace std;
using namespace str;

#pragma once
namespace variaveis {
    unsigned long tempCodeCounter = 0;

    const string NUMBER_ID = "number";
    const string BOOLEAN_ID = "boolean";
    const string STRING_ID = "string";
    const string CHAR_ID = "char";

    string getTypeCodeById(string id) {
        if (id == NUMBER_ID) {
            return "int";
        } else if (id == BOOLEAN_ID) {
            return "bool";
        } else if (id == STRING_ID) {
            return "string";
        }
        
        return "";
    }

    typedef struct {
        string label;
        string type;
        string translation;
    } Atributo;
    
    class Variavel {
        private:
            string varName;
            string varType;
            string varValue;
            bool constant;
        public:
            Variavel(string varName, string varType, string varValue, bool constant) {
                this->varName = varName;
                this->varType = varType;
                this->varValue = varValue;
                this->constant = constant;
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

            string getVarType() {
                return varType;
            }

            string getRealVarType() {
                return getTypeCodeById(varType);
            }

            bool isConstant() {
                return constant;
            }

            string getTranslation() {
                return getRealVarType() + " " + varName;
            }

    };

    const Variavel NULL_VAR = {"", "", "", false};

    vector<Variavel> variaveis;

    string gentempcode() {
        tempCodeCounter++;
        return "t" + to_string(tempCodeCounter);
    }

    string gerarCodigo(string codigo) {
        for (int i = 0; i < variaveis.size(); i++) {
            codigo =  "\t" + variaveis[i].getTranslation() + ";\n" + codigo;
        }

        return "/* Compilador GALM */\n\n"
                    "#include <iostream>\n\n"
                    "int main(void) {\n" +
                    codigo +
                    "\treturn 0;\n"
                    "}";
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

    Variavel createVariableIfNotExists(string varName, string varType, string varValue, bool isConst = false,  bool isGlobal = false) {
        bool found = false;
        findVariableByName(varName, found);
        
        if (!found) {
            Variavel var = {varName, varType, varValue, isConst};
            variaveis.push_back(var);
            return var;
        }

        yyerror("The symbol \"" + varName + "\" is already declared");
        return NULL_VAR;
    }

};