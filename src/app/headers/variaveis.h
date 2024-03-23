#include <iostream>
#include <string>

using namespace std;

#pragma once
namespace variaveis {
    unsigned long tempCodeCounter = 0;

    const string NUMBER_ID = "number";
    const string BOOLEAN_ID = "boolean";
    const string STRING_ID = "string";

    typedef struct
    {
        string label;
        string type;
        string translation;
    } Atributo;

    string gentempcode() {
        return "t" + std::to_string(++tempCodeCounter);
    }

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

    string gerarCodigo(string codigo) {
        return "/*Compilador GALM*/\n"
                    "#include <iostream>\n"
                    "int main(void) {\n" +
                    codigo +
                    "\treturn 0;\n"
                    "}";
    }
};