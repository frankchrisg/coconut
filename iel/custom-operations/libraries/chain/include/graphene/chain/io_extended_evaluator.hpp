#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class io_extended_evaluator : public evaluator<io_extended_evaluator> {
        public:
            typedef io_extended_in_operation operation_type;

            void_result do_evaluate(const io_extended_in_operation &o);

            void write(const io_extended_in_operation &o, vector<string> args);

            void scan(const io_extended_in_operation &o, vector<string> args);

            void revertScan(const io_extended_in_operation &o, vector<string> args);

            vector<char> getVal(int k, int retLen);

            void_result do_apply(const io_extended_in_operation &o);
        };
    }
}