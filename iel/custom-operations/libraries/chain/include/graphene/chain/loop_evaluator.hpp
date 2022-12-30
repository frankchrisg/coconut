#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class loop_evaluator : public evaluator<loop_evaluator> {
        public:
            typedef loop_operation operation_type;

            void_result do_evaluate(const loop_operation &o);

            void loop(const loop_operation &o, int start, int end, const string &signature);

            void_result do_apply(const loop_operation &o);
        };
    }
}
