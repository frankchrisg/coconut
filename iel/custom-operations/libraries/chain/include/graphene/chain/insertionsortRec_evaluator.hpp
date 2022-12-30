#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class insertionsortRec_evaluator : public evaluator<insertionsortRec_evaluator> {
        public:
            typedef insertionsortRec_operation operation_type;

            void_result do_evaluate(const insertionsortRec_operation &o);

            void insertionsortRec(const insertionsortRec_operation &o, vector<int> &A, int l, int r);

            void insert(vector<int> &A, int l, int r);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const insertionsortRec_operation &o);
        };
    }
}
