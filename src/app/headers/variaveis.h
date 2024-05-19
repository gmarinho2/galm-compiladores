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

    typedef struct {
        string label;
        string type;
        string details;
        string translation;
    } Atributo;

    string getType(Atributo atributo) {
        if (atributo.type == NUMBER_ID) {
            return atributo.details == REAL_NUMBER_ID ? REAL_NUMBER_DEFINITION : INTEGER_NUMBER_DEFINITION;
        }

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

    vector<string> utilitiesFunctionsFiles;

    string gerarCodigo(string codigo) {
        utilitiesFunctionsFiles.push_back("intToString");
        utilitiesFunctionsFiles.push_back("strCopy");
        utilitiesFunctionsFiles.push_back("stringConcat");
        utilitiesFunctionsFiles.push_back("strLen");
        utilitiesFunctionsFiles.push_back("realToString");
        int assertCount = countSubstring(codigo, "assert");

        string compilador = "/* Compilador GALM */\n\n#include <iostream>\n#include <math.h>\n#include <string.h>\n\n";

        compilador += "#define bool int\n";
        compilador += "#define true 1\n";
        compilador += "#define false 0\n\n";

        compilador += "using namespace std;\n\n";

        string protoTypes = "";
        string protoTypesImpl = "";

        bool success = false;

        for (int i = 0; i < utilitiesFunctionsFiles.size(); i++) {
            string file = readFileAsString("src/app/utility/" + utilitiesFunctionsFiles[i] + ".c", success);

            if (!success) {
                cout << "Ocorreu um erro ao tentar abrir o arquivo de funções utilitárias" << endl;
                cout << "Não foi possível carregar o arquivo " << utilitiesFunctionsFiles[i] << endl;
                exit(1);
            }

            string protoType = split(file, " {")[0];

            protoTypes += protoType + ";\n";
            protoTypesImpl += file + "\n";
        }

        compilador += protoTypes + "\n";

        compilador += "typedef union {\n\t" + REAL_NUMBER_DEFINITION + " real;\n\t" + INTEGER_NUMBER_DEFINITION + " integer;\n} number;\n\n";

        compilador += "\nint main(void) {\n";

        list<Variable*> allVars = getContextStack()->getAllVariables();
        bool hasTemp = false;

        for (list<Variable*>::iterator it = allVars.begin(); it != allVars.end(); ++it) {
            Variable* var = *it;

            if (var->isTemp()) {
                hasTemp = true;
                continue;
            }

            compilador += "\t" + var->getTranslation() + ";\n";
        }

        if (hasTemp)
            compilador += "\n\t/* Variáveis Temporárias */\n\n";

        for (list<Variable*>::iterator it = allVars.begin(); it != allVars.end(); ++it) {
            Variable* var = *it;

            if (var->isTemp())
                compilador += "\t" + var->getTranslation() + ";\n";
        }

        compilador += "\n" + codigo;

        if (assertCount > 0) {
            compilador += "\tcout << \"\\033[1;32mAll of " + to_string(assertCount) + " assertions passed. Congrats!\\033[0m\\n\";\n";
        }

        compilador += "\treturn 0;\n}\n\n";

        compilador += protoTypesImpl;

        return compilador;
    }

    /**
     * Função que retorna uma variável a partir do nome
     * Ela busca na tabela de simbolos e retorna a variável
     * Caso não encontre, retorna uma instância sem nada e com o atributo found como false
     */

    Variable* findVariableByName(string varName) {
        return getContextStack()->findVariableByName(varName);
    }

    Variable* createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isReal = false, bool isConst = false, bool isTemp = false) {
        return getContextStack()->createVariableIfNotExists(varName, varLabel, varType, varValue, isReal, isConst, isTemp);
    }
    
    void createString(string strLabel, string &translation, string sizeStr = "") {
        string sizeOfString = strLabel + STRING_SIZE_STR;
        createVariableIfNotExists(sizeOfString, sizeOfString, NUMBER_ID, sizeStr, false, true, true);

        translation += sizeOfString + " = " + sizeStr+ ";\n";
    }

    bool isInterpretedAsNumeric(string type) {
        return type == NUMBER_ID || type == CHAR_ID || type == BOOLEAN_ID;
    }

    string toId(string typeId) {
        if (typeId == "string") return "char*";

        return typeId;
    }

};