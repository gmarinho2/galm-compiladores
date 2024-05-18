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

    int countSubstring(const std::string& str, const std::string& sub) {
        if (sub.length() == 0 || str.length() < sub.length()) return 0;

        int count = 0;
        
        for (size_t offset = str.find(sub); offset != std::string::npos; offset = str.find(sub, offset + sub.length())) {
            ++count;
        }
        
        return count;
    }

    /**
     * Starts with ignores case.
    */

    bool startsWith(const std::string &str, const std::string &start) {
        if (str.length() < start.length()) return false;

        for (int i = 0; i < start.length(); i++) {
            if (tolower(str[i]) != tolower(start[i])) return false;
        }

        return true;
    }

    /**
     * Ends with ignores case.
    */

    bool endsWith(const std::string &str, const std::string &end) {
        if (str.length() < end.length()) return false;

        for (int i = 0; i < end.length(); i++) {
            if (tolower(str[str.length() - i - 1]) != tolower(end[end.length() - i - 1])) return false;
        }

        return true;
    }
}