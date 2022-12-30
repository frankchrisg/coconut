#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class slowsort_evaluator : public evaluator<slowsort_evaluator> {
        public:
            typedef slowsort_operation operation_type;

            void_result do_evaluate(const slowsort_operation &o);

            void slowsort(const slowsort_operation &o, vector<int> &A, int l, int r);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const slowsort_operation &o);
        };
    }
}
