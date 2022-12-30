#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class selectionsort_evaluator : public evaluator<selectionsort_evaluator> {
        public:
            typedef selectionsort_operation operation_type;

            void_result do_evaluate(const selectionsort_operation &o);

            void selectionsort(const selectionsort_operation &o, vector<int> A, int l, int r, const string &signature);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const selectionsort_operation &o);
        };
    }
}
