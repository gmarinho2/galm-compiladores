#include <stdio.h>
#include <string>

using namespace std;

#pragma once
namespace file {
    string readFileAsString(string path, bool &success) {
        FILE *file = fopen(path.c_str(), "r");
    
        if (file == NULL) {
            printf("Error opening %s", path.c_str());
            success = false;
            return "";
        }

        string buffer;

        while (!feof(file)) {
            char c = fgetc(file);
            buffer += c;
        }

        fclose(file);
        success = true;
        return buffer.substr(0, buffer.size() - 1);
    }
}