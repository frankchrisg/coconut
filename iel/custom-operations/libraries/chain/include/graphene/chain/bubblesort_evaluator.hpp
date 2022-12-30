#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class bubblesort_evaluator : public evaluator<bubblesort_evaluator> {
        public:
            typedef bubblesort_operation operation_type;

            void_result do_evaluate(const bubblesort_operation &o);

            void bubbleSort(const bubblesort_operation &o, vector<int> A, int l, int r, const string &signature);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const bubblesort_operation &o);
        };
    }
}
