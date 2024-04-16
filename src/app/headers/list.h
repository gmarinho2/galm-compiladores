#pragma once
namespace list {

    template <class T> class List {
        private:
            T *element;
            List<T> *prox;
        public:
            List(T *element) {
                this->element = element;
                this->prox = NULL;
            }

            T* value() {
                return *element;
            }

            List<T> next() {
                if (prox == NULL) {
                    return NULL;
                }

                return *prox;
            }

            List<T> end() {
                if (prox == NULL) {
                    return *this;
                } else {
                    return prox->end();
                }
            }

            void add(T *element) {
                if (prox == NULL) {
                    prox = new List<T>(element);
                    return;
                }

                prox->add(element);
            }

            T* get(int index) {
                if (index == 0) {
                    return element;
                }

                if (prox != NULL) {
                    return prox->get(index - 1);
                }

                return NULL;
            }

            void remove(int index) {
                if (index == 0) {
                    if (prox != NULL) {
                        List<T> *temp = prox;
                        prox = prox->prox;
                        delete temp;
                    }
                }

                if (prox != NULL) {
                    prox->remove(index - 1);
                }
            }

            int size() {
                if (prox == NULL) {
                    return 1;
                }

                return 1 + prox->size();
            }
    };

}