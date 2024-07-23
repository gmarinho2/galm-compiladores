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

    string translate(const Atributo &arg1, string &translation, string toType) {
        if (arg1.type == toType) {
            return arg1.label;
        }
        
        string temp = gentempcode();
        createVariableIfNotExists(temp, temp, toType, temp, true, true);

        if (arg1.type == NUMBER_ID) {
            if (toType == BOOLEAN_ID) {
                translation += temp + " = numberToBool(" + arg1.label + ");\n";
            } else if (toType == CHAR_ID) {
                translation += temp + " = numberToChar(" + arg1.label + ");\n";
            } else if (toType == STRING_ID) {
                string newLabel = gentempcode();
                createVariableIfNotExists(newLabel, newLabel, STRING_ID, newLabel, true, true);

                translation += newLabel + " = numberToString(" + arg1.label + ");\n";
                translation += temp + " = strCopy(" + newLabel + ");\n";
            } else {
                yyerror("Cannot convert number to " + toType, "Type check error");
            }
        } else if (arg1.type == CHAR_ID) {
            if (toType == NUMBER_ID) {
                translation += temp + ".value.integer = (int) " + arg1.label + ";\n";
                translation += temp + ".isInteger = true;\n";
            } else if (toType == STRING_ID) {
                translation += temp + ".str = (char*) malloc(1);\n";
                translation += temp + ".str[0] = " + arg1.label + ";\n";
                translation += temp + ".length = 1;\n";
            } else if (toType == BOOLEAN_ID) {
                translation += temp + " = " + arg1.label + " != 0;\n";
            } else {
                yyerror("Cannot convert char to " + toType, "Type check error");
            }
        } else if (arg1.type == BOOLEAN_ID) {
            if (toType == NUMBER_ID) {
                translation += temp + ".value.integer = " + arg1.label + ";\n";
                translation += temp + ".isInteger = true;\n";
            } else if (toType == STRING_ID) {
                string notArg = gentempcode();
                createVariableIfNotExists(notArg, notArg, BOOLEAN_ID, notArg, true, true);

                translation += notArg + " = !" + arg1.label + ";\n";

                translation += temp + ".length = " + notArg + " + 4;\n";
                translation += temp + ".str = (char*) malloc(" + temp + ".length);\n";

                string ifLabel = genlabelcode();
                string elseLabel = genlabelcode();

                translation += "if(!" + notArg + ") goto " + ifLabel + ";\n";
                translation += temp + ".str[0] = 'f';\n";
                translation += temp + ".str[1] = 'a';\n";
                translation += temp + ".str[2] = 'l';\n";
                translation += temp + ".str[3] = 's';\n";
                translation += temp + ".str[4] = 'e';\n";
                translation += "goto " + elseLabel + ";\n";
                translation += ifLabel + ":\n";
                translation += temp + ".str[0] = 't';\n";
                translation += temp + ".str[1] = 'r';\n";
                translation += temp + ".str[2] = 'u';\n";
                translation += temp + ".str[3] = 'e';\n";
                translation += elseLabel + ":\n";
            } else {
                yyerror("Cannot convert boolean to " + toType, "Type check error");
            }
        } else {
            yyerror("Cannot convert " + arg1.type + " to " + toType, "Type check error");
        }

        return temp;
    }

}