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

    class Context {
        private:
            list<Variable*> variables;
        public:
            Context() {
                this->variables = list<Variable*>();
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

    class Stack {
        private:
            list<Context*> contexts;
            int index;
        public:
            Stack() {
                this->index = 0;
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
                return top()->createVariableIfNotExists(varName, varLabel, varType, varValue, isReal, isConst, isTemp);
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

            list<Variable*> getAllVariables() {
                list<Variable*> allVariables;

                for (list<Context*>::iterator it = this->contexts.begin(); it != this->contexts.end(); ++it) {
                    list<Variable*> variables = (*it)->getVariables();

                    for (list<Variable*>::iterator it2 = variables.begin(); it2 != variables.end(); ++it2) {
                        allVariables.push_back(*it2);
                    }
                }

                return allVariables;
            }
    };

    Stack* stack = new Stack();

    void init() {
        Context* globalContext = new Context();
        stack->push(globalContext);
    }

    Stack* getContextStack() {
        return stack;
    }
}