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

    unsigned long long int currentLine = 1;

    void addLine() {
        currentLine++;
    }

    int getCurrentLine() {
        return currentLine;
    }

    void yyerror(string message, string error = "Syntax error") {
        cout << "\033[1;31m" << error << ": " << message << " (line " << currentLine << ")" << endl << "\033[0m";
        exit(1);
    }

    void yywarning(string message, string warning = "Warning") {
        cout << "\033[1;33m" << warning << ": " << message << " (line " << currentLine << ")" << endl << "\033[0m";
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
            bool temp;
        public:
            Variavel(string varName, string varLabel, string varType, string varValue, bool constant, bool real = false, bool temp = false) {
                this->varName = varName;
                this->varLabel = varLabel;
                this->varType = varType;
                this->varValue = varValue;
                this->constant = constant;
                this->real = real;
                this->temp = temp;
            }

            bool isTemp() {
                return temp;
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
                    yyerror("The symbol \"" + varName + "\" was already initialized with a value");

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

                if (this->temp) {
                    if (this->varType == NUMBER_ID) {
                        return real ? "float" : "int";
                    }
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
        int assertCount = countSubstring(codigo, "assert");

        string compilador = "/* Compilador GALM */\n\n#include <iostream>\n\n";

        compilador += "#define bool int\n";
        compilador += "#define true 1\n";
        compilador += "#define false 0\n\n";

        compilador += "using namespace std;\n\n";

        compilador += "typedef union {\n\t" + REAL_NUMBER_DEFINITION + " real;\n\t" + INTEGER_NUMBER_DEFINITION + " integer;\n} number;\n\n";

        compilador += "\nint main(void) {\n";

        bool hasTemp = false;

        for (int i = 0; i < variaveis.size(); i++) {
            if (variaveis[i].isTemp()) {
                hasTemp = true;
                continue;
            }

            compilador += "\t" + variaveis[i].getTranslation() + ";\n";
        }

        if (hasTemp)
            compilador += "\n\t/* Variáveis Temporárias */\n\n";

        for (int i = 0; i < variaveis.size(); i++) {
            if (variaveis[i].isTemp())
                compilador += "\t" + variaveis[i].getTranslation() + ";\n";
        }

        compilador += "\n" + codigo;

        if (assertCount > 0) {
            compilador += "\tcout << \"\\033[1;32mAll of " + to_string(assertCount) + " assertions passed. Congrats!\\033[0m\\n\";\n";
        }

        compilador += "\treturn 0;\n}";

        return compilador;
    }

    /**
     * Função que retorna uma variável a partir do nome
     * Ela busca na tabela de simbolos e retorna a variável
     * Caso não encontre, retorna uma instância sem nada e com o atributo found como false
     */

    Variavel* findVariableByName(string varName, bool &found) {
        for (int i = 0; i < variaveis.size(); i++) {
            if (variaveis[i].getVarName() == varName) {
                found = true;
                return &variaveis[i];
            }
        }

        return &NULL_VAR;
    }

    Variavel createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isReal = false, bool isConst = false, bool isTemp = false) {
        string realVarName = isTemp ? "@" + varName : varName;
        
        bool found = false;
        findVariableByName(realVarName, found);

        if (!found) {
            Variavel var = Variavel(realVarName, varLabel, varType, varValue, isConst, isReal, isTemp);
            variaveis.push_back(var);
            return var;
        }

        yyerror("The symbol \"" + realVarName + "\" is already declared");
        return NULL_VAR;
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

    bool isInterpretedAsNumeric(string type) {
        return type == NUMBER_ID || type == CHAR_ID || type == BOOLEAN_ID;
    }

};