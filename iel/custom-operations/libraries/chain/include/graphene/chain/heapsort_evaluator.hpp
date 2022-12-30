#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class heapsort_evaluator : public evaluator<heapsort_evaluator> {
        public:
            typedef heapsort_operation operation_type;

            void_result do_evaluate(const heapsort_operation &o);

            void heapsort(const heapsort_operation &o, vector<int> &A, int l, int r, const string &signature);

            void buildheap(const vector<int> &A, int l, int r);

            void heapify(vector<int> A, int l, int q, int r);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const heapsort_operation &o);
        };
    }
}
