#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class smallbank_evaluator : public evaluator<smallbank_evaluator> {
        public:
            typedef smallbank_in_operation operation_type;

            void_result do_evaluate(const smallbank_in_operation &o);

            void writeCheck(const smallbank_in_operation &o, vector<string> args);

            void depositChecking(const smallbank_in_operation &o, vector<string> args);

            void transactSavings(const smallbank_in_operation &o, vector<string> args);

            void sendPayment(const smallbank_in_operation &o, vector<string> args);

            void balance(const smallbank_in_operation &o, vector<string> args);

            void amalgamate(const smallbank_in_operation &o, vector<string> args);

            void createAccount(const smallbank_in_operation &o, vector<string> args);

            void_result do_apply(const smallbank_in_operation &o);
        };
    }
}
