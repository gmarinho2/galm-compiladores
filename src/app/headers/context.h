#include <string.h>
#include "str.h"
#include <list>

using namespace std;
using namespace str;

#pragma once
namespace context {

    const string NUMBER_ID = "number";
    const string BOOLEAN_ID = "bool";
    const string STRING_ID = "char*";
    const string CHAR_ID = "char";
    const string VOID_ID = "void";

    const string STRING_SIZE_STR = "_len";

    bool isVoid(string voidString) {
        return voidString == VOID_ID || voidString == "void*";
    }

    const string REAL_NUMBER_ID = "real";
    const string INTEGER_NUMBER_ID = "integer";

    const string REAL_NUMBER_DEFINITION = "double";
    const string INTEGER_NUMBER_DEFINITION = "int";

    class Variable {
        private:
            string varName;
            string varLabel;
            string varType;
            string varValue;
            bool constant;
            bool real;
            bool temp;
        public:
            Variable(string varName, string varLabel, string varType, string varValue, bool constant, bool real = false, bool temp = false) {
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

                if (this->temp || endsWith(this->varName, STRING_SIZE_STR)) {
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

    class SwitchCase {
        private:
            string label;
            string expressionTranslation;
            string translation;
            int line;
        public:
            SwitchCase(string label, string expressionTranslation, string translation, int line) {
                this->label = label;
                this->expressionTranslation = expressionTranslation;
                this->translation = translation;
                this->line = line;
            }

            string getLabel() {
                return label;
            }

            string getExpressionTranslation() {
                return expressionTranslation;
            }

            string getTranslation() {
                return translation;
            }

            int getLine() {
                return line;
            }

            bool isDefault() {
                return label == "@default";
            }
    };

    class Switch {
        private:
            list<SwitchCase*> cases;
            string endSwitchLabel;
        public:
            Switch(string endSwitchLabel) {
                this->cases = list<SwitchCase*>();
                this->endSwitchLabel = endSwitchLabel;
            }

            SwitchCase* addCase(string label, string expressionTranslation, string translation) {
                vector<string> labelParts = split(label, ",");
                SwitchCase* sc = new SwitchCase(label, expressionTranslation, translation, getCurrentLine());
                this->cases.push_back(sc);
                return sc;
            }

            SwitchCase* addExaustiveCase(string translation) {
                return addCase("@default", "", translation);
            }

            list<SwitchCase*> getCases() {
                return this->cases;
            }

            SwitchCase* getDefaultCase() {
                for (list<SwitchCase*>::iterator it = this->cases.begin(); it != this->cases.end(); ++it) {
                    SwitchCase* sc = *it;

                    if (sc->getLabel() == "@default") {
                        return sc;
                    }
                }

                return NULL;
            }

            bool hasDefaultCase() {
                return getDefaultCase() != NULL;
            }

            string getEndSwitchLabel() {
                return this->endSwitchLabel;
            }
    };

    class Context {
        private:
            list<Variable*> variables;

            list<Switch*> switches;
        public:
            Context() {
                this->variables = list<Variable*>();
            }

            Switch* createSwitch(string endSwitchLabel) {
                Switch* sw = new Switch(endSwitchLabel);
                this->switches.push_back(sw);
                return sw;
            }

            Switch* topSwitch() {
                return this->switches.back();
            }

            Switch* popSwitch() {
                Switch* sw = this->switches.back();
                this->switches.pop_back();
                return sw;
            }
            
            Variable* createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isReal = false, bool isConst = false, bool isTemp = false) {
                string realVarName = isTemp ? "@" + varName : varName;
                Variable* variable = findVariableByName(realVarName);

                if (variable == NULL) {
                    Variable* var = new Variable(realVarName, varLabel, varType, varValue, isConst, isReal, isTemp);
                    this->variables.push_back(var);
                    return var;
                }

                yyerror("The symbol \"" + varName + "\" is already declared");
                return NULL;
            }

            Variable* findVariableByName(string name) {
                for (list<Variable*>::iterator it = this->variables.begin(); it != this->variables.end(); ++it) {
                    Variable* variable = *it;

                    if (variable->getVarName() == name) {
                        return variable;
                    }
                }

                return NULL;
            }
            
            list<Variable*> getVariables() {
                return this->variables;
            }
    };

    list<Variable*> allVariables;

    class ContextStack {
        private:
            list<Context*> contexts;
            int index;
        public:
            ContextStack() {
                this->index = 0;
            }

            Switch* createSwitch(string endSwitchLabel) {
                return this->top()->createSwitch(endSwitchLabel);
            }

            Switch* topSwitch() {
                for (list<Context*>::reverse_iterator it = this->contexts.rbegin(); it != this->contexts.rend(); ++it) {
                    Switch* sw = (*it)->topSwitch();

                    if (sw != NULL) {
                        return sw;
                    }
                }

                return NULL;
            }

            Switch* popSwitch() {
                Switch* topSwitch = this->topSwitch();

                if (topSwitch != NULL) {
                    return this->top()->popSwitch();
                }

                return NULL;
            }

            bool hasCurrentSwitch() {
                return this->topSwitch() != NULL;
            }

            /**
             * Procura do topo para a base.
            */
            
            Variable* findVariableByName(string name) {
                int i = this->index;

                for (list<Context*>::reverse_iterator it = this->contexts.rbegin(); it != this->contexts.rend(); ++it, i--) {
                    Variable* variable = (*it)->findVariableByName(name);

                    if (variable != NULL) {
                        return variable;
                    }
                }

                return NULL;
            }

            Variable* createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isReal = false, bool isConst = false, bool isTemp = false) {
                Context* top = this->top();
                Variable* var = top->createVariableIfNotExists(varName, varLabel, varType, varValue, isReal, isConst, isTemp);
                allVariables.push_back(var);
                return var;
            }

            Context* top() {
                return this->contexts.back();
            }
            
            Context* first() {
                return this->contexts.front();
            }
            
            Context* pop() {
                Context* context = this->contexts.back();
                this->contexts.pop_back();
                this->index--;
                return context;
            }
            
            void push(Context* context) {
                this->contexts.push_back(context);
                this->index++;
            }
            
            bool isEmpty() {
                return this->contexts.empty();
            }

            list<Context*> getContexts() {
                return this->contexts;
            }
    };

    ContextStack* contextStack = new ContextStack();

    void init() {
        Context* globalContext = new Context();
        contextStack->push(globalContext);
    }

    ContextStack* getContextStack() {
        return contextStack;
    }

    list<Variable*> getAllVariables() {
        return allVariables;
    }
}