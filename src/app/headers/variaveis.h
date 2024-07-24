#include <iostream>
#include <string.h>
#include <vector>

#include "str.h"
#include "file.h"
#include "context.h"

using namespace std;
using namespace str;
using namespace file;
using namespace context;

#pragma once
namespace variaveis {
    unsigned long long int tempCodeCounter = 0;
    unsigned long long int varCodeCounter = 0;
    unsigned long long int labelCounter = 0;
    unsigned long long int functionCounter = 0;

    typedef struct {
        string label;
        string type;
        string translation;
    } Atributo;

    string getType(Atributo atributo) {
        return atributo.type;
    }

    string gentempcode(bool isVar = false) {
        if(isVar) {
            return "var" + to_string(++varCodeCounter);
        }

        return "t" + to_string(++tempCodeCounter);
    }

    string genlabelcode() {
        return "label_" + to_string(++labelCounter);
    }

    string genfunctioncode() {
        return "f" + to_string(++functionCounter);
    }

    vector<string> utilitiesFunctionsFiles;

    string gerarCodigo(string codigo) {
        bool success = false;
        string codigoIntermediario = readFileAsString("src/app/utility/codigo-intermediario.cpp", success);

        if (!success) {
            cout << "Ocorreu um erro ao tentar abrir o arquivo de funções utilitárias" << endl;
            cout << "Não foi possível carregar o arquivo codigo-intermediario.cpp" << endl;
            exit(1);
        }

        vector<string> splitted = split(codigoIntermediario, "/* %%%%%%%%%%%%%%%%%%%%%%% */");

        string header = splitted[0];
        string footer = splitted[1];

        int assertCount = countSubstring(codigo, "assert");

        string compilador = simplifyCode ? "" : header;

        list<Variable*> allVars = getAllVariables();
        bool hasTemp = false;

        compilador += "\n/* User Variables */\n\n";

        for (list<Variable*>::iterator it = allVars.begin(); it != allVars.end(); ++it) {
            Variable* var = *it;

            if (var->isTemp()) {
                hasTemp = true;
                continue;
            }

            compilador += var->getTranslation() + ";\n";
        }

        if (hasTemp)
            compilador += "\n/* Compiler Temporary Variables */\n\n";

        for (list<Variable*>::iterator it = allVars.begin(); it != allVars.end(); ++it) {
            Variable* var = *it;

            if (var->isTemp())
                compilador += var->getTranslation() + ";\n";
        }

        ContextStack *contextStack = getContextStack();
        list<Function*> allFuncs = contextStack->getFunctions();

        if (contextStack->getFunctions().size() > 0) {
            compilador += "\n/* Functions */\n\n";

            for (list<Function*>::iterator it = allFuncs.begin(); it != allFuncs.end(); ++it) {
                Function* func = *it;

                compilador += func->getDeclaration() + "\n";
            }
        }

        compilador += "\nint main(void) {\n";

        compilador += codigo;

        if (assertCount > 0 && testMode) {
            compilador += "\tcout << \"\\033[1;32mAll of " + to_string(assertCount) + " assertions passed. Congrats!\\033[0m\\n\";\n";
        }

        compilador += "\treturn 0;\n}";

        compilador += simplifyCode ? "" : footer;

        return compilador;
    }

    /**
     * Função que retorna uma variável a partir do nome
     * Ela busca na tabela de simbolos e retorna a variável
     * Caso não encontre, retorna uma instância sem nada e com o atributo found como false
     */

    Variable* findVariableByName(string varName) {
        ContextStack* stack = getContextStack();

        Function* creationFunction = topFunctionStack();

        if (creationFunction != NULL) {
            Parameter* param = creationFunction->findParameterByName(varName);

            if (param != NULL) {
                return new Variable(param->getName(), param->getNickname(), param->getType(), "", true, false);
            }
        }

        return stack->findVariableByName(varName);
    }

    Function* findFunction(string functionName, string types) {
        return getContextStack()->findFunction(functionName, types);
    }

    Variable* createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isConst = false, bool isTemp = false) {
        return getContextStack()->createVariableIfNotExists(varName, varLabel, varType, varValue, isConst, isTemp);
    }

    bool isInterpretedAsNumeric(string type) {
        return type == NUMBER_ID || type == CHAR_ID || type == BOOLEAN_ID;
    }

};