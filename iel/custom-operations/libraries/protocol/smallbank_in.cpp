#include <graphene/protocol/smallbank_in.hpp>
#include <graphene/protocol/fee_schedule.hpp>

#include <fc/io/raw.hpp>

namespace graphene {
    namespace protocol {

        void smallbank_in_operation::validate() const {
//NOP
        }

    }
} // graphene::protocol

GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::smallbank_in_operation::fee_parameters_type)
GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::smallbank_in_operation)

