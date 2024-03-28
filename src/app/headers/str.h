#include <iostream>
#include <string>
#include <vector>

using namespace std;

#pragma once
namespace str {
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
}