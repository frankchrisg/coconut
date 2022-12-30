#pragma once

#include <graphene/chain/evaluator.hpp>

namespace graphene {
    namespace chain {

        class memory_evaluator : public evaluator<memory_evaluator> {
        public:
            typedef memory_operation operation_type;

            void_result do_evaluate(const memory_operation &o);

            void memory(const memory_operation &o, int lenOut, int lenIn, int firstChar, int length, bool useVector,
                   const string &signature);

            void_result do_apply(const memory_operation &o);
        };
    }
}
