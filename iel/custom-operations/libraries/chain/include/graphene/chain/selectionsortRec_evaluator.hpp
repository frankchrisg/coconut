#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class selectionsortRec_evaluator : public evaluator<selectionsortRec_evaluator> {
        public:
            typedef selectionsortRec_operation operation_type;

            void_result do_evaluate(const selectionsortRec_operation &o);

            void selectionsortRec(const selectionsortRec_operation &o, vector<int> &A, int l, int r);

            int max(vector<int> &A, int q, int l, int r);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const selectionsortRec_operation &o);
        };
    }
}
