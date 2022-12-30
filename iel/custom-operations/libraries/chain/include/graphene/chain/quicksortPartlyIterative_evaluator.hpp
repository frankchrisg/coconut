#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class quicksortPartlyIterative_evaluator : public evaluator<quicksortPartlyIterative_evaluator> {
        public:
            typedef quicksortPartlyIterative_operation operation_type;

            void_result do_evaluate(const quicksortPartlyIterative_operation &o);

            void quicksortPartlyIterative(const quicksortPartlyIterative_operation &o, vector<int> &A, int l, int r);

            int partition(vector<int> &A, int l, int r);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const quicksortPartlyIterative_operation &o);
        };
    }
}
