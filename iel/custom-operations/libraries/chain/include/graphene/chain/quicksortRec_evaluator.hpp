#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class quicksortRec_evaluator : public evaluator<quicksortRec_evaluator> {
        public:
            typedef quicksortRec_operation operation_type;

            void_result do_evaluate(const quicksortRec_operation &o);

            void quicksortRec(const quicksortRec_operation &o, vector<int> &A, int l, int r);

            int partition(vector<int> &A, int l, int r);

            int partition1(vector<int> &A, int x, int i, int j);

            int partition2(vector<int> &A, int x, int i, int j);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const quicksortRec_operation &o);
        };
    }
}
