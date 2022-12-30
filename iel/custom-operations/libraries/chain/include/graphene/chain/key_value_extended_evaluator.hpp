#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class key_value_extended_evaluator : public evaluator<key_value_extended_evaluator> {
        public:
            typedef key_value_extended_in_operation operation_type;

            void_result do_evaluate(const key_value_extended_in_operation &o);

            void get(const key_value_extended_in_operation &o, vector<string> args);

            void set(const key_value_extended_in_operation &o, vector<string> args);

            void_result do_apply(const key_value_extended_in_operation &o);
        };
    }
}
