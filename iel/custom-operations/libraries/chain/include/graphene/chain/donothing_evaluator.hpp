#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class donothing_evaluator : public evaluator<donothing_evaluator> {
        public:
            typedef donothing_operation operation_type;

            void_result do_evaluate(const donothing_operation &o);

            void_result do_apply(const donothing_operation &o);
        };
    }
}
