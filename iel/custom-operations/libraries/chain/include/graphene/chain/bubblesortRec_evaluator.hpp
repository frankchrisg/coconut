#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class bubblesortRec_evaluator : public evaluator<bubblesortRec_evaluator> {
        public:
            typedef bubblesortRec_operation operation_type;

            void_result do_evaluate(const bubblesortRec_operation &o);

            void bubblesortRec(const bubblesortRec_operation &o, vector<int> &A, int l, int r);

            void exchange(vector<int> &A, int q, int i);

            void bubble(vector<int> &A, int q, int i);

            void_result do_apply(const bubblesortRec_operation &o);
        };
    }
}
