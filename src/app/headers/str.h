#include <iostream>
#include <string>
#include <vector>

using namespace std;

#pragma once
namespace str {
    unsigned long long int currentLine = 1;

    void addLine() {
        currentLine++;
    }

    int getCurrentLine() {
        return currentLine;
    }

    bool isEquals(string str1, string str2) {
        for (int i = 0; i < str1.length(); i++) {
            if (str1[i] != str2[i]) return false;
        }

        return str1.length() == str2.length();
    }

    vector<string> split(string str, string del) {
        // Use find function to find 1st position of delimiter.
        vector<string> v;
        int end = str.find(del); 

        while (end != -1) { // Loop until no delimiter is left in the string.
            v.push_back(str.substr(0, end));
            str.erase(str.begin(), str.begin() + end + 1);
            end = str.find(del);
        }

        return v;
    }

    string indent(string code) {
        vector<string> lines = split(code, "\n");
        string identedCode = "";

        for (int i = 0; i < lines.size(); i++) {
            identedCode += "\t" + lines[i] + "\n";
        }

        return identedCode;
    }

    int countSubstring(const string& str, const string& sub) {
        if (sub.length() == 0 || str.length() < sub.length()) return 0;

        int count = 0;
        
        for (size_t offset = str.find(sub); offset != string::npos; offset = str.find(sub, offset + sub.length())) {
            ++count;
        }
        
        return count;
    }

    /**
     * Starts with ignores case.
    */

    bool startsWith(const string &str, const string &start) {
        if (str.length() < start.length()) return false;

        for (int i = 0; i < start.length(); i++) {
            if (tolower(str[i]) != tolower(start[i])) return false;
        }

        return true;
    }

    /**
     * Ends with ignores case.
    */

    bool endsWith(const string &str, const string &end) {
        if (str.length() < end.length()) return false;

        for (int i = 0; i < end.length(); i++) {
            if (tolower(str[str.length() - i - 1]) != tolower(end[end.length() - i - 1])) return false;
        }

        return true;
    }

    void yyerror(string message, string error = "Syntax error") {
        cout << "\033[1;31m" << error << ": " << message << " (line " << currentLine << ")" << endl << "\033[0m";
        exit(1);
    }
}