#include <string.h>
#include "str.h"
#include <list>

using namespace std;
using namespace str;

#pragma once
namespace context {

    const string NUMBER_ID = "number";
    const string BOOLEAN_ID = "bool";
    const string STRING_ID = "string";
    const string CHAR_ID = "char";
    const string VOID_ID = "void";

    bool simplifyCode = false;
    bool testMode = false;

    bool isVoid(string voidString) {
        return voidString == VOID_ID || voidString == "void*";
    }

    string getRealTypeName(string type) {
        if (type == "string") {
            return "String";
        }

        return type;
    }

    class Variable {
        private:
            string varName;
            string varLabel;
            string varType;
            string varValue;
            bool constant;
            bool temp;
        public:
            Variable(string varName, string varLabel, string varType, string varValue, bool constant, bool temp = false) {
                this->varName = varName;
                this->varLabel = varLabel;
                this->varType = varType;
                this->varValue = varValue;
                this->constant = constant;
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

            string getVarType() {
                if (this->varType == VOID_ID) {
                    return "void*";
                }

                return this->varType;
            }

            string getRealVarLabel() {
                return varLabel;
            }

            bool isConstant() {
                return constant;
            }

            string getTranslation() {
                return getRealTypeName(getVarType()) + " " + varLabel;
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
            string switchType;
            string endSwitchLabel;
        public:
            Switch(string switchType, string endSwitchLabel) {
                this->cases = list<SwitchCase*>();
                this->switchType = switchType;
                this->endSwitchLabel = endSwitchLabel;
            }

            string getSwitchType() {
                return this->switchType;
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

    class EndableStatement {
        private:
            string startLabel;
            string endLabel;
            bool switchStatement;
        public:
            EndableStatement(string startLabel, string endLabel, bool switchStatement = false) {
                this->startLabel = startLabel;
                this->endLabel = endLabel;
                this->switchStatement = switchStatement;
            }

            bool isSwitchStatement() {
                return switchStatement;
            }

            string getStartLabel() {
                return startLabel;
            }

            string getEndLabel() {
                return endLabel;
            }

            bool hasEndLabel() {
                return !endLabel.empty();
            }

            bool hasStartLabel() {
                return !startLabel.empty();
            }
    };

    class Context {
        private:
            list<Variable*> variables;

            list<Switch*> switches;
            list<EndableStatement*> endableStatements;
        public:
            Context() {
                this->variables = list<Variable*>();
            }

            EndableStatement* createEndableStatement(string startLabel, string endLabel, bool switchStatement = false) {
                EndableStatement* es = new EndableStatement(startLabel, endLabel, switchStatement);
                this->endableStatements.push_back(es);
                return es;
            }   

            EndableStatement* topEndableStatement() {
                return this->endableStatements.back();
            }

            EndableStatement* popEndableStatement() {
                EndableStatement* es = this->endableStatements.back();
                this->endableStatements.pop_back();
                return es;
            }

            EndableStatement* topLoopStatement() {
                for (list<EndableStatement*>::reverse_iterator it = this->endableStatements.rbegin(); it != this->endableStatements.rend(); ++it) {
                    EndableStatement* es = *it;

                    if (!es->isSwitchStatement()) {
                        return es;
                    }
                }

                return NULL;
            }

            Switch* createSwitch(string switchType, string endSwitchLabel) {
                Switch* sw = new Switch(switchType, endSwitchLabel);
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
            
            Variable* createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isConst = false, bool isTemp = false) {
                string realVarName = isTemp ? "@" + varName : varName;
                Variable* variable = findVariableByName(realVarName);

                if (variable == NULL) {
                    Variable* var = new Variable(realVarName, varLabel, varType, varValue, isConst, isTemp);
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

            Switch* createSwitch(string switchType, string endSwitchLabel) {
                return this->top()->createSwitch(switchType, endSwitchLabel);
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
                for (list<Context*>::reverse_iterator it = this->contexts.rbegin(); it != this->contexts.rend(); ++it) {
                    Switch* popSwitch = (*it)->topSwitch();

                    if (popSwitch != NULL) {
                        return (*it)->popSwitch();
                    }
                }

                return NULL;
            }

            bool hasCurrentSwitch() {
                return this->topSwitch() != NULL;
            }

            EndableStatement* createEndableStatement(string startLabel, string endLabel, bool switchStatement = false) {
                return this->top()->createEndableStatement(startLabel, endLabel, switchStatement);
            }

            EndableStatement* topEndableStatement() {
                for (list<Context*>::reverse_iterator it = this->contexts.rbegin(); it != this->contexts.rend(); ++it) {
                    EndableStatement* es = (*it)->topEndableStatement();

                    if (es != NULL) {
                        return es;
                    }
                }

                return NULL;
            }

            EndableStatement* topLoopStatement() {
                for (list<Context*>::reverse_iterator it = this->contexts.rbegin(); it != this->contexts.rend(); ++it) {
                    EndableStatement* es = (*it)->topLoopStatement();

                    if (es != NULL) {
                        return es;
                    }
                }

                return NULL;
            }

            EndableStatement* popEndableStatement() {
                EndableStatement* topEndableStatement = this->topEndableStatement();

                if (topEndableStatement != NULL) {
                    return this->top()->popEndableStatement();
                }

                return NULL;
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

            Variable* createVariableIfNotExists(string varName, string varLabel, string varType, string varValue, bool isConst = false, bool isTemp = false) {
                Context* top = this->top();
                Variable* var = top->createVariableIfNotExists(varName, varLabel, varType, varValue, isConst, isTemp);
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

    void init(int argc, char* argv[]) {

        if (argc > 1) {
            for (int i = 1; i < argc; i++) {
                if (strcmp(argv[i], "--s") == 0) {
                    simplifyCode = true;
                } else if (strcmp(argv[i], "--t") == 0) {
                    testMode = true;
                }
            }
        }

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