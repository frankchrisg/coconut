#include <graphene/protocol/insertionsort.hpp>
#include <graphene/protocol/fee_schedule.hpp>

#include <fc/io/raw.hpp>

namespace graphene {
    namespace protocol {

        void insertionsort_operation::validate() const {
//NOP
        }

    }
}

GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::insertionsort_operation::fee_parameters_type)
GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::insertionsort_operation)

