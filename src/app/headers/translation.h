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
        if (arg1.type == toType) {
            if (toType == NUMBER_ID) {
                if (arg1.details == toDetails) {
                    return arg1.label;
                }
            } else {
                return arg1.label;
            }
        }
        
        string temp = gentempcode();
        createVariableIfNotExists(temp, temp, toType, temp, toType == NUMBER_ID && toDetails == REAL_NUMBER_ID, true, true);

        if (arg1.type == NUMBER_ID) {
            if (toType == BOOLEAN_ID) {
                translation += temp + " = " + arg1.label + " != 0;\n";
            } else if (toType == CHAR_ID) {
                translation += temp + " = (char) " + arg1.label + ";\n";
            } else if (toType == STRING_ID) {
                string newLabel = gentempcode();
                createVariableIfNotExists(newLabel, newLabel, STRING_ID, newLabel, false, true, true);

                if (arg1.details == INTEGER_NUMBER_ID) { 
                    translation += newLabel + " = intToString(" + arg1.label + ");\n";
                } else {
                    translation += newLabel + " = realToString(" + arg1.label + ");\n";
                }

                createString(newLabel, translation, "strLen(" + newLabel + ")");

                translation += temp + " = strCopy(" + newLabel + ", strLen(" + newLabel + "));\n";
                createString(temp, translation, newLabel + STRING_SIZE_STR);
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
                string notArg = gentempcode();
                createVariableIfNotExists(notArg, notArg, BOOLEAN_ID, notArg, false, true, true);

                translation += notArg + " = !" + arg1.label + ";\n";
                
                string stringLength = gentempcode();
                createVariableIfNotExists(stringLength, stringLength, NUMBER_ID, INTEGER_NUMBER_ID, false, true, true);

                translation += stringLength + " = " + notArg + " + 4;\n";

                string newLabel = gentempcode();
                createVariableIfNotExists(newLabel, newLabel, STRING_ID, newLabel, false, true, true);

                translation += newLabel + " = (char*) malloc(" + stringLength + ");\n";

                string ifLabel = genlabelcode();
                string elseLabel = genlabelcode();

                translation += "if(!" + notArg + ") goto " + ifLabel + ";\n";
                translation += newLabel + "[0] = 'f';\n";
                translation += newLabel + "[1] = 'a';\n";
                translation += newLabel + "[2] = 'l';\n";
                translation += newLabel + "[3] = 's';\n";
                translation += newLabel + "[4] = 'e';\n";
                translation += "goto " + elseLabel + ";\n";
                translation += ifLabel + ":\n";
                translation += newLabel + "[0] = 't';\n";
                translation += newLabel + "[1] = 'r';\n";
                translation += newLabel + "[2] = 'u';\n";
                translation += newLabel + "[3] = 'e';\n";
                translation += elseLabel + ":\n";

                translation += "cout << " + stringLength + " << endl;\n";
                
                createString(temp, translation, stringLength);
                translation += temp + " = strCopy(" + newLabel + ", " + stringLength + ");\n";
            } else {
                yyerror("Cannot convert boolean to " + toType, "Type check error");
            }
        } else {
            yyerror("Cannot convert " + arg1.type + " to " + toType, "Type check error");
        }

        return temp;
    }

}