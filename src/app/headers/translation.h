#include <iostream>
#include <string>
#include <vector>
#include "str.h"
#include "variaveis.h"

using namespace std;
using namespace str;
using namespace variaveis;

#pragma once
namespace translation {
    
    class TranslationResult {
        private:
            string translation;
            string label;
        public:
            TranslationResult(string translation, string label) {
                this->translation = translation;
                this->label = label;
            }

            string getTranslation() {
                return translation;
            }

            string getLabel() {
                return label;
            }
    };

    string translate(const Atributo &arg1, string &translation, string toType, string toDetails = "") {
        if (arg1.type == toType && arg1.details == toDetails) {
            return arg1.label;
        }
        
        string temp = gentempcode();
        createVariableIfNotExists(temp, temp, toType, temp, toDetails == REAL_NUMBER_ID, true, true);

        if (arg1.type == NUMBER_ID) {
            if (toType == BOOLEAN_ID) {
                translation += temp + " = " + arg1.label + " != 0;\n";
            } else if (toType == CHAR_ID) {
                translation += temp + " = (char) " + arg1.label + ";\n";
            } else if (toType == STRING_ID) {
                translation += "strcpy(" + temp + ", intToString(" + arg1.label + "));\n";
                createString(temp, translation, "strLen(" + temp + ")");
            } else if (!empty(toDetails)) {
                if (toDetails == REAL_NUMBER_ID) {
                    translation += temp + " = (float) " + arg1.label + ";\n";
                } else {
                    translation += temp + " = (int) " + arg1.label + ";\n";
                }
            } else {
                yyerror("Cannot convert number to " + toType, "Type check error");
            }
        } else if (arg1.type == CHAR_ID) {
            if (toType == NUMBER_ID) {
                translation += temp + " = (int) " + arg1.label + ";\n";
            } else if (toType == STRING_ID) {
                createString(temp, translation, "1");
                translation += temp + " = (char*) malloc(1);\n";
                translation += temp + "[0] = " + arg1.label + ";\n";
            } else if (toType == BOOLEAN_ID) {
                translation += temp + " = " + arg1.label + " != 0;\n";
            } else {
                yyerror("Cannot convert char to " + toType, "Type check error");
            }
        } else if (arg1.type == BOOLEAN_ID) {
            if (toType == NUMBER_ID) {
                translation += temp + " = " + arg1.label + ";\n";
            } else if (toType == STRING_ID) {

                translation += "int size_b = " + arg1.label + " ? 4 : 5;\n";

                createString(temp, translation, "size_b");
                translation += "strcpy(" + temp + ", " + arg1.label + " ? \"true\" : \"false\");\n"; // NÃO PODE, TA COM MAIS DE 3 ENDEREÇOS
            } else {
                yyerror("Cannot convert boolean to " + toType, "Type check error");
            }
        } else {
            yyerror("Cannot convert " + arg1.type + " to " + toType, "Type check error");
        }

        return temp;
    }

}