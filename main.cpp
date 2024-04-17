#include <cstddef>
#include <iostream>
#include "src/app/headers/list.h"

using namespace list;
using namespace std;

int main(void) {
    int valor = 1;
    void* ptr = NULL;

    if (ptr == NULL) {
        cout << "ta porra menor" << endl;
        ptr = new List<int>(&valor);
    }
    
    List<int> *l = (List<int>*) ptr;

    for (int i = 0; i < l->size(); i++) {
        cout << *l->get(i) << endl;
    }
}