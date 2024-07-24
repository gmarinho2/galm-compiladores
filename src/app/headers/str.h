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
        size_t pos_start = 0, pos_end, delim_len = del.length();
        string token;
        vector<string> res;

        while ((pos_end = str.find(del, pos_start)) != string::npos) {
            token = str.substr (pos_start, pos_end - pos_start);
            pos_start = pos_end + delim_len;
            res.push_back (token);
        }

        if (pos_start < str.length()) {
            res.push_back (str.substr (pos_start));
        }
        return res;
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

    string toLowerCase(string str) {
        for (int i = 0; i < str.length(); i++) {
            str[i] = tolower(str[i]);
        }

        return str;
    }

    void yyerror(string message, string error = "Syntax error") {
        cout << "\033[1;31m" << error << ": " << message << " (line " << currentLine << ")" << endl << "\033[0m";
        exit(1);
    }
}