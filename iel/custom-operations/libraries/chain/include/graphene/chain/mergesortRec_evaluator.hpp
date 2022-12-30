#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class mergesortRec_evaluator : public evaluator<mergesortRec_evaluator> {
        public:
            typedef mergesortRec_operation operation_type;

            void_result do_evaluate(const mergesortRec_operation &o);

            void mergesortRec(const mergesortRec_operation &o, vector<int> &A, int l, int r);

            void merge(vector<int> &A, int l, int q, int r);

            void_result do_apply(const mergesortRec_operation &o);
        };
    }
}
