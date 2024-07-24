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

    const string ARRAY_NUMBER_ID = "NumberArray";
    const string ARRAY_BOOLEAN_ID = "BoolArray";
    const string ARRAY_STRING_ID = "StringArray";
    const string ARRAY_CHAR_ID = "CharArray";
    const string VOID_CHAR_ID = "VoidArray";

    bool simplifyCode = false;
    bool testMode = false;

    bool isVoid(string voidString) {
        return voidString == VOID_ID || voidString == "void*";
    }

    string toType(string type) {
        return type == "string" ? "String" : type;
    }
    
    bool isArray(string type) {
        return type.find("Array") != string::npos;
    }

    string getArrayTypeFromType(string type) {
        if (isArray(type)) {
            return type;
        }

        if (type == NUMBER_ID) {
            return ARRAY_NUMBER_ID;
        }

        if (type == BOOLEAN_ID) {
            return ARRAY_BOOLEAN_ID;
        }

        if (type == STRING_ID) {
            return ARRAY_STRING_ID;
        }

        if (type == CHAR_ID) {
            return ARRAY_CHAR_ID;
        }

        if (type == VOID_ID) {
            return VOID_CHAR_ID;
        }

        return VOID_ID;
    }

    string getOriginalTypeFromArrayType(string arrayType) {
        if (arrayType == ARRAY_NUMBER_ID) {
            return NUMBER_ID;
        }

        if (arrayType == ARRAY_BOOLEAN_ID) {
            return BOOLEAN_ID;
        }

        if (arrayType == ARRAY_STRING_ID) {
            return STRING_ID;
        }

        if (arrayType == ARRAY_CHAR_ID) {
            return CHAR_ID;
        }

        if (arrayType == VOID_CHAR_ID) {
            return VOID_ID;
        }

        return VOID_ID;
    }

    class Array;
    class Variable;
    class SwitchCase;
    class EndableStatement;
    class Context;
    class ContextStack;
    class Function;
    class Parameter;

    ContextStack* contextStack;
    list<Variable*> allVariables;
    list<Array*> arrayCreationStack;
    list<Function*> functionCreationStack;

    ContextStack* getContextStack();
    list<Variable*> getAllVariables();

    Array* createArray();
    Array* topArrayStack();
    Array* popArrayStack();
    bool isArrayStackEmpty();

    Function* createFunction(string name, string nickname);
    Function* topFunctionStack();
    Function* popFunctionStack();
    bool isFunctionStackEmpty();

    Function* createFunction(Function* function);

    class Parameter {
        private:
            string name;
            string nickname;
            string type;
        public:
            Parameter(string name, string nickname, string type) {
                this->name = name;
                this->nickname = nickname;
                this->type = type;
            }

            string getName() {
                return name;
            }

            string getNickname() {
                return nickname;
            }

            string getType() {
                return type;
            }
    };

    class Function {
        private:
            string name;
            string nickname;
            string returnType;
            list<Parameter*> parameters;
            string translation;
        public:
            Function(string name, string nickname) {
                this->name = name;
                this->nickname = nickname;
                this->returnType = VOID_ID;
                this->parameters = list<Parameter*>();
                this->translation = "";
            }

            Parameter* findParameterByName(string name) {
                for (list<Parameter*>::iterator it = parameters.begin(); it != parameters.end(); ++it) {
                    Parameter* parameter = *it;

                    if (parameter->getName() == name) {
                        return parameter;
                    }
                }

                return NULL;
            }

            void setReturnType(string returnType) {
                this->returnType = returnType;
            }

            string getNickname() {
                return nickname;
            }

            string getName() {
                return name;
            }

            string getReturnType() {
                return returnType;
            }

            void addParameter(string name, string type) {
                for (list<Parameter*>::iterator it = parameters.begin(); it != parameters.end(); ++it) {
                    Parameter* parameter = *it;

                    if (parameter->getName() == name) {
                        yyerror("The parameter \"" + name + "\" of the function \"" + this->name + "\" was already declared");
                    }
                }

                Parameter* parameter = new Parameter(name, "param" + to_string(parameters.size()), type);
                parameters.push_back(parameter);
            }

            list<Parameter*> getParameters() {
                return parameters;
            }

            string getDeclaration() {
                string translation = "";

                translation += returnType + " " + nickname + "(";

                for (list<Parameter*>::iterator it = parameters.begin(); it != parameters.end(); ++it) {
                    Parameter* parameter = *it;

                    translation += toType(parameter->getType()) + " " + parameter->getNickname() + ", ";
                }

                if (parameters.size() > 0) {
                    translation = translation.substr(0, translation.size() - 2);
                }

                translation += ") {\n";

                translation += indent(this->translation);

                translation += "}\n";

                return translation;
            }

            string getTranslation() {
                return translation;
            }

            void setTranslation(string translation) {
                this->translation = translation;
            }
    };

    class Array {
        private:
            string type;

            list<string> labels;
            list<Array*> childs;
        public:
            Array() {
                this->type = VOID_ID;
            }

            void addLabel(string label) {
                if (childs.size() > 0) {
                    yyerror("Expected a expression, but got a child array.");
                }

                labels.push_back(label);
            }

            void addChild(Array* child) {
                if (labels.size() > 0) {
                    yyerror("Expected a child array, but got a expression. Did you forget to use the [] operator?");
                }

                if (childs.size() > 0) {
                    Array* firstChild = childs.front();
                    int firstChildDepth = firstChild->getDepth();
                    int firstChildElementsCount = firstChild->getElementsCount();

                    if (child->getDepth() != firstChildDepth) {
                        yyerror("The first child array has a depth of " + to_string(firstChildDepth) + ", but the new child array has a depth of " + to_string(child->getDepth()));
                    } else if (child->getElementsCount() != firstChildElementsCount) {
                        yyerror("The first child array has " + to_string(firstChildElementsCount) + " elements, but the new child array has " + to_string(child->getElementsCount()) + " elements");
                    }
                }

                childs.push_back(child);
            }

            void setType(string type) {
                this->type = type;
            }

            string getType() {
                return type;
            }

            list<string> getLabels() {
                return labels;
            }

            list<Array*> getChilds() {
                return childs;
            }

            list<string> getAllLabels() {
                list<string> allLabels;

                if (labels.size() > 0) {
                    return labels;
                }

                for (list<Array*>::iterator it = childs.begin(); it != childs.end(); ++it) {
                    Array* child = *it;
                    list<string> childLabels = child->getAllLabels();

                    allLabels.insert(allLabels.end(), childLabels.begin(), childLabels.end());
                }

                return allLabels;
            }

            string getTranslation(string label, string sumSizeofNumber, string sumSizeofInt) {
                string arrayType = getArrayTypeFromType(type);
                string originalType = getOriginalTypeFromArrayType(type);

                int* dimensions = getDimensions();

                string translation = "";

                list<string> allLabels = getAllLabels();

                for (list<string>::iterator it = allLabels.begin(); it != allLabels.end(); ++it) {
                    string currentLabelTranslation = split(*it, " - ")[1];

                    translation += currentLabelTranslation;
                }


                translation += sumSizeofNumber + " = sizeof(" + toType(originalType) + ") * " + to_string(getElementsCount()) + ";\n";
                translation += sumSizeofInt + " = sizeof(int) * " + to_string(dimensions[0] + 1) + ";\n";

                translation += label + ".array = (" + toType(originalType) + "*) malloc(" + sumSizeofNumber + ");\n";
                translation += label + ".dimensions = (int*) malloc(" + sumSizeofInt + ");\n";


                for (int j = 0; j < (dimensions[0] + 1); j++) {
                    translation += label + ".dimensions[" + to_string(j) + "] = " + to_string(dimensions[j]) + ";\n";
                }

                int i = 0;
                for (list<string>::iterator it = allLabels.begin(); it != allLabels.end(); ++it, i++) {
                    string currentLabel = split(*it, " - ")[0];
                    translation += label + ".array[" + to_string(i) + "] = " + currentLabel + ";\n";
                }

                return translation;
            }

            int getLength() {
                return labels.size() > 0 ? labels.size() : childs.size();
            }

            int getDepth() {
                int depth = 0;

                for (list<Array*>::iterator it = childs.begin(); it != childs.end(); ++it) {
                    Array* child = *it;
                    int childDepth = child->getDepth();

                    if (childDepth > depth) {
                        depth = childDepth;
                    }
                }

                return depth + 1;
            }

            int getElementsCount() {
                if (labels.size() > 0) {
                    return labels.size();
                }

                if (childs.size() == 0) {
                    return 0;
                }

                Array* firstChild = childs.front();
                return firstChild->getElementsCount() * childs.size();
            }

            int* getDimensions() {
                int depth = getDepth();
                int* dimensions = new int[depth + 1];

                int i = 0;
                dimensions[i++] = depth;

                if (labels.size() > 0) {
                    dimensions[i] = labels.size();
                    return dimensions;
                }

                if (childs.size() > 0) {
                    list<Array*> childStack;

                    childStack.push_back(childs.front());
                    dimensions[i++] = childs.size();

                    while (childStack.size() > 0) {
                        Array* currentChild = childStack.back();
                        childStack.pop_back();

                        if (currentChild->labels.size() > 0) {
                            dimensions[i++] = currentChild->labels.size();
                        } else if (currentChild->childs.size() > 0) {
                            childStack.push_back(currentChild->childs.front());
                            dimensions[i++] = currentChild->childs.size();
                        } else {
                            dimensions[i++] = 0;
                        }
                    }
                } else {
                    dimensions[i] = 0;
                }

                return dimensions;
            }
    };

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

            bool isArray() {
                return varType.find("Array") != string::npos;
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
                return toType(getVarType()) + " " + varLabel;
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

            string returnType;
            bool returning;
            bool funcContext;

            Context* parent;
        public:
            Context(Context* parent, bool funcContext = false) {
                this->variables = list<Variable*>();
                this->returnType = VOID_ID;
                this->funcContext = funcContext;

                this->parent = parent;
            }

            Context* getParent() {
                return this->parent;
            }

            bool isFuncContext() {
                return this->funcContext;
            }

            string getReturnType() {
                return returnType;
            }

            bool isReturning() {
                return returning;
            }

            void setReturning(bool returning) {
                this->returning = returning;
            }

            void setReturnType(string returnType) {
                if (!funcContext) {
                    yyerror("The return type can only be defined in a function context");
                }

                if (this->returnType != VOID_ID && returnType != this->returnType) {
                    yyerror("The return type of the function is already defined as \"" + this->returnType + "\"");
                }

                this->returnType = returnType;

                if (parent != NULL && parent->isFuncContext()) {
                    parent->setReturnType(returnType);
                }
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

    class ContextStack {
        private:
            list<Context*> contexts;
            list<Function*> functions;
            int index;
        public:
            ContextStack() {
                this->index = 0;
            }

            Function* findFunction(string functionName, string types) {
                vector<string> typesVector = split(types, ", ");

                for (list<Function*>::iterator it = this->functions.begin(); it != this->functions.end(); ++it) {
                    Function* function = *it;

                    if (function->getName() == functionName) {
                        list<Parameter*> parameters = function->getParameters();

                        if (parameters.size() != typesVector.size()) {
                            continue;
                        }

                        bool found = true;
                        int i = 0;

                        for (list<Parameter*>::iterator it = parameters.begin(); it != parameters.end(); ++it, i++) {
                            Parameter* parameter = *it;

                            if (parameter->getType() != typesVector[i]) {
                                found = false;
                                break;
                            }
                        }

                        if (found) {
                            return function;
                        }
                    }
                }

                return NULL;
            }

            Function* createFunction(Function* function) {
                this->functions.push_back(function);
                return function;
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

            list<Function*> getFunctions() {
                return this->functions;
            }
    };

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

        contextStack = new ContextStack();

        Context* globalContext = new Context(NULL);
        contextStack->push(globalContext);
    }

    Array* createArray() {
        Array* array = new Array();
        arrayCreationStack.push_back(array);
        return array;
    }

    Array* topArrayStack() {
        return arrayCreationStack.back();
    }

    Array* popArrayStack() {
        Array* array = arrayCreationStack.back();
        arrayCreationStack.pop_back();
        return array;
    }

    bool isArrayStackEmpty() {
        return arrayCreationStack.empty();
    }

    Function* createFunction(string name, string nickname) {
        Function* function = new Function(name, nickname);
        functionCreationStack.push_back(function);
        return function;
    }

    Function* topFunctionStack() {
        return functionCreationStack.back();
    }

    Function* popFunctionStack() {
        Function* function = functionCreationStack.back();
        functionCreationStack.pop_back();
        return function;
    }

    bool isFunctionStackEmpty() {
        return functionCreationStack.empty();
    }

    Function* createFunction(Function* function) {
        ContextStack* contextStack = getContextStack();

        contextStack->createFunction(function);
        return function;
    }

    Context* createContext(bool func = false) {
        Context *parent = getContextStack()->top();
        Context *newContext = new Context(parent, parent->isFuncContext() || func);
        getContextStack()->push(newContext);
        return newContext;
    }

    ContextStack* getContextStack() {
        return contextStack;
    }

    list<Variable*> getAllVariables() {
        return allVariables;
    }
}