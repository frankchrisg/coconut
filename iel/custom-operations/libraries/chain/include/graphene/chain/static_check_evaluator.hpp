#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class static_check_evaluator : public evaluator<static_check_evaluator> {
        public:
            typedef static_check_operation operation_type;

            void_result do_evaluate(const static_check_operation &o);

            void checkVarGet();

            void checkVarSet(string val);

            void exchange(vector<int> &A, int q, int i);

            void_result do_apply(const static_check_operation &o);
        };
    }
}
