#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class insertionsort_evaluator : public evaluator<insertionsort_evaluator> {
        public:
            typedef insertionsort_operation operation_type;

            void_result do_evaluate(const insertionsort_operation &o);

            void insertionsort(const insertionsort_operation &o, vector<int> A, int l, int r, const string &signature);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const insertionsort_operation &o);
        };
    }
}
