#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class recursion_evaluator : public evaluator<recursion_evaluator> {
        public:
            typedef recursion_operation operation_type;

            void_result do_evaluate(const recursion_operation &o);

            void recursion(const recursion_operation &o, int start, int end);

            void_result do_apply(const recursion_operation &o);
        };
    }
}
