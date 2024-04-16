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

    void translate(Atributo &arg1, string &translation, string toType, string toDetails = "") {
        if (arg1.type == toType && arg1.details == toDetails) {
            return;
        }
        
        string temp = gentempcode();
        createVariableIfNotExists(temp, temp, toType, temp, false, true, true);

        if (arg1.type == NUMBER_ID) {
            if (!empty(toDetails)) {
                if (toDetails == INTEGER_NUMBER_ID) {
                    translation += temp + " = (int) " + arg1.label + ";\n";
                } else if (toDetails == REAL_NUMBER_ID) {
                    translation += temp + " = (float) " + arg1.label + ";\n";
                }
            } else if (toType == BOOLEAN_ID) {
                translation += temp + " = " + arg1.label + " != 0;\n";
            }
        }

        if (empty(temp)) {
            cout << "ta porra menor";
        }

        arg1.label = temp;
    }

}