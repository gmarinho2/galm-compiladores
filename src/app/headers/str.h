#include <iostream>
#include <string>
#include <vector>

#pragma once
namespace str {
    std::vector<std::string> split(std::string str, std::string del) {
        // Use find function to find 1st position of delimiter.
        std::vector<std::string> v;
        int end = str.find(del); 

        while (end != -1) { // Loop until no delimiter is left in the string.
            v.push_back(str.substr(0, end));
            str.erase(str.begin(), str.begin() + end + 1);
            end = str.find(del);
        }

        return v;
    }

    std::string indent(std::string code) {
        std::vector<std::string> lines = split(code, "\n");
        std::string identedCode = "";

        for (int i = 0; i < lines.size(); i++) {
            identedCode += "\t" + lines[i] + "\n";
        }

        return identedCode;
    }
}