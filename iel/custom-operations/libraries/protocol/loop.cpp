#include <graphene/protocol/loop.hpp>
#include <graphene/protocol/fee_schedule.hpp>

#include <fc/io/raw.hpp>

namespace graphene {
    namespace protocol {

        void loop_operation::validate() const {
//NOP
        }

    }
}

GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::loop_operation::fee_parameters_type)
GRAPHENE_IMPLEMENT_EXTERNAL_SERIALIZATION(graphene::protocol::loop_operation)

